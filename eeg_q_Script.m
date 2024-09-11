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
Nome = '';  % Placeholder for file name, if needed
pastaDados = 'DataPath';  % Path to EEG data folder
pastaReport = 'ReportPath';  % Output folder for reports
mkdir(pastaReport);  % Create output folder if it doesn't exist

FreqMap = [3 11 22 34];  % Frequencies to visualize in the output plots
FreqRange = [2 40];  % Frequency range for spectral analysis
delChanels = {'Cz'};  % Channels to be excluded from the analysis

ritmos = {'Delta', 'Teta', 'Alfa','Beta'};  % Frequency bands (Delta, Theta, Alpha, Beta)
freqIn = [0.5, 4, 8, 13];  % Starting frequencies for each band
freqFi = [3.99, 7.99, 12.99, 30];  % Ending frequencies for each band

EpIni = 1;  % Initial epoch for analysis (1 means from the start)
EpFin = 30; % Final epoch for analysis (-1 for all epochs)

%% Region and electrode configuration
reg = {'FrontalD','FrontalE','CentralD','CentralE','TempDir','TempEsq','ParietalD','ParietalE','OcipitalD','OcipitalE'};  % Brain regions
regE = {
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
arq = dir([pastaDados, Nome, '*.set']);  % Get list of .set files
tamanho = length(arq);  % Number of files in the folder

%% Load electrode names from the first EEG file
EEG = pop_loadset([pastaDados arq(1).name]);
ncanais = EEG.nbchan;  % Number of channels
for i = 1:ncanais
    EEG.chanlocs(i).labels = upper(EEG.chanlocs(i).labels);  % Convert channel labels to uppercase
end
EEG = pop_select(EEG, 'nochannel', upper(delChanels));  % Remove unwanted channels
ncanais = EEG.nbchan;  % Update channel count after removal
for i = 1:ncanais
    chans{i} = EEG.chanlocs(i).labels;  % Store channel labels
end
clear EEG  % Clear the EEG variable

%% Output tables for storing results
out = cell(length(ritmos), length(arq), 3);  % Table to store results by channel
des = cell(length(ritmos), length(arq), 1);  % Table to store standard deviations

%% MAIN processing loop for each file
for i = 1:tamanho
    disp(['Processing file -------------------- ' arq(i).name]);
    EEG = pop_loadset([pastaDados arq(i).name]);  % Load EEG file
    EEG = pop_select(EEG, 'nochannel', delChanels);  % Exclude specified channels
    EEG = eeg_checkset(EEG);  % Check EEG dataset consistency
    
    if EpFin == 1
        EpFin = EEG.trials;  % If final epoch is set to 1, use all epochs
    end
    range = [];
    if EpIni > 1
        range = [1:EpIni-1];  % Exclude epochs before EpIni
    end
    if EpFin < EEG.trials
        range = [range EpFin+1:EEG.trials];  % Exclude epochs after EpFin
    end
    EEG = pop_rejepoch(EEG, range, 0);  % Reject unwanted epochs

    %% Calculate power spectrum for each frequency band
    np = EEG.pnts;
    nepcs = EEG.trials;
    srate = EEG.srate;
    eegData = EEG.data;
    canais = 1:EEG.nbchan;
    
    for r = 1:length(ritmos)
        disp(['Calculating for ' ritmos{r}]);
        spec = meanfreq2(freqIn(r), freqFi(r), canais, np, nepcs, srate, eegData);  % Call custom function for spectral analysis
        out{r,i,2} = nepcs;  % Store number of epochs
        out{r,i,3} = spec;  % Store power spectrum
        des{r,i,1} = std(spec);  % Store standard deviation of spectrum
    end
    
    %% Optional: Plot spectrograms
    % figure;
    % pop_spectopo(EEG, 1, [0  EEG.pnts-1], 'EEG', 'freq', FreqMap, 'freqrange', FreqRange, 'electrodes', 'on');
    % nameImg = [pastaReport arq(i).name(1:end-3) 'png'];
    % saveas(gcf, nameImg);
    % close
end

%% Generate output files for each rhythm (by individual, electrode, and region)
for rt = 1:length(ritmos)
    %% File by individual
    fp = fopen([pastaReport ritmos{rt} '_IND.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqIn(rt), freqFi(rt));
    fprintf(fp, 'Name;#Epochs;Power\n');
    
    for j = 1:length(arq)
        fprintf(fp, '%s;%d', arq(j).name, out{rt,j,2});
        soma = 0;
        for i = 1:ncanais
            soma = soma + out{rt,j,3}(i);
        end
        fprintf(fp, ';%f\n', soma/ncanais);  % Average power per channel
    end
    fclose(fp);

    %% File by electrode
    fp = fopen([pastaReport ritmos{rt} '_ELE.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqIn(rt), freqFi(rt));
    fprintf(fp, 'Name;#Epochs');
    
    for i = 1:ncanais
        fprintf(fp, ';%s', chans{i});  % Electrode names as headers
    end
    fprintf(fp, '\n');
    
    for j = 1:length(arq)
        fprintf(fp, '%s;%d', arq(j).name, out{rt,j,2});
        for i = 1:ncanais
            fprintf(fp, ';%f', out{rt,j,3}(i));
        end
        fprintf(fp, '\n');
    end
    fclose(fp);

    %% File by region
    fp = fopen([pastaReport ritmos{rt} '_REG.csv'], 'wt');
    fprintf(fp, 'Freq. Range[%d,%d]\n', freqIn(rt), freqFi(rt));
    fprintf(fp, 'Name;#Epochs');
    
    for r = 1:length(reg)
        fprintf(fp, ';%s', reg{r});  % Region names as headers
    end
    fprintf(fp, '\n');
    
    for j = 1:length(arq)
        fprintf(fp, '%s;%d', arq(j).name, out{rt,j,2});
        for r = 1:length(reg)
            soma = 0;
            N = 0;
            for i = 1:ncanais
                id = find(strcmpi(regE{r}, chans{i}));  % Find electrodes belonging to the current region
                if ~isempty(id)
                    soma = soma + out{rt,j,3}(i);  % Sum power for the region
                    N = N + 1;
                end
            end
            fprintf(fp, ';%f', soma/N);  % Average power per region
        end
        fprintf(fp, '\n');
    end
    fclose(fp);
end

fclose all;  % Close all file streams
disp('Done');  % Display completion message