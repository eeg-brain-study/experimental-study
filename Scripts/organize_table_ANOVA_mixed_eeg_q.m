%{
This script processes CSV files containing EEG data, organizes the data based on 
subjects, groups, and tasks as defined by a specified mask pattern, and outputs 
the results in a format suitable for ANOVA analysis.

The script performs the following steps:
1. Reads the CSV files from a specified directory.
2. Parses subject, task, and group information from each data entry based on a given mask.
3. Creates a new table where each column corresponds to a combination of the original 
   variable names and tasks.
4. Fills in the new table with the corresponding data.
5. Saves the new table as a CSV file with the suffix "_ANOVA.csv".

The mask (`mascara`) is a string where each character indicates how to interpret 
the corresponding character in the subject names. For example:
- 'S' means it's part of the subject identifier.
- 'G' means it's part of the group identifier.
- 'T' means it's part of the task identifier.

INPUTS:
    - `dirName`: Directory containing the CSV files to be processed.
    - `mascara`: Mask string that defines how to parse subject, group, and task 
      identifiers from the file names.
    - CSV files in the specified directory.

OUTPUTS:
    - Processed CSV files saved in the same directory with "_ANOVA.csv" appended 
      to the file names.

DEPENDENCIES:
    - The function `separaSuj` is used to parse the subject, task, and group 
      information from the file names based on the mask.
%}

clear all
dirName = 'path'; % Directory where the CSV files are located

mascara = 'SSSGTTTT';  % Mask to separate subject, group, and task information from file names

% Get the list of CSV files in the directory
files = dir([dirName '\*.csv']);

% Initialize variables to store unique subjects, tasks, and groups
sujeitos = {};
tarefas = {};
grupos = {};

% Loop through each CSV file
for j = 1:length(files)
    % Read the current CSV file
    tb = readtable([dirName '\' files(j).name]);
    
    % Process each entry in the file to extract subject, task, and group info
    for i = 1:length(tb.Name)
        [suj, tar, gp] = separaSuj(tb.Name{i}, mascara);
        sujeitos{i} = suj;
        tarefas{i} = tar;
        grupos{i} = gp;
    end
   
    % Ensure unique and sorted lists of subjects, tasks, and groups
    sujeitos = unique(sujeitos);
    sujeitos = sort(sujeitos);
    tarefas = unique(tarefas);
    tarefas = sort(tarefas);
    grupos = unique(grupos);
    grupos = sort(grupos);

    % Get the number of rows and columns in the table
    [lin, col] = size(tb);
    col_names = tb.Properties.VariableNames;

    % Create new column names and types for the output table
    newColNames = {'suj', 'Grupo'};
    newColTypes = {'string', 'string'};
    
    % Create additional columns based on the tasks
    x = length(newColNames);
    for co = 3:length(col_names)
        for ta = 1:length(tarefas)
            x = x + 1;
            newColNames{x} = [col_names{co} '_' tarefas{ta}];
            newColTypes{x} = 'double';
        end
    end
    
    % Initialize the output table with the new structure
    tbOut = table('Size', [0, numel(newColNames)], 'VariableNames', newColNames, 'VariableTypes', newColTypes);

    % Fill the new table with data
    col_namesNew = tbOut.Properties.VariableNames;
    newline = 1;
    for l = 1:lin
        % Extract subject, task, and group info from each row
        [suj, tar, gp] = separaSuj(tb.Name{l}, mascara);
        linha = find(strcmp(tbOut.suj, suj) .* strcmp(tbOut.Grupo, gp));
        
        % If the subject and group are not yet in the output table, add them
        if isempty(linha)
            tbOut(newline, 1) = {suj};
            tbOut(newline, 2) = {gp};
            linha = newline;
            newline = newline + 1;
        end
        
        % Fill in the data for the appropriate columns
        for c = 3:col
            colum = [col_names{c} '_' tar]; 
            tbId = find(strcmp(col_namesNew, colum));
            tbOut(linha, tbId) = tb(l, c);
        end
    end

    % Generate the new file name and save the output table
    newName = [dirName '\' files(j).name(1:end-4) '_ANOVA.csv'];
    disp(newName);
    writetable(tbOut, newName);
    
end


%{
Function to separate subject, task, and group information from a name 
based on the provided mask.

INPUTS:
    - nome: The string to be parsed (subject name).
    - mascara: Mask pattern defining which characters correspond to subject (S),
      group (G), and task (T).

OUTPUTS:
    - suj: Subject identifier parsed from the name.
    - tar: Task identifier parsed from the name.
    - grp: Group identifier parsed from the name.
%}
function [suj, tar, grp] = separaSuj(nome, mascara)
    suj = [];
    grp = [];
    tar = [];
    nome = upper(nome);
    
    % Loop through the mask and parse the corresponding parts from the name
    for i = 1:length(mascara)
        cd = mascara(i);
        if strcmp(cd, 'S')
            suj = [suj nome(i)];
        elseif strcmp(cd, 'G')
            grp = [grp nome(i)];
        elseif strcmp(cd, 'T')
            tar = [tar nome(i)];
        end
    end
end