% clear all
% close all
% clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f = 0.1:0.01:1; 
numFrequencies = length(f);

% Convert frequency from GHz to Hz for wavelength calculation
f_Hz = f * 1e9; % Frequency in Hz

% Speed of light in m/s
c = 3e8;

% Calculate wavelength in meters
wavelength = c ./ f_Hz; 

% User-defined thickness and material selection for each configuration
thickness_config = {
    [3.252291, 0.255655],         % Thickness for 2 layers
    [3.810436, 1.393118, 1.462735], % Thickness for 3 layers
    [3.8067, 0.1452, 1.4186, 1.4369], % Thickness for 4 layers
    [3.584383, 1.611745, 0.783599, 0.667855, 0.244155] % Thickness for 5 layers
};

mat_selection_config = {
    [4, 6],         % Material selection for 2 layers
    [4, 8, 15],     % Material selection for 3 layers
    [4, 15, 8, 15],  % Material selection for 4 layers
    [4, 8, 15, 16, 4] % Material selection for 5 layers
};

% Arrays for relative permittivity and permeability
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

% Loop over different layer configurations (2, 3, 4, 5 layers)
for configIndex = 1:4
    % Get thickness and material selection for each configuration
    thickness = thickness_config{configIndex};
    mat_selection = mat_selection_config{configIndex};
    numLayers = length(thickness);

    % Initialize epsr and mur for infinite medium and air
    epsr = [ones(1, numFrequencies); M_epsr(mat_selection, :); ones(1, numFrequencies)];
    mur = [ones(1, numFrequencies); M_mur(mat_selection, :); ones(1, numFrequencies)];

    % Reflection coefficient arrays
    rSlab_TE_abs1 = zeros(numFrequencies, numLayers+1); 
    a = zeros(1, numFrequencies);
    rSlab_TE_db = zeros(1, numFrequencies);

    % Vectorized call to the RMultiSlab function
    for i = 1:numFrequencies
        [rSlab_TE_abs, ~] = RMultiSlab(numLayers, 0, epsr(:,i), mur(:,i), f(i), thickness);
        rSlab_TE_abs1(i, :) = rSlab_TE_abs;
        a(i) = rSlab_TE_abs1(i, numLayers+1); 
        rSlab_TE_db(i) = 10 .* log10(a(i));
    end

    % Plot the results
    semilogx(f, rSlab_TE_db, 'LineWidth', 2.5);
    hold on;
end

% Plot settings
title('Overlayed Multilayered RAM Structures', 'FontSize', 25)
xlabel('frequency (GHz)', 'FontSize', 25)
ylabel('Reflection (dB)', 'FontSize', 25)
grid on
legend('2 Layers', '3 Layers', '4 Layers', '5 Layers', 'FontSize', 16, 'Location', 'best')
hold off

