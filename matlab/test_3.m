clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f = 0.1:0.01:1;
numFrequencies = length(f);
backLayer = 'PEC';

% radar is coming from the right
% assumes pefect electrical conducting layer is leftmost layer

% xValues: Thickness of the films [mm]
thicknessMM = [1.0 2.0];
% %nVar = 5; % Number of material layers
% % yValues: Selection of material indices for each layer
materialInd = [6.0 11.0];

nLayers = length(thicknessMM);

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

% Initialize epsr and mur for infinite medium and air
epsr = [ones(1, numFrequencies); M_epsr(materialInd, :); ones(1, numFrequencies)];
mur = [ones(1, numFrequencies); M_mur(materialInd, :); ones(1, numFrequencies)];

% Reflection coefficient arrays
% Vectorized call to the RMultiSlab function
[rSlab_TE_abs, rSlab_TM_abs] = RMultiSlab2_vectorized(nLayers, 0, epsr, mur, f, thicknessMM, backLayer);
a = rSlab_TE_abs(nLayers+1,:);
rSlab_TE_db = 10 .* log10(a);

% Plot the results
semilogx(f, rSlab_TE_db, 'r', 'LineWidth', 2.5);
xlabel('frequency (GHz)')
ylabel('Reflection in dB')
grid on
hold on

M_nk = sqrt(M_epsr.*M_mur);
c = 299792458;
% convert f from GHz to wavelength in microns
lambda = (c./(f*1e3));

%lambda2 = (c./f)

for i = 1:size(M_epsr)
  filename = ['Mat', num2str(i), '-MIchielssen-20.csv']
  fileID = fopen(filename, 'w');
  fprintf(fileID, 'wl,n\n');
  fclose(fileID);
  data = [lambda; real(M_nk(i,:))]';
  find(data< 0)
  writematrix(data, filename, 'WriteMode', 'append');
  
  fileID = fopen(filename, 'a');
  fprintf(fileID, '\n');
  fprintf(fileID, 'wl,k\n');
  fclose(fileID);
  data = [lambda; -imag(M_nk(i,:))]';
  find(data < 0)
  writematrix(data, filename, 'WriteMode', 'append');
end


