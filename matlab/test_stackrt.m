clear all
close all
clc

% This script calculates and plots the total reflection for a TE wave 
% in dB versus frequency for a multi-slab configuration.

wavelengths = linspace(300e-9, 900e-9, 3); 
frequencies = convert_wavelengths_to_frequencies(wavelengths); % GHz

[n_Ag, k_Ag] = interpolate_material("Ag", frequencies);
n_k_Ag = n_Ag + 1j*k_Ag;
n_air = ones(size(frequencies));

d_Ag = 2e-6; % in m

%n_stack = [n_air; n_k_Ag; n_air];
n_stack = [n_k_Ag];
%d_stack = [d_air, d_Ag, d_air];
thicknessMM = d_Ag*1000;

theta_inc = 0;

backLayer = 'air';

epsr = conj(n_stack.^2);
mur = ones(size(epsr));
[rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs] = RMultiSlab3_vectorized(theta_inc, epsr, mur, frequencies./1e9, thicknessMM, backLayer);



