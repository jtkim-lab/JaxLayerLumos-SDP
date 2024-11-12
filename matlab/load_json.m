function [material_indices, current_dir] = load_json()
current_dir = fileparts(mfilename('fullpath'));
    
% Construct the path to 'materials.json'
current_dir = fullfile(current_dir, '../jaxlayerlumos/');
materials_file = fullfile(current_dir, 'materials.json');

% Check if the JSON file exists
if exist(materials_file, 'file') ~= 2
  error('Material file %s not found in the current directory.', materials_file);
end

% Read the contents of the JSON file
jsonText = fileread(materials_file);

% Decode the JSON data into a MATLAB structure
material_indices = jsondecode(jsonText);

end