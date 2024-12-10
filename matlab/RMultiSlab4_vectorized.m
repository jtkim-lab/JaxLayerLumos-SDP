function [rSlab_TE_abs, rSlab_TM_abs, tSlab_TE_abs, tSlab_TM_abs, coeff_TE, coeff_TM, kz] = RMultiSlab3_vectorized(theta_inc, epsr, mur, f, d_input, materials)
% Calculates the reflection coefficients for TE and TM polarization
% from a multilayer slab structure.
%
% Inputs:
% theta_inc- Angle of incidence (degrees)
% epsr     - Relative permittivity array for each slab
% mur      - Relative permeability array for each slab
% f        - Frequency (GHz)
% d        - Thickness of each slab (mm)
%
% Outputs:
% rSlab_TE_abs - Absolute value squared of the total reflection coefficient for TE polarization
% rSlab_TM_abs - Absolute value squared of the total reflection coefficient for TM polarization

% includes incident layer and last layer
% add air to front and back
% d = [0 d_input];
% Initialize epsr and mur for infinite medium and air
%epsr = [ones(1,epsr];
%mur = [ones(1, length(f)); mur];
% flipped the sidesf


% Convert frequency from GHz to Hz
f = f * 1e9;

% Convert slab thickness from mm to m
d = d_input * 1e-3;
numLayers = length(d);

NK = conj(sqrt(epsr .* mur));

% NK(end,:) = real(NK(end,:));

% if any(imag(NK(:)) < 0)
%   NK(imag(NK) < 0) = conj(NK(imag(NK) < 0));
% end
%NK = conj(sqrt(epsr .* mur));
%NK = sqrt(epsr .* mur);
%NK(imag(NK)< 0) = conj(NK(imag(NK)< 0));
eta = conj(sqrt(mur./epsr)); % impedance of materials
% eta(end,:) = real(eta(end,:));
%if any(imag(eta(:)) > 0)
  %eta(imag(eta) > 0) = conj(eta(imag(eta) > 0));
%end
%eta = sqrt(mu./eps);


c = 299792458; % m/s
k = 2 * pi./c * f.*NK;
sin_theta = zeros(numLayers, length(f));
sin_theta(1,:) = sin(theta_inc);
for j = 1:numLayers-1
  sin_theta(j+1,:) = (k(j,:).* sin_theta(j,:))./k(j+1,:); % sin(Theta) in slab i
end

%theta = asin(sin_theta);
cos_theta = sqrt(1-sin_theta.^2);
kz = k.*cos_theta;

delta = d.'.*kz;

Z_TE = eta./cos_theta;
Z_TM = eta.*cos_theta;

% switch(backLayer)
%   case('PEC')
%     Z_TE(end,:) = Inf;
%     Z_TM(end,:) = Inf;
%   case('air')
%     % Do nothing as the last layer is already set to air
%   otherwise
%     error('back layer must be PEC or air')
% end


M_TE = repmat(eye(2), 1, 1, length(f));
M_TM = repmat(eye(2), 1, 1, length(f));

M_TE_all = zeros(2, 2, numLayers, length(f));
M_TM_all = zeros(2, 2, numLayers, length(f));

for j = 1:numLayers-1
  
  r_jk_TE = (Z_TE(j+1,:)- Z_TE(j,:))./(Z_TE(j+1,:)+ Z_TE(j,:));
  t_jk_TE = (2*Z_TE(j+1,:))./(Z_TE(j+1,:)+ Z_TE(j,:));

  r_jk_TM = (Z_TM(j+1,:)- Z_TM(j,:))./(Z_TM(j+1,:)+ Z_TM(j,:));
  t_jk_TM = (2*Z_TM(j+1,:))./(Z_TM(j+1,:)+ Z_TM(j,:));

  if j == numLayers -1 && strcmp(materials{end},'PEC')
    r_jk_TE = -ones(1, length(f));
    t_jk_TE = ones(1, length(f)); % Avoid division by zero
    r_jk_TM = -ones(1, length(f));
    t_jk_TM = ones(1, length(f));
  end

  D_jk_TE = repmat(eye(2), 1, 1,length(f));
  D_jk_TE(1,2,:) = r_jk_TE;
  D_jk_TE(2,1,:) = r_jk_TE;
  D_jk_TE = D_jk_TE./reshape(t_jk_TE, 1, 1, []);

  D_jk_TM = repmat(eye(2), 1, 1,length(f));
  D_jk_TM(1,2,:) = r_jk_TM;
  D_jk_TM(2,1,:) = r_jk_TM;
  D_jk_TM = D_jk_TM./reshape(t_jk_TM, 1, 1, []);

  P = zeros(2, 2, length(f));
  P(1,1,:) = exp(-1j*delta(j+1,:));
  P(2,2,:) = exp(1j*delta(j+1,:));
 
  M_TE = pagemtimes(M_TE, pagemtimes(D_jk_TE,P));
  M_TM = pagemtimes(M_TM, pagemtimes(D_jk_TM,P));

  M_TE_all(:,:,j,:) = M_TE;
  M_TM_all(:,:,j,:) = M_TM;
end

coeff_TE = zeros(2, length(f), numLayers);
coeff_TM = zeros(2, length(f), numLayers);

coeff_TE(:, :, numLayers) = repmat([1;0], 1, length(f));
coeff_TM(:, :, numLayers) = repmat([1;0], 1, length(f));

for index = numLayers-1:-1:1
  coeff_TE(:, index) = M_TE_all(:,:,index,:)*coeff_TE(:, :, numLayers);
  coeff_TM(:, index) = M_TE_all(:,:,index,:)*coeff_TM(:, :, numLayers);
end

r_TE_i = squeeze(M_TE(2,1,:)./M_TE(1,1,:));
t_TE_i = squeeze(1./M_TE(1,1,:));

r_TM_i = squeeze(M_TM(2,1,:)./M_TM(1,1,:));
t_TM_i = squeeze(1./M_TM(1,1,:));


rSlab_TE_abs = abs(r_TE_i).^2;
tSlab_TE_abs = abs(t_TE_i).^2.*real(NK(end,:)*cos_theta(end,:)./(NK(1,:)*cos_theta(1,:)))';

rSlab_TM_abs = abs(r_TM_i).^2;
tSlab_TM_abs = abs(t_TM_i).^2.*real(NK(end,:)*cos_theta(1,:)./(NK(1,:)*cos_theta(end,:)))';
