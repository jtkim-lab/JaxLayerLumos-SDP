function [n_material,k_material] = interpolate_material(material,frequencies)

assert(isvector(frequencies));

[data_n, data_k] = load_material(material);

n_material = interp1(data_n(:, 1), data_n(:, 2), frequencies, 'linear');
k_material = interp1(data_k(:, 1), data_k(:, 2), frequencies, 'linear');

end