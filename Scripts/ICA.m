%{
This MATLAB script processes EEG files in EDF format, applying filtering,
removing unwanted channels, assigning electrode locations, and performing
Independent Component Analysis (ICA). The processed data is saved in SET format
for further analysis.

Steps:
1. Load EDF files from a specified directory.
2. Remove specific channels not required for analysis.
3. Apply band-pass filtering to the data (0.5 Hz to 50 Hz).
4. Assign standard channel locations using an external file.
5. Perform ICA for artifact removal, keeping the first 55 principal components.
6. Remove the first four independent components.
7. Save the processed EEG data in SET format.

INPUTS:
    - EDF EEG files located in the specified folder.

OUTPUTS:
    - Processed EEG data saved as SET files in a new directory.

Note:
    Ensure that the path to the electrode location file ('standard_1005.elc') 
    is correct before running the script.

%}

clear all
tic % Start timer to measure execution time

% Define the path to the folder containing the EEG data files
dataPath= 'DataPath\';

% List all EDF files in the specified folder
fileList=dir([dataPath, '*.edf']); % Retrieve EDF files in 'dataPath'
numFiles=length(fileList); % Get the number of files in the folder
mkdir([dataPath 'SET\']); % Create a new directory to store SET files

% Loop through each EDF file
for i=1:numFiles
    disp(fileList(i).name); % Display the name of the current file being processed
    
    % Load the EDF file without importing events, annotations, or epoching
    EEG = pop_biosig([dataPath fileList(i).name], 'importevent','off', 'blockepoch','off','importannot','off');
    
    % Remove unwanted channels from the dataset
    EEG = pop_select(EEG,'nochannel',{'M1','M2','Cb2','Cb1','VEOG','HEOG','EMG','EKG','Fz','FT11','F11','F12','FT12','Status'});
    
    % Apply a band-pass filter (0.5 Hz - 50 Hz) to the EEG data
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',50);
    
    % Add standard channel location information from the specified file
    EEG = pop_chanedit(EEG, 'lookup','path\standard_1005.elc');
    
    % Perform Independent Component Analysis (ICA) on the EEG data
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',55);
    
    % Remove the first four independent components (assumed to be artifacts)
    EEG = pop_subcomp(EEG, [1  2  3  4], 0);
    
    % Check the consistency of the EEG dataset
    EEG = eeg_checkset(EEG);
    
    % Save the processed EEG data as a SET file in the newly created directory
    EEG = pop_saveset(EEG, 'filename',fileList(i).name,'filepath',[dataPath 'SET\']);
end

% Calculate and display the total execution time in minutes
total_time = toc;  % End the timer
total_time_minutes = total_time / 60; % Convert seconds to minutes
disp(['Total execution time: ' num2str(total_time_minutes) ' minutes']);
disp('END');