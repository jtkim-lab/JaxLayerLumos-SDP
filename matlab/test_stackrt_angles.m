clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

num_wavelengths = 5;
frequencies = get_frequencies_visible_light(num_wavelengths);

[n_TiO2, k_TiO2] = interpolate_material("TiO2", frequencies);
n_k_TiO2 = n_TiO2 + 1j*k_TiO2;

d_TiO2 = 2e-8; % in m

%theta_inc = deg2rad(linspace(0, 89, 3));
theta_inc = deg2rad(44.5);

n_stack = [n_k_TiO2];
%d_stack = [d_air, d_Ag, d_air];
thicknessMM = d_TiO2*1000;

backLayer = 'air';

epsr = conj(n_stack.^2);
mur = ones(size(epsr));
rSlab_TE_abs = zeros(length(theta_inc), length(frequencies));
rSlab_TM_abs = zeros(length(theta_inc), length(frequencies));

tSlab_TE_abs = zeros(length(theta_inc), length(frequencies));
tSlab_TM_abs = zeros(length(theta_inc), length(frequencies));
for i = 1:length(theta_inc)
  [rSlab_TE_abs(i,:), rSlab_TM_abs(i,:), tSlab_TE_abs(i,:), tSlab_TM_abs(i,:)] = RMultiSlab3_vectorized(theta_inc(i), epsr, mur, frequencies./1e9, thicknessMM, backLayer);
end

R_avg = (rSlab_TE_abs + rSlab_TM_abs)/2;
T_avg = (tSlab_TE_abs + tSlab_TM_abs)/2;


