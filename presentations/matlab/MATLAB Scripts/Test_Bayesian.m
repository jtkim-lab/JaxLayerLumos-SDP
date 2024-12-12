%This code uses Bayesian optimization to optimize a 3 layer RAM
%The parameters can be changed but this code takes awhile to find optimal
%solutions


clc
clear all
close all

% Initial setup
% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f = 0.1:0.01:1; 
numFrequencies = length(f);

% Convert frequency from GHz to Hz for wavelength calculation
f_Hz = f * 1e9; % Frequency in Hz

% Speed of light in m/s
c = 3e8;

% Material properties initialization
M_epsr = zeros(16, numFrequencies);
M_mur = zeros(16, numFrequencies);

% Fill constant values for permittivity (epsr)
M_epsr(1:5, :) = repmat([10 50 15 15 15]', 1, numFrequencies);
M_epsr(9:16, :) = 15;

% Frequency-dependent permittivity values for materials 6 to 8
M_epsr(6, :) = 5 ./ (f.^0.861) - 1i * (8 ./ (f.^0.569));
M_epsr(7, :) = 8 ./ (f.^0.778) - 1i * (10 ./ (f.^0.682));
M_epsr(8, :) = 10 ./ (f.^0.778) - 1i * (6 ./ (f.^0.861));

% Fill constant values for permeability (mur)
M_mur(1:2, :) = 1;
M_mur(6:8, :) = 1;

% Frequency-dependent permeability for materials 3 to 5
M_mur(3, :) = 5 ./ (f.^0.974) - 1i * (10 ./ (f.^0.961));
M_mur(4, :) = 3 ./ (f.^1) - 1i * (15 ./ (f.^0.957));
M_mur(5, :) = 7 ./ (f.^1) - 1i * (12 ./ (f.^1));

% Frequency-dependent permeability for materials 9 to 16
M_mur(9, :) = (35 * (0.8^2)) ./ (f.^2 + 0.8^2) - 1i * (35 * 0.8 * f) ./ (f.^2 + 0.8^2);
M_mur(10, :) = (35 * (0.5^2)) ./ (f.^2 + 0.5^2) - 1i * (35 * 0.5 * f) ./ (f.^2 + 0.5^2);
M_mur(11, :) = (30 * (1^2)) ./ (f.^2 + 1^2) - 1i * (30 * f) ./ (f.^2 + 1^2);
M_mur(12, :) = (18 * (0.5^2)) ./ (f.^2 + 0.5^2) - 1i * (18 * 0.5 * f) ./ (f.^2 + 0.5^2);
M_mur(13, :) = (20 * (1.5^2)) ./ (f.^2 + 1.5^2) - 1i * (20 * 1.5 * f) ./ (f.^2 + 1.5^2);
M_mur(14, :) = (30 * (2.5^2)) ./ (f.^2 + 2.5^2) - 1i * (30 * 2.5 * f) ./ (f.^2 + 2.5^2);
M_mur(15, :) = (30 * (2^2)) ./ (f.^2 + 2^2) - 1i * (30 * 2 * f) ./ (f.^2 + 2^2);
M_mur(16, :) = (25 * (3.5^2)) ./ (f.^2 + 3.5^2) - 1i * (25 * 3.5 * f) ./ (f.^2 + 3.5^2);

% Number of layers
nVar = 3; 

% Bayesian Optimization Setup
% Define the variables for Bayesian Optimization
thicknessVars = optimizableVariable.empty;
materialVars = optimizableVariable.empty;
for i = 1:nVar
    thicknessVars(i) = optimizableVariable(sprintf('Thickness%d', i), [0.1, 7.0], 'Type', 'real');
    materialVars(i) = optimizableVariable(sprintf('Material%d', i), [1, 16], 'Type', 'integer');
end

vars = [thicknessVars, materialVars];

% Objective Function for Bayesian Optimization
fun = @(params) reflectionObjective_BO(params, f, M_epsr, M_mur);

% Run Bayesian Optimization with increased variability
results = bayesopt(fun, vars, ...
    'UseParallel', true, ...
    'MaxObjectiveEvaluations', 1010, ... % Increase number of evaluations
    'NumSeedPoints', 10, ... % Increase number of initial points to promote exploration
    'AcquisitionFunctionName', 'expected-improvement-plus', ...
    'ExplorationRatio', 0.5, ... % Increase exploration ratio to encourage more variability
    'PlotFcn', {@plotMinObjective, @plotAcquisitionFunction}, ...
    'Verbose', 1);

% Extract optimal parameters
opt_params = results.XAtMinObjective;
opt_thickness = [opt_params.Thickness1, opt_params.Thickness2, opt_params.Thickness3];
opt_material_selection = [opt_params.Material1, opt_params.Material2, opt_params.Material3];

% Display the results
disp('Optimal Thickness (mm):');
disp(opt_thickness);
disp('Optimal Material Selection:');
disp(opt_material_selection);
disp('Minimum Reflection in dB:');
disp(results.MinObjective);

% Use the optimal parameters to compute and plot reflection
thickness = opt_thickness;
mat_selection = opt_material_selection;

% Initialize epsr and mur based on mat_selection
epsr = [ones(1, numFrequencies); M_epsr(mat_selection, :); ones(1, numFrequencies)];
mur = [ones(1, numFrequencies); M_mur(mat_selection, :); ones(1, numFrequencies)];

% Vectorized call to the RMultiSlab function
for i = 1:numFrequencies
    [rSlab_TE_abs, rSlab_TM_abs] = RMultiSlab(nVar, 0, epsr(:,i), mur(:,i), f(i), thickness);
    rSlab_TE_abs1(i, :) = rSlab_TE_abs;
    rSlab_TM_abs1(i, :) = rSlab_TM_abs;
    a(i) = rSlab_TE_abs1(i, nVar+1); % The 6th reflection coefficient
    rSlab_TE_db(i) = 10 .* log10(a(i));
end

% Plot the optimized reflection
semilogx(f, rSlab_TE_db, 'r', 'LineWidth', 2.5);
title('Optimized RAM Structure')
xlabel('Frequency (GHz)')
ylabel('Max Reflection in dB')
grid on
hold on

%%
function reflection_db = reflectionObjective_BO(params, f, M_epsr, M_mur)
    % Extract the number of layers and material indices from the parameters
    thickness = [params.Thickness1, params.Thickness2, params.Thickness3];
    mat_selection = [params.Material1, params.Material2, params.Material3];

    numFrequencies = length(f);

    % Initialize epsr and mur based on mat_selection
    epsr = [ones(1, numFrequencies); M_epsr(mat_selection, :); ones(1, numFrequencies)];
    mur = [ones(1, numFrequencies); M_mur(mat_selection, :); ones(1, numFrequencies)];

    % Call RMultiSlab to calculate reflection for each frequency
    a = zeros(1, numFrequencies);

    for i = 1:numFrequencies
        [rSlab_TE_abs, ~] = RMultiSlab(length(thickness), 0, epsr(:,i), mur(:,i), f(i), thickness);
        a(i) = rSlab_TE_abs(end); % Reflection coefficient for TE polarization
    end

    % Convert to dB and take the mean over the frequency range
    rSlab_TE_db = 10 .* log10(a);
    reflection_db = max(rSlab_TE_db); % Objective: Minimize the maximum reflection in dB
end


