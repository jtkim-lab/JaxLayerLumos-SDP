clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)

%f = 1;

% radar is coming from the right
% assumes pefect electrical conducting layer is leftmost layer

% xValues: Thickness of the films [mm]
f = 0.1:0.01:1;
% thicknessMM = [1.9863 1.9883 1.4878 0.8485 0.7742];
% materialInd = [4.0000 4.0000 7.0000 16.0000 11.0000];

thicknessMM = [1.155 0.885 1.272 1.446 0.486];
materialInd = [2 11 5 6 16];


% f = linspace(8,12)
% thicknessMM = flipud([1.781920 3.503729 3.473454]);
% materialInd = flipud([6.000000 6.000000 8.000000]);
% nLayers = 3;
%thicknessMM = [2.0];


%thicknessMM = [3.8499 1.2553 1.0716];
%materialInd =[4, 7, 15];
%thicknessMM = 2.0;
%materialInd = [3.0];

% thicknessMM = [0.486 1.446 1.272 0.885 1.155];
% materialInd = [8 7 6 2 1];
backLayer = 'PEC';


numFrequencies = length(f);

% thicknessMM = [2.0];
% materialInd = [6.0];

nLayers = length(thicknessMM);

[epsr, mur, M_epsr, M_mur] = initialize_epsr_mur(materialInd, f);

% Reflection coefficient arrays
% Vectorized call to the RMultiSlab function
[rSlab_TE_abs, rSlab_TM_abs] = RMultiSlab_vectorized(nLayers, 0, epsr, mur, f, thicknessMM, backLayer);
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

for i = 1:size(M_epsr,1)
  filename = ['Mat', num2str(i), '-MIchielssen-20.csv'];
  fileID = fopen(filename, 'w');
  fprintf(fileID, 'wl,n\n');
  fclose(fileID);
  data = [lambda; real(M_nk(i,:))]';
  writematrix(data, filename, 'WriteMode', 'append');
  
  fileID = fopen(filename, 'a');
  fprintf(fileID, '\n');
  fprintf(fileID, 'wl,k\n');
  fclose(fileID);
  data = [lambda; -imag(M_nk(i,:))]';
  writematrix(data, filename, 'WriteMode', 'append');
end


