function [frequencies] = get_frequencies_visible_light(num_wavelengths)

wavelengths = linspace(380e-9, 780e-9, num_wavelengths);
frequencies = convert_wavelengths_to_frequencies(wavelengths);

   