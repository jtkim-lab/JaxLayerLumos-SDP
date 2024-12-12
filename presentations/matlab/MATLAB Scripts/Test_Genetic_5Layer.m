%This code is used to produce an optimized 5 layer RAM using GA
%It uses the 16 material properties and imports them into an array with the
%thickness values from 0.1 - 7 [mm]. 
%It will also save the values to a .txt and produce a total thickness vs.
%reflection graph

clc; 
clear;

% File to save previous total thickness and reflection results
dataFile = 'Total_Thickness_VS_Reflection_5Layer.mat';

% Check if the previous data file exists
if isfile(dataFile)
    % Load previous data if it exists
    load(dataFile, 'thickness_all', 'reflection_all');
else
    % Initialize empty arrays for thickness and reflection data
    thickness_all = [];
    reflection_all = [];
end

% Initial setup
close all;

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

% Genetic Algorithm Setup
nVar = 5; % Number of layers (updated from 4 to 5)

% Define bounds for thickness and material selection
thickness_lower_bound = 0.1; % Min thickness (mm)
thickness_upper_bound = 7.0; % Max thickness (mm)
material_lower_bound = 1; % Min material index
material_upper_bound = 16; % Max material index

% Bounds vector
lb = [repmat(thickness_lower_bound, 1, nVar), repmat(material_lower_bound, 1, nVar)];
ub = [repmat(thickness_upper_bound, 1, nVar), repmat(material_upper_bound, 1, nVar)];

% Setting IntCon constraint so materials and thickness don't mix (6 7 8 9 10)
% are thickness indices
IntCon = [6 7 8 9 10]; % Updated to include five layers

% Set genetic algorithm options with a mutation function
options = optimoptions('ga', ...
    'PopulationSize', 10, ...
    'MaxGenerations', 10, ...
    'CrossoverFraction', 0.8, ...
    'MutationFcn', @mutationadaptfeasible, ...
    'EliteCount', 3, ...
    'PlotFcn', @gaplotbestf);

% Run the genetic algorithm to find optimal parameters
[opt_params, fval] = ga(@(params) reflectionObjective(params, f, M_epsr, M_mur), 2 * nVar, [], [], [], [], lb, ub, @(params) thicknessConstraint(params), IntCon, options);

% Extract optimal parameters
opt_thickness = opt_params(1:nVar);
opt_material_selection = round(opt_params(nVar + 1:end));

% Use the optimal parameters to compute reflection
thickness = opt_thickness;
mat_selection = opt_material_selection;

% Initialize epsr and mur based on mat_selection
epsr = [ones(1, numFrequencies); M_epsr(mat_selection, :); ones(1, numFrequencies)];
mur = [ones(1, numFrequencies); M_mur(mat_selection, :); ones(1, numFrequencies)];

% Vectorized call to the RMultiSlab function
rSlab_TE_abs1 = zeros(numFrequencies, 1);
for i = 1:numFrequencies
    [rSlab_TE_abs, ~] = RMultiSlab(nVar, 0, epsr(:,i), mur(:,i), f(i), thickness);
    rSlab_TE_abs1(i) = rSlab_TE_abs(nVar + 1); % The final reflection coefficient
end

% Convert reflection coefficient to dB
rSlab_TE_db = 10 .* log10(rSlab_TE_abs1);

% Compute total thickness
total_thickness = sum(thickness);

% Append new data to previous data
thickness_all = [thickness_all; total_thickness];
reflection_all = [reflection_all; fval];

% Display the results
disp('Optimal Thickness (mm):');
disp(opt_thickness);
disp('Total Thickness');
disp(total_thickness);
disp('Optimal Material Selection:');
disp(opt_material_selection);
disp('Minimum Reflection in dB:');
disp(fval);

% Save updated data for next run
save(dataFile, 'thickness_all', 'reflection_all');

% Save the structure in a text file
fileID = fopen('Optimized_Structure_5Layer.txt', 'a'); % Open in append mode
fprintf(fileID, 'Optimal Thickness (mm):\n');
fprintf(fileID, '%f\n', opt_thickness);
fprintf(fileID, '\nOptimal Material Selection:\n');
fprintf(fileID, '%d\n', opt_material_selection);
fprintf(fileID, '\nMinimum Reflection in dB:\n');
fprintf(fileID, '%f\n', fval);
fprintf(fileID, '\n------------------------------\n'); % Separator for readability
fclose(fileID);
disp('Structure appended to Optimized_Structure_5Layer.txt');

% Plot the updated data
figure;
[reflection_all, sortIdx] = sort(reflection_all);
thickness_all = thickness_all(sortIdx);
plot(thickness_all, reflection_all, 'b.', 'MarkerSize', 20);
xlabel('Total Thickness (mm)');
ylabel('Minimum Reflection (dB)');
title('Total Thickness vs. Minimum Reflection for 5 Layer Structure');
grid on;

% Plot the optimized reflection curve
figure;
semilogx(f, rSlab_TE_db, 'r', 'LineWidth', 2.5);
title('Optimized 5 Layered RAM Structure Reflection');
xlabel('Frequency (GHz)');
ylabel('Reflection (dB)');
grid on;
hold on;

%% Reflection Objective Function
function reflection_db = reflectionObjective(params, f, M_epsr, M_mur)
% Extract the number of layers and material indices from the parameters
nVar = length(params) / 2;
thickness = params(1:nVar); % First half of params are thicknesses
mat_selection = round(params(nVar+1:end)); % Second half are material indices, rounded to integers

numFrequencies = length(f);

% Initialize epsr and mur based on mat_selection
epsr = [ones(1, numFrequencies); M_epsr(mat_selection, :); ones(1, numFrequencies)];
mur = [ones(1, numFrequencies); M_mur(mat_selection, :); ones(1, numFrequencies)];

% Call RMultiSlab to calculate reflection for each frequency
a = zeros(1, numFrequencies);
for i = 1:numFrequencies
    [rSlab_TE_abs, ~] = RMultiSlab(nVar, 0, epsr(:,i), mur(:,i), f(i), thickness);
    a(i) = rSlab_TE_abs(end); % Reflection coefficient for TE polarization
end

% Convert to dB and take the mean over the frequency range
rSlab_TE_db = 10 .* log10(a);
reflection_db = max(rSlab_TE_db); % Objective: Minimize the reflection in dB
end

%% Thickness Constraint Function
function [c, ceq] = thicknessConstraint(params)
% Extract thickness values
nVar = length(params) / 2;
thickness = params(1:nVar);

% Constraint: Total thickness must be less than or equal to 7 mm
c = sum(thickness) - 7;
ceq = [];
end
