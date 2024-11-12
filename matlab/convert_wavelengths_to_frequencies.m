function [frequencies] = convert_wavelengths_to_frequencies(wavelengths)

c = 299792458.0;
frequencies = c./wavelengths;

end