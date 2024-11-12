function [data_n, data_k] = load_material(material)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
[data_n, data_k] = load_material_wavelength(material);
    
% Convert wavelengths to frequencies
data_n(:, 1) = convert_wavelengths_to_frequencies(data_n(:, 1));
data_k(:, 1) = convert_wavelengths_to_frequencies(data_k(:, 1));

end