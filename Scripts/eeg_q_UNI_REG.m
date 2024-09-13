%{
    Script for EEG data processing, calculating power in different frequency bands (Delta, Theta, Alpha, Beta) across various brain regions.

    INPUTS:
        - EEG data files in .set format from a specified folder
        - Frequency bands and corresponding regions of interest (electrodes)
        - Epochs to analyze, unwanted channels to exclude

    OUTPUTS:
        - CSV files containing power spectral data:
            - Individual results by electrode, region, and overall power
%}

clear all;  % Clears all variables
Name = '';  % Placeholder for file name, if needed
dataFolder = 'DataPath';  % Path to EEG data folder
reportFolder = 'OutputPath\';  % Path to output folder for reports
mkdir(reportFolder);  % Creates the output folder if it doesn't exist

FreqMap = [3 11 22 34];  % Frequencies to visualize in the output plots
FreqRange = [2 40];  % Frequency range for spectral analysis
delChannels = {'Cz'};  % Channels to exclude from the analysis

rhythms = {'Delta', 'Theta', 'Alpha', 'Beta'};  % Frequency bands (Delta, Theta, Alpha, Beta)
freqIn = [0.5, 4, 8, 13];  % Starting frequencies for each band
freqFi = [3.99, 7.99, 12.99, 30];  % Ending frequencies for each band

EpStart = 1;  % Initial epoch for analysis (1 means from the start)
EpEnd = 30;  % Final epoch for analysis (-1 for all epochs)

%% Region and electrode configuration
% Brain regions
regions = {'Frontal', 'Central', 'RightTemporal', 'LeftTemporal', 'Parietal', 'Occipital'};  
% Electrodes corresponding to each region
regionElectrodes = { 
    {'FP2','AF4','F10','F8','F6','F4','FP1','AF3','F9','F7','F5','F3'}, ...
    {'FC6','FC4','FC2','F2','C6','C4','C2','FC5','FC3','FC1','F1','C5','C3','C1'}, ...
    {'TP8','FT8','T10','T8'}, ...
    {'TP7','FT7','T9','T7'}, ...
    {'CP6','CP4','CP2','P10','P8','P6','P4','P2','CP5','CP3','CP1','P9','P7','P5','P3','P1'}, ...
    {'PO4','O2','PO3','O1'}
};

%% Load EEG data files from the folder
files = dir([dataFolder, Name, '*.set']);  % Gets the list of .set files in the folder
numFiles = length(files);  % Number of files in the folder

%% Load electrode names from the first EEG file
EEG = pop_loadset([dataFolder files(1).name]);
numChannels = EEG.nbchan;  % Number of channels
for i = 1:numChannels
    EEG.chanlocs(i).labels = upper(EEG.chanlocs(i).labels);  % Convert channel labels to uppercase
end
EEG = pop_select(EEG, 'nochannel', upper(delChannels));  % Remove unwanted channels
numChannels = EEG.nbchan;  % Update channel count after removing channels
for i = 1:numChannels
    chans{i} = EEG.chanlocs(i).labels;  % Store channel labels
end
clear EEG  % Clear the EEG variable

%% Output tables for storing results
out = cell(length(rhythms), length(files), 3);  % Table to store results by channel
stdev = cell(length(rhythms), length(files), 1);  % Table to store standard deviations

%% MAIN processing loop for each file
for i = 1:numFiles
    disp(['PROCESSING FILE -------------------- ' files(i).name]);
    EEG = pop_loadset([dataFolder files(i).name]);  % Load EEG file
    EEG = pop_select(EEG, 'nochannel', delChannels);  % Exclude specified channels
    EEG = eeg_checkset(EEG);  % Check EEG dataset consistency
    
    if EpEnd == 1
        EpEnd = EEG.trials;  % If final epoch is set to 1, use all epochs
    end
    epochRange = [];
    if EpStart > 1
        epochRange = [1:EpStart-1];  % Exclude epochs before EpStart
    end
    if EpEnd < EEG.trials
        epochRange = [epochRange EpEnd+1:EEG.trials];  % Exclude epochs after EpEnd
    end
    EEG = pop_rejepoch(EEG, epochRange, 0);  % Reject unwanted epochs

    %% Calculate power spectrum for each frequency band
    numPoints = EEG.pnts;  % Number of points per epoch
    numEpochs = EEG.trials;  % Number of epochs
    sampleRate = EEG.srate;  % Sampling rate
    eegData = EEG.data;  % EEG data
    channels = 1:EEG.nbchan;  % Channel indices
    
    for r = 1:length(rhythms)
        disp(['Calculating for ' rhythms{r}]);  % Display current rhythm
        spec = meanfreq2(freqIn(r), freqFi(r), channels, numPoints, numEpochs, sampleRate, eegData);  % Call custom function for spectral analysis
        out{r, i, 2} = numEpochs;  % Store number of epochs
        out{r, i, 3} = spec;  % Store power spectrum
        stdev{r, i, 1} = std(spec);  % Store standard deviation of spectrum
    end
end

%% Generate output files for each rhythm
for rt = 1:length(rhythms)
    %% File by individual
    fp = fopen([reportFolder rhythms{rt} '_IND.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqIn(rt), freqFi(rt));  % Frequency range header
    fprintf(fp, 'Name;#Epochs;Power\n');
    
    for j = 1:length(files)
        fprintf(fp, '%s;%d', files(j).name, out{rt,j,2});  % File name and number of epochs
        sumPower = 0;
        for i = 1:numChannels
            sumPower = sumPower + out{rt,j,3}(i);  % Sum power across channels
        end
        fprintf(fp, ';%f\n', sumPower/numChannels);  % Average power per channel
    end
    fclose(fp);

    %% File by electrode
    fp = fopen([reportFolder rhythms{rt} '_ELE.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqIn(rt), freqFi(rt));  % Frequency range header
    fprintf(fp, 'Name;#Epochs');
    
    for i = 1:numChannels
        fprintf(fp, ';%s', chans{i});  % Electrode names as headers
    end
    fprintf(fp, '\n');
    
    for j = 1:length(files)
        fprintf(fp, '%s;%d', files(j).name, out{rt,j,2});  % File name and number of epochs
        for i = 1:numChannels
            fprintf(fp, ';%f', out{rt,j,3}(i));  % Power for each electrode
        end
        fprintf(fp, '\n');
    end
    fclose(fp);

    %% File by region
    fp = fopen([reportFolder rhythms{rt} '_REG.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqIn(rt), freqFi(rt));  % Frequency range header
    fprintf(fp, 'Name;#Epochs');
    
    for r = 1:length(regions)
        fprintf(fp, ';%s', regions{r});  % Region names as headers
    end
    fprintf(fp, '\n');
    
    for j = 1:length(files)
        fprintf(fp, '%s;%d', files(j).name, out{rt,j,2});  % File name and number of epochs
        for r = 1:length(regions)
            sumPower = 0;
            N = 0;
            for i = 1:numChannels
                id = find(strcmpi(regionElectrodes{r}, chans{i}));  % Find electrodes belonging to the current region
                if ~isempty(id)
                    sumPower = sumPower + out{rt,j,3}(i);  % Sum power for the region
                    N = N + 1;
                end
            end
            fprintf(fp, ';%f', sumPower/N);  % Average power per region
        end
        fprintf(fp, '\n');
    end
    fclose(fp);
end

fclose all;  % Close all file streams
disp('END');  % Display completion message