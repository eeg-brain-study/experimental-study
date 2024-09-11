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
diretorio = 'path\abc.edf';

% List all .edf files in the directory
arquivos_edf = dir(fullfile(diretorio, '*.edf'));
num_arquivos = length(arquivos_edf);

% Ensure there are at least two .edf files to merge
if num_arquivos < 2
    error('At least two .edf files are required to merge.');
end

% Load the first .edf file
EEG = pop_biosig(fullfile(diretorio, arquivos_edf(1).name));

% Loop to merge the remaining .edf files
for i = 2:num_arquivos
    arquivo_atual = fullfile(diretorio, arquivos_edf(i).name);
    EEG_tmp = pop_biosig(arquivo_atual);
    EEG = pop_mergeset(EEG, EEG_tmp, 1);
end

% Save the merged dataset as an EDF file
arquivo_unificado = fullfile(diretorio, '007_BL23.edf');
pop_writeeeg(EEG, arquivo_unificado, 'TYPE', 'EDF');

% Display success message
disp('EDF files merged and saved successfully.');




