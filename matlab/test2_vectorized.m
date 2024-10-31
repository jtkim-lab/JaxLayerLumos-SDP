clear all
close all

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% Frequency range in GHz (from 0.1 to 1 GHz in steps of 0.01 GHz)
f = 0.1:0.01:1;
numFrequencies = length(f);

% radar is coming from the right
% assumes pefect electrical conducting layer is leftmost layer

% xValues: Thickness of the films in mm
% thicknessMM = [1.9863 1.9883 1.4878 0.8485 0.7742];
% materialInd = [4.0000 4.0000 7.0000 16.0000 11.0000];

% thicknessMM = [1.0 2.0];
% materialInd = [6 11];

thicknessMM = [1.0];
materialInd = [6];


nLayers = length(thicknessMM);

[epsr, mur] = initialize_epsr_mur(materialInd, f);

% Vectorized call to the RMultiSlab function
theta_inc = 0;
[rSlab_TE_abs, rSlab_TM_abs] = RMultiSlab2_vectorized(theta_inc, epsr, mur, f, thicknessMM);
a = rSlab_TM_abs(nLayers+1,:);
rSlab_TE_db = 10 .* log10(a);

% Plot the results
semilogx(f, rSlab_TE_db, 'r', 'LineWidth', 2.5);
xlabel('frequency (GHz)')
ylabel('Reflection in dB')
grid on
hold on

M_nk = sqrt(epsr.*mur);
c = 299792458;
% convert f from GHz to wavelength in microns
lambda = (c./(f*1e3));

%lambda2 = (c./f)
% 
% for i = 1:size(M_epsr)
%   filename = ['Mat', num2str(i), '-MIchielssen-20.csv']
%   fileID = fopen(filename, 'w');
%   fprintf(fileID, 'wl,n\n');
%   fclose(fileID);
%   data = [lambda; real(M_nk(i,:))]';
%   find(data< 0)
%   writematrix(data, filename, 'WriteMode', 'append');
% 
%   fileID = fopen(filename, 'a');
%   fprintf(fileID, '\n');
%   fprintf(fileID, 'wl,k\n');
%   fclose(fileID);
%   data = [lambda; -imag(M_nk(i,:))]';
%   find(data < 0)
%   writematrix(data, filename, 'WriteMode', 'append');
% end
% 
% 
