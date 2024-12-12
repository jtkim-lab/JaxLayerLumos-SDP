clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

wavelengths = 300e-9;
frequencies = convert_wavelengths_to_frequencies(wavelengths); % GHz

materials = {'Air', 'Ag', 'Cr'};
thickness_materials = [0 9.36793259, 0]*1e-9; % in m

n_air = ones(size(frequencies));
%n_stack = n_air;

backLayer = false;
theta_inc = deg2rad(34.767507632418315);
thicknessMM = thickness_materials*1000;

n_stack = ones(length(materials), length(frequencies));

for i = 1:length(materials)
  [n, k] = interpolate_material(materials{i}, frequencies);
  n_k = n + 1j*k;
  n_stack(i,:) = n_k;
end

epsr = conj(n_stack.^2);
mur = ones(size(epsr));
rSlab_TE_abs = zeros(length(theta_inc), length(frequencies));
rSlab_TM_abs = zeros(length(theta_inc), length(frequencies));

tSlab_TE_abs = zeros(length(theta_inc), length(frequencies));
tSlab_TM_abs = zeros(length(theta_inc), length(frequencies));

coeff_TE = zeros(1, 2, length(frequencies), length(materials));
coeff_TM = zeros(1, 2, length(frequencies), length(materials));


for i = 1:length(theta_inc)
  [rSlab_TE_abs(i,:), rSlab_TM_abs(i,:), tSlab_TE_abs(i,:), tSlab_TM_abs(i,:), coeff_TE(i,:,:,:), coeff_TM(i,:,:,:), kz, Z_TE, Z_TM] = RMultiSlab4_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, materials)
  %[rSlab_TE_abs(i,:), rSlab_TM_abs(i,:), tSlab_TE_abs(i,:), tSlab_TM_abs(i,:), coeff_TE(i,:,:,:), coeff_TM(i,:,:,:), kz] = RMultiSlab3_vectorized(theta_inc(i), epsr, mur, frequencies./1e9, thicknessMM, backLayer);
  [aSlab_TE_abs] = calc_absorption_from_coeffs2(thickness_materials, kz, coeff_TE, Z_TE);
  [aSlab_TM_abs] = calc_absorption_from_coeffs2(thickness_materials, kz, coeff_TM, Z_TM);
end



R_avg = (rSlab_TE_abs + rSlab_TM_abs)/2;
T_avg = (tSlab_TE_abs + tSlab_TM_abs)/2;


