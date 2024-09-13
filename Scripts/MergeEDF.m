%{
This script loads multiple EEG files in EDF format, merges them into a single dataset,
and saves the resulting unified file as an EDF file.

Steps:
1. Clears the MATLAB workspace and closes any open figures.
2. Loads the EEGLAB toolbox (uncomment the lines to add EEGLAB to the MATLAB path if needed).
3. Specifies the directory containing the .edf files to be merged.
4. Checks if there are at least two EDF files in the directory (merging requires at least two).
5. Loads the first EDF file.
6. Loops through the remaining files, loading and merging them with the first dataset.
7. Saves the merged dataset as a new EDF file in the specified directory.

INPUTS:
    - Multiple EDF files located in the specified directory.

OUTPUTS:
    - A single merged EDF file saved in the same directory.

Note:
    Uncomment the `addpath` line if EEGLAB is not already added to the MATLAB path.
    Ensure that the `pop_biosig` and `pop_mergeset` functions from EEGLAB are available.
%}

% Clear Workspace
clear;
close all;
clc;


% Load EEGLAB
eeglab;

% Define the directory where the .edf files are located
directory = 'path\abc.edf';

% List all .edf files in the directory
edf_files = dir(fullfile(directory, '*.edf'));
num_files = length(edf_files);

% Ensure there are at least two .edf files to merge
if num_files < 2
    error('At least two .edf files are required to merge.');
end

% Load the first .edf file
EEG = pop_biosig(fullfile(directory, edf_files(1).name));

% Loop to merge the remaining .edf files
for i = 2:num_files
    current_file = fullfile(directory, edf_files(i).name);
    EEG_tmp = pop_biosig(current_file);
    EEG = pop_mergeset(EEG, EEG_tmp, 1);
end

% Save the merged dataset as an EDF file
merged_file = fullfile(directory, '007_BL23.edf');
pop_writeeeg(EEG, merged_file, 'TYPE', 'EDF');

% Display success message
disp('EDF files merged and saved successfully.');