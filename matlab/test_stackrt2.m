clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

% wavelengths = linspace(300e-9, 900e-9, 3); 
wavelengths = 300e-9;
frequencies = convert_wavelengths_to_frequencies(wavelengths); % GHz

materials = {'FusedSilica', 'Si3N4'};
thickness_materials = [2.91937911, 6.12241842]*1e-9; % in m

n_air = ones(size(frequencies));
%n_stack = n_air;

backLayer = 'air';
theta_inc = 0;
thicknessMM = thickness_materials*1000;
%d_stack = [d_air, thickness_materials, d_air];

n_stack = ones(length(materials), length(frequencies));

for i = 1:length(materials)
  [n, k] = interpolate_material(materials{i}, frequencies);
  n_k = n + 1j*k;
  n_stack(i,:) = n_k;
end

epsr = conj(n_stack.^2);
mur = ones(size(epsr));
[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs] = RMultiSlab3_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, backLayer)



