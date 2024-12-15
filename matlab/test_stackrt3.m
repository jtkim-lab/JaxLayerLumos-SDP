clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% wavelengths = linspace(300e-9, 900e-9, 3);
wavelengths = 600e-9;
frequencies = convert_wavelengths_to_frequencies(wavelengths); % GHz

materials = {'air', 'cSi', 'air'};

thickness_materials = [0, 10, 0]*1e-9; %*1e-9; % in m


%materials = {'Air', 'Ag', 'Air'};
%thickness_materials = [0 9.36793259, 0]*1e-9; % in m


%n_air = ones(size(frequencies));
%n_stack = n_air;

%backLayer = 'air';
%theta_inc = 0;
theta_inc = deg2rad(45);
thicknessMM = thickness_materials*1000;
%d_stack = [d_air, thickness_materials, d_air];

n_stack = ones(length(materials), length(frequencies));

for i = 1:length(materials)
  [n, k] = interpolate_material(materials{i}, frequencies);
  n_k = n + 1j*k;
  n_stack(i,:) = n_k;
end

n_stack(2,:) = 5.003642857142856 + 4.161857142857143i;
epsr = conj(n_stack.^2);
mur = ones(size(epsr));
%[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs] = RMultiSlab3_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, materials)

coeff_TE = zeros(1, 2, length(frequencies), length(materials));
coeff_TM = zeros(1, 2, length(frequencies), length(materials));

%[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs] = RMultiSlab3_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, "air");
[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs, coeff_TE(1,:,:,:), coeff_TM(1,:,:,:), kz, cos_theta] = RMultiSlab4_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, materials);

%[aSlab_TE_abs] = calc_absorption_from_coeffs(thickness_materials, kz, coeff_TE);
%[aSlab_TM_abs] = calc_absorption_from_coeffs(thickness_materials, kz, coeff_TM);

[aSlab_TE_abs2] = calc_absorption_from_coeffs3(thickness_materials, kz, coeff_TE, cos_theta, 'TE');
[aSlab_TM_abs2] = calc_absorption_from_coeffs3(thickness_materials, kz, coeff_TM, cos_theta, 'TM');



% rSlab_TE_abs + tSlab_TE_abs + aSlab_TE_abs
% rSlab_TM_abs + tSlab_TM_abs + aSlab_TM_abs

rSlab_TE_abs + tSlab_TE_abs + aSlab_TE_abs2
rSlab_TM_abs + tSlab_TM_abs + aSlab_TM_abs2