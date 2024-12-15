function [n_material,k_material] = interpolate_material(material,frequencies)

assert(isvector(frequencies));

if strcmpi(material, 'air')
  n_material = ones(1, length(frequencies));
  k_material = zeros(1, length(frequencies));
else
  [data_n, data_k] = load_material(material);

  n_material = interp1(data_n(:, 1), data_n(:, 2), frequencies, 'linear');
  k_material = interp1(data_k(:, 1), data_k(:, 2), frequencies, 'linear');
end


end