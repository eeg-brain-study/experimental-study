%{
    Script for EEG data processing, which calculates power in different frequency bands (Delta, Theta, Alpha, Beta) for various brain regions.

    INPUTS:
        - EEG data files in .set format from a specified folder
        - Frequency bands and corresponding regions of interest (electrodes)
        - Epochs to analyze, and unwanted channels to exclude

    OUTPUTS:
        - CSV files containing power spectral data:
            - Individual results by electrode, region, and overall power
%}

clear all;  % Clears all variables
Name = '';  % Placeholder for file name, if needed
dataFolder = 'DataPath';  % Path to EEG data folder
reportFolder = 'ReportPath';  % Output folder for reports
mkdir(reportFolder);  % Create output folder if it doesn't exist

FreqMap = [3 11 22 34];  % Frequencies to visualize in the output plots
FreqRange = [2 40];  % Frequency range for spectral analysis
excludedChannels = {'Cz'};  % Channels to be excluded from the analysis

rhythms = {'Delta', 'Theta', 'Alpha','Beta'};  % Frequency bands (Delta, Theta, Alpha, Beta)
freqStart = [0.5, 4, 8, 13];  % Starting frequencies for each band
freqEnd = [3.99, 7.99, 12.99, 30];  % Ending frequencies for each band

epochStart = 1;  % Initial epoch for analysis (1 means from the start)
epochEnd = 30;  % Final epoch for analysis (-1 for all epochs)

%% Region and electrode configuration
regions = {'FrontalR','FrontalL','CentralR','CentralL','TemporalR','TemporalL','ParietalR','ParietalL','OccipitalR','OccipitalL'};  % Brain regions
regionElectrodes = {
    {'FP2','AF4','F10','F8','F6','F4'}, ...  % Right Frontal electrodes
    {'FP1','AF3','F9','F7','F5','F3'}, ...  % Left Frontal electrodes
    {'FC6','FC4','FC2','F2','C6','C4','C2'}, ...  % Right Central electrodes
    {'FC5','FC3','FC1','F1','C5','C3','C1'}, ...  % Left Central electrodes
    {'TP8','FT8','T10','T8'}, ...  % Right Temporal electrodes
    {'TP7','FT7','T9','T7'}, ...  % Left Temporal electrodes
    {'CP6','CP4','CP2','P10','P8','P6','P4','P2'}, ...  % Right Parietal electrodes
    {'CP5','CP3','CP1','P9','P7','P5','P3','P1'}, ...  % Left Parietal electrodes
    {'PO4','O2'}, ...  % Right Occipital electrodes
    {'PO3','O1'} ...  % Left Occipital electrodes
};

%% Load EEG data files from the folder
files = dir([dataFolder, Name, '*.set']);  % Get list of .set files
numFiles = length(files);  % Number of files in the folder

%% Load electrode names from the first EEG file
EEG = pop_loadset([dataFolder files(1).name]);
numChannels = EEG.nbchan;  % Number of channels
for i = 1:numChannels
    EEG.chanlocs(i).labels = upper(EEG.chanlocs(i).labels);  % Convert channel labels to uppercase
end
EEG = pop_select(EEG, 'nochannel', upper(excludedChannels));  % Remove unwanted channels
numChannels = EEG.nbchan;  % Update channel count after removal
for i = 1:numChannels
    channels{i} = EEG.chanlocs(i).labels;  % Store channel labels
end
clear EEG  % Clear the EEG variable

%% Output tables for storing results
out = cell(length(rhythms), length(files), 3);  % Table to store results by channel
stdev = cell(length(rhythms), length(files), 1);  % Table to store standard deviations

%% MAIN processing loop for each file
for i = 1:numFiles
    disp(['Processing file -------------------- ' files(i).name]);
    EEG = pop_loadset([dataFolder files(i).name]);  % Load EEG file
    EEG = pop_select(EEG, 'nochannel', excludedChannels);  % Exclude specified channels
    EEG = eeg_checkset(EEG);  % Check EEG dataset consistency
    
    if epochEnd == 1
        epochEnd = EEG.trials;  % If final epoch is set to 1, use all epochs
    end
    epochRange = [];
    if epochStart > 1
        epochRange = [1:epochStart-1];  % Exclude epochs before epochStart
    end
    if epochEnd < EEG.trials
        epochRange = [epochRange epochEnd+1:EEG.trials];  % Exclude epochs after epochEnd
    end
    EEG = pop_rejepoch(EEG, epochRange, 0);  % Reject unwanted epochs

    %% Calculate power spectrum for each frequency band
    numPoints = EEG.pnts;
    numEpochs = EEG.trials;
    sampleRate = EEG.srate;
    eegData = EEG.data;
    channelsToAnalyze = 1:EEG.nbchan;
    
    for r = 1:length(rhythms)
        disp(['Calculating for ' rhythms{r}]);
        spec = meanfreq2(freqStart(r), freqEnd(r), channelsToAnalyze, numPoints, numEpochs, sampleRate, eegData);  % Call custom function for spectral analysis
        out{r,i,2} = numEpochs;  % Store number of epochs
        out{r,i,3} = spec;  % Store power spectrum
        stdev{r,i,1} = std(spec);  % Store standard deviation of spectrum
    end
    
    %% Optional: Plot spectrograms
    % figure;
    % pop_spectopo(EEG, 1, [0  EEG.pnts-1], 'EEG', 'freq', FreqMap, 'freqrange', FreqRange, 'electrodes', 'on');
    % nameImg = [reportFolder files(i).name(1:end-3) 'png'];
    % saveas(gcf, nameImg);
    % close
end

%% Generate output files for each rhythm (by individual, electrode, and region)
for rt = 1:length(rhythms)
    %% File by individual
    fp = fopen([reportFolder rhythms{rt} '_IND.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqStart(rt), freqEnd(rt));
    fprintf(fp, 'Name;#Epochs;Power\n');
    
    for j = 1:length(files)
        fprintf(fp, '%s;%d', files(j).name, out{rt,j,2});
        sumPower = 0;
        for i = 1:numChannels
            sumPower = sumPower + out{rt,j,3}(i);
        end
        fprintf(fp, ';%f\n', sumPower/numChannels);  % Average power per channel
    end
    fclose(fp);

    %% File by electrode
    fp = fopen([reportFolder rhythms{rt} '_ELE.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqStart(rt), freqEnd(rt));
    fprintf(fp, 'Name;#Epochs');
    
    for i = 1:numChannels
        fprintf(fp, ';%s', channels{i});  % Electrode names as headers
    end
    fprintf(fp, '\n');
    
    for j = 1:length(files)
        fprintf(fp, '%s;%d', files(j).name, out{rt,j,2});
        for i = 1:numChannels
            fprintf(fp, ';%f', out{rt,j,3}(i));
        end
        fprintf(fp, '\n');
    end
    fclose(fp);

    %% File by region
    fp = fopen([reportFolder rhythms{rt} '_REG.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqStart(rt), freqEnd(rt));
    fprintf(fp, 'Name;#Epochs');
    
    for r = 1:length(regions)
        fprintf(fp, ';%s', regions{r});  % Region names as headers
    end
    fprintf(fp, '\n');
    
    for j = 1:length(files)
        fprintf(fp, '%s;%d', files(j).name, out{rt,j,2});
        for r = 1:length(regions)
            sumPower = 0;
            N = 0;
            for i = 1:numChannels
                id = find(strcmpi(regionElectrodes{r}, channels{i}));  % Find electrodes belonging to the current region
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
disp('Done');  % Display completion message