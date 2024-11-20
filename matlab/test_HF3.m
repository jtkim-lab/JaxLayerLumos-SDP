clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
%f = linspace(2,8);
f = 0.1:0.01:10;
numFrequencies = length(f);

% radar is coming from the right
% assumes pefect electrical conducting layer is leftmost layer

% xValues: Thickness of the films [mm]
%thicknessMM = [1.9863 1.9883 1.4878 0.8485 0.7742];
% %nVar = 5; % Number of material layers
% % yValues: Selection of material indices for each layer
%materialInd = [4.0000 4.0000 7.0000 16.0000 11.0000];
%thicknessMM = [1];
%materialInd = [6];

thicknessMM = fliplr([1.155 0.885 1.272 1.446 0.486]);
materialInd = fliplr([2 11 5 6 16]);

% thicknessMM = [1.0];
% materialInd = [6.0];


nLayers = length(thicknessMM);

%[epsr, mur] = initialize_epsr_mur(materialInd, f)
[epsr, mur, M_epsr, M_mur] = initialize_epsr_mur2(materialInd, f);


% Reflection coefficient arrays
% Vectorized call to the RMultiSlab function
[rSlab_TE_abs, rSlab_TM_abs] = RMultiSlab3_vectorized(0, epsr, mur, f, thicknessMM);
a = rSlab_TE_abs;
rSlab_TE_db = 10 .* log10(a);

thicknessMM2 = fliplr([0.975 0.465 0.261 0.432 0.537]);
materialInd2 = fliplr([13 2 5 8 16]);

thicknessMM3 = fliplr([0.0009 0.051 0.477 0.636 0.588]);
materialInd3 = fliplr([2 11 5 6 16]);

thicknessMM4 = fliplr([0.078 0.411 0.435 0.039 0.273]);
materialInd4 = fliplr([2 11 5 6 16]);

[epsr2, mur2, M_epsr, M_mur] = initialize_epsr_mur2(materialInd2, f);
[epsr3, mur3, M_epsr, M_mur] = initialize_epsr_mur2(materialInd3, f);
[epsr4, mur4, M_epsr, M_mur] = initialize_epsr_mur2(materialInd4, f);

[rSlab_TE_abs2, rSlab_TM_abs2] = RMultiSlab3_vectorized(0, epsr2, mur2, f, thicknessMM2);
a2 = rSlab_TE_abs2;
rSlab_TE_db2 = 10 .* log10(a2);

[rSlab_TE_abs3, rSlab_TM_abs3] = RMultiSlab3_vectorized(0, epsr3, mur3, f, thicknessMM3);
a3 = rSlab_TE_abs3;
rSlab_TE_db3 = 10 .* log10(a3);

[rSlab_TE_abs4, rSlab_TM_abs4] = RMultiSlab3_vectorized(0, epsr4, mur4, f, thicknessMM4);
a4 = rSlab_TE_abs4;
rSlab_TE_db4 = 10 .* log10(a4);

% Plot the results
semilogx(f, rSlab_TE_db, 'r', 'LineWidth', 2.5);
hold on;
semilogx(f, rSlab_TE_db2, 'b', 'LineWidth', 2.5);
semilogx(f, rSlab_TE_db3, 'g', 'LineWidth', 2.5);
semilogx(f, rSlab_TE_db4, 'c', 'LineWidth', 2.5);
legend('HF1', 'HF2', 'HF3', 'HF4')
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


