function [absorptionResult] = calc_absorption_from_coeffs(thickness, kz, coeff);

numLayers = length(thickness);

middleLayerIndex = 2:numLayers -1;
E0f = squeeze(coeff(:, 1, middleLayerIndex)).';
E0b = squeeze(coeff(:, 2, middleLayerIndex)).';

kZ(1:length(middleLayerIndex), :) = kz(middleLayerIndex,:);

kZR = real(kZ);
kZI = imag(kZ);

dm = thickness(middleLayerIndex);
dm = dm.'*ones(1, size(kZ, 2));

kZ0 = kz(1,:); % incident wave vector
%kZ0 = ones(size(structureInfo.tVector(:, analyzeResultsInfo.tIndex), 1),1)*kZ0;
A = coeff(:, 1, 1)';
absorption = -(kZR.*((E0f.*conj(E0f)).*(exp(-2.*abs(kZI).*dm)-1)-(E0b.*conj(E0b)).*(exp(2.*abs(kZI).*dm)-1))-2.*kZI.*imag(E0f.*conj(E0b).*(exp(-2*1i*kZR.*dm)-1)));
denominator = ones(size(kZ, 1), 1)*(kZ0.*(A.*conj(A)));
absorptionResult = (absorption./denominator)';


end