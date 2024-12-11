function [E] = calc_I_lambda(wavelengths, T)

h = 6.62607015e-34;
k = 1.380649e-23;
c = 299792458;

E = (2 * h* c^2)./ (wavelengths.^5) ./ (exp((h * c) ./ (wavelengths .* k * T)) - 1);
