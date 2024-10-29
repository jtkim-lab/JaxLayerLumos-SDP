function [rSlab_TE_abs, rSlab_TM_abs] = RMultiSlab_vectorized(M, Theta_inc, epsr, mur, f, d, backLayer)
% Calculates the reflection coefficients for TE and TM polarization
% from a multilayer slab structure.
%
% Inputs:
% M        - Number of slabs
% Theta_inc- Angle of incidence (degrees)
% epsr     - Relative permittivity array for each slab
% mur      - Relative permeability array for each slab
% f        - Frequency (GHz)
% d        - Thickness of each slab (mm)
%
% Outputs:
% rSlab_TE_abs - Absolute value squared of the total reflection coefficient for TE polarization
% rSlab_TM_abs - Absolute value squared of the total reflection coefficient for TM polarization

if nargin == 6
  backLayer = 'PEC';
end

% Convert frequency from GHz to Hz
f = f * 1e9;

% Define constants: permittivity of free space (e0) and permeability of free space (u0)
e0 = 8.854187817e-12; % Permittivity of free space [F/m]
u0 = 1.256637061e-6;  % Permeability of free space [H/m]

% Calculate absolute permittivity (eps) and permeability (mu) for each slab
eps = epsr * e0; % Absolute permittivity for each slab
mu = mur * u0;   % Absolute permeability for each slab

% Convert slab thickness from mm to m
d = d * 1e-3;

% Convert the incidence angle from degrees to radians
Theta_inc = Theta_inc * pi / 180;

% Initialize arrays for sin(theta), reflection coefficients, and wave numbers
sinTh = [];
rFresnel = [];
rSlab_TE = [];
rSlab_TM = [];

sinTh(M+2,:) = sin(Theta_inc)*ones(length(f), 1); % sin(Theta) in the incidence medium

% Calculate wave number (k) for each medium
k = 2 * pi * f.*sqrt(eps.*mu); % Wave number in medium i

% Initialize kz (component of k in the z-direction)
kz = [];

% Assign kz for the incidence medium
kz(M+2) = k(M+2).*cos(Theta_inc); % kz in incidence medium

% Calculate sin(theta) for each slab using Snell's law
% each slab is vertical; 
for i = 1:M+1
  sinTh(M+2-i,:) = (k(M+3-i,:).* sinTh(M+3-i))./k(M+2-i,:); % sin(Theta) in slab i
end

% Calculate kz for each slab
% for i = 1:M+1
%   kz(i,:) = k(i,:) * sqrt(1 - (sinTh(i,:)).^2); % kz in slab i
% end

kz = k.*sqrt(1 - sinTh.^2);

rFresnel = zeros(M+1,length(f));
rFresnelH = zeros(M+1,length(f))
% Calculate Fresnel reflection coefficients for TE (rFresnel) and TM (rFresnelH)
for i = 1:M+1
  rFresnel(i,:) = (mu(i,:) .* kz(i+1,:) - mu(i+1,:) .* kz(i,:)) ./ (mu(i,:) .* kz(i+1,:) + mu(i+1,:) .* kz(i,:)); % TE reflection coefficient
  rFresnelH(i,:) = (kz(i,:) .* eps(i+1,:) - kz(i+1,:) .* eps(i,:)) ./ (kz(i,:) .* eps(i+1,:) + kz(i+1,:) .* eps(i,:)); % TM reflection coefficient
end

% Calculate the absolute value squared of Fresnel reflection coefficients
% rFresnel_abs = abs(rFresnel).^2;
% rFresnelH_abs = abs(rFresnelH).^2;

% Initial values for total reflection coefficients (rSlab_TE and rSlab_TM)
% -1 indicates a Perfect Electric Conductor (PEC) boundary condition
switch(backLayer)
  case('PEC')
    rSlab_TE(1, :) = -1*ones(length(f), 1); % TE polarization
    rSlab_TM(1, :) = -1*ones(length(f), 1); % TM polarization
  case('air')
    rSlab_TE(1,:) = rFresnel(1)*ones(length(f), 1); % initial value for rSlab_TE
    rSlab_TM(1,:) = rFresnelH(1)*ones(length(f), 1); % initial value for rSlab_TM
  otherwise
    error('back layer must be PEC or air')
end


% Calculate total reflection coefficients for TE and TM polarizations
for i = 2:M+1
  rSlab_TE(i,:) = (rFresnel(i,:) + rSlab_TE(i-1,:).* exp(-2j .* kz(i,:) .* d(i-1))) ./ ...
    (1 + rFresnel(i,:) .* rSlab_TE(i-1,:).* exp(-2j .* kz(i,:) .* d(i-1)));
  rSlab_TM(i,:) = (rFresnelH(i) + rSlab_TM(i-1,:) .* exp(-2j * kz(i,:) * d(i-1))) ./ ...
    (1 + rFresnelH(i,:) .* rSlab_TM(i-1,:).* exp(-2j .* kz(i,:) .* d(i-1)));
end

% Calculate the absolute value squared of the total reflection coefficients
rSlab_TE_abs = abs(rSlab_TE).^2;
rSlab_TM_abs = abs(rSlab_TM).^2;
