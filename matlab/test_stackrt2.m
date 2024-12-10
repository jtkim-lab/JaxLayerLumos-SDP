clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

wavelengths = linspace(300e-9, 900e-9, 3); 
% wavelengths = 300e-9;
frequencies = convert_wavelengths_to_frequencies(wavelengths); % GHz

materials = {'air', 'FusedSilica', 'Si3N4'};
thickness_materials = [0, 2.91937911, 0]; % in m

% materials = {"air", "Ag", "air"};
for i = 1:length(materials)
  [n, k] = interpolate_material(materials{i}, frequencies);
  n_k = n + 1j*k;
  n_stack(i,:) = n_k;
end

theta_inc = 0;

epsr = conj(n_stack.^2);
mur = ones(size(epsr));

thicknessMM = thickness_materials*1000;
%d_stack = [d_air, thickness_materials, d_air];

[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs, coeff_TE, coeff_TM, kz] = RMultiSlab4_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, materials)

%[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs] = RMultiSlab3_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, backLayer)



