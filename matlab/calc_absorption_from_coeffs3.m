function [absorptionResult] = calc_absorption_from_coeffs3(thickness, kz, coeff, cos_theta, mode)

if nargin == 3
  cos_theta = ones(size(kz));
end

numLayers = length(thickness);

middleLayerIndex = 2:numLayers -1;
E0f = squeeze(coeff(:, 1, middleLayerIndex)).'./coeff(:, 1, 1);
E0b = squeeze(coeff(:, 2, middleLayerIndex)).'./coeff(:, 1, 1);

kZ(1:length(middleLayerIndex), :) = kz(middleLayerIndex,:);

kZR = real(kZ);
kZI = imag(kZ);

% Z = Z_layers(middleLayerIndex);
% Z0 = Z_layers(1);

dm = thickness(middleLayerIndex);
dm = dm.'*ones(1, size(kZ, 2));

kZ0 = kz(1,:); % incident wave vector
%kZ0 = ones(size(structureInfo.tVector(:, analyzeResultsInfo.tIndex), 1),1)*kZ0;
%A = coeff(:, 1, 1)';

if mode == 'TE'
  absorption = -(kZR.*(abs(E0f).^2).*(exp(-2.*abs(kZI).*dm)-1)-(abs(E0b).^2).*(exp(2.*abs(kZI).*dm)-1))-2.*kZI.*imag(E0f.*conj(E0b).*(exp(-2*1i*kZR.*dm)-1));
  denominator = ones(size(kZ, 1), 1)*kZ0; %.*(A.*conj(A)));
elseif mode == 'TM'
  %absorption = -(kZR.*((E0f.*conj(E0f)).*(exp(-2.*abs(kZI).*dm)-1)-(E0b.*conj(E0b)).*(exp(2.*abs(kZI).*dm)-1))-2.*kZI.*imag(E0f.*conj(E0b).*(exp(-2*1i*kZR.*dm)-1)));
  %absorption = -abs(cos_theta(1,:)).^2/abs(cos_theta(middleLayerIndex,:)).^2.*kZR.*((abs(E0f).^2).*(exp(-2.*abs(kZI).*dm)-1)-(abs(E0b).^2).*(exp(2.*abs(kZI).*dm)-1)-2.*kZI.*imag(E0f.*conj(E0b).*(exp(-2*1i*kZR.*dm)-1)))./kZ0;
  E0f = E0f/cos_theta(middleLayerIndex,:);
  E0b = E0b/cos_theta(middleLayerIndex,:);
  %absorption = -abs(cos_theta(1,:)).^2.*kZR.*((abs(E0f).^2).*(exp(-2.*abs(kZI).*dm)-1)-(abs(E0b).^2).*(exp(2.*abs(kZI).*dm)-1)-2.*kZI.*imag(E0f.*conj(E0b).*(exp(-2*1i*kZR.*dm)-1)))./kZ0;
  absorption = -abs(cos_theta(1,:)).^2.*kZR.*((abs(E0f).^2).*(exp(-2.*abs(kZI).*dm)-1)-(abs(E0b).^2).*(exp(2.*abs(kZI).*dm)-1)-2.*kZI.*real(E0f.*conj(E0b)).*(sin(2*kZR.*dm)))./kZ0;
  denominator = 1;
  %denominator = 1./ones(size(kZ, 1), 1)*kZ0; %.*(A.*conj(A)));
end


absorptionResult = (absorption./denominator)';


end