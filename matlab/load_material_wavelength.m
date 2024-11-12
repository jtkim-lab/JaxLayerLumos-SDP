function [data_n, data_k] = load_material_wavelength(material)

[data_n, data_k] = load_material_wavelength_um(material);

% Convert wavelengths from micrometers to meters by multiplying by 1e-6
data_n(:, 1) = data_n(:, 1) * 1e-6;
data_k(:, 1) = data_k(:, 1) * 1e-6;

end


function [data_n, data_k] = load_material_wavelength_um(material)
% load_material_wavelength_um loads material data from a CSV file,
% parsing wavelengths and corresponding 'n' and 'k' values.
%
% Inputs:
%   material - Name or identifier of the material (string).
%
% Outputs:
%   data_n - Matrix containing wavelengths (in micrometers) and refractive index 'n' values.
%   data_k - Matrix containing wavelengths (in micrometers) and extinction coefficient 'k' values.
%
% This function depends on 'load_json', which should return:
%   - material_indices: a map or struct linking material names to file names.
%   - str_directory: the directory containing the CSV files.

% Load the material indices and directory path
[material_indices,str_directory] = load_json();

% Get the filename for the specified material
if isfield(material_indices, material)
  str_file = material_indices.(material);
elseif isKey(material_indices, material) % If material_indices is a containers.Map
  str_file = material_indices(material);
else
  error('Material %s not found in JaxLayerLumos.', material);
end

% Construct the full path to the CSV file
str_csv = fullfile(str_directory, str_file);

% Initialize data_n and data_k as empty arrays
data_n = [];
data_k = [];

% Open the CSV file for reading
fid = fopen(str_csv, 'r');
if fid == -1
  error('Could not open file %s', str_csv);
end

% Initialize variables to track whether we're reading n or k data
start_n = false;
start_k = false;

% Read the file line by line
while ~feof(fid)
  line = fgetl(fid);
  % Skip empty lines
  if isempty(line)
    continue;
  end
  % Split the line by commas
  row = strsplit(line, ',');
  % Remove any surrounding whitespace
  row = strtrim(row);
  % Remove empty cells
  row = row(~cellfun('isempty', row));

  % Process the row
  if length(row) == 2
    if strcmp(row{1}, 'wl') && strcmp(row{2}, 'n')
      % Starting 'n' data section
      start_n = true;
      start_k = false;
    elseif strcmp(row{1}, 'wl') && strcmp(row{2}, 'k')
      % Starting 'k' data section
      start_n = false;
      start_k = true;
    else
      % Try to parse numerical values
      wavelength_um = str2double(row{1});
      value = str2double(row{2});
      if isnan(wavelength_um) || isnan(value)
        error('Invalid data in file %s', str_csv);
      end
      if start_n && ~start_k
        % Append to data_n
        data_n = [data_n; wavelength_um, value];
      elseif start_k && ~start_n
        % Append to data_k
        data_k = [data_k; wavelength_um, value];
      else
        error('Unexpected data format in file %s', str_csv);
      end
    end
  elseif isempty(row)
    % Ignore empty rows
    continue;
  else
    error('Unexpected row format in file %s', str_csv);
  end
end

% Close the file
fclose(fid);

% Ensure that either data_n or data_k is not empty
if isempty(data_n) && isempty(data_k)
  error('No data found in file %s', str_csv);
end

% If data_n is empty, create it using wavelengths from data_k and zeros for 'n' values
if isempty(data_n)
  data_n = [data_k(:, 1), zeros(size(data_k, 1), 1)];
end

% If data_k is empty, create it using wavelengths from data_n and zeros for 'k' values
if isempty(data_k)
  data_k = [data_n(:, 1), zeros(size(data_n, 1), 1)];
end
end