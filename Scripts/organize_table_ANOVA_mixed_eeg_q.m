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

The mask (`mask`) is a string where each character indicates how to interpret 
the corresponding character in the subject names. For example:
- 'S' means it's part of the subject identifier.
- 'G' means it's part of the group identifier.
- 'T' means it's part of the task identifier.

INPUTS:
    - `dirName`: Directory containing the CSV files to be processed.
    - `mask`: Mask string that defines how to parse subject, group, and task 
      identifiers from the file names.
    - CSV files in the specified directory.

OUTPUTS:
    - Processed CSV files saved in the same directory with "_ANOVA.csv" appended 
      to the file names.

DEPENDENCIES:
    - The function `separateSubj` is used to parse the subject, task, and group 
      information from the file names based on the mask.
%}

clear all
dirName = 'path'; % Directory where the CSV files are located

mask = 'SSSGTTTT';  % Mask to separate subject, group, and task information from file names

% Get the list of CSV files in the directory
files = dir([dirName '\*.csv']);

% Initialize variables to store unique subjects, tasks, and groups
subjects = {};
tasks = {};
groups = {};

% Loop through each CSV file
for j = 1:length(files)
    % Read the current CSV file
    tb = readtable([dirName '\' files(j).name]);
    
    % Process each entry in the file to extract subject, task, and group info
    for i = 1:length(tb.Name)
        [subj, task, grp] = separateSubj(tb.Name{i}, mask);
        subjects{i} = subj;
        tasks{i} = task;
        groups{i} = grp;
    end
   
    % Ensure unique and sorted lists of subjects, tasks, and groups
    subjects = unique(subjects);
    subjects = sort(subjects);
    tasks = unique(tasks);
    tasks = sort(tasks);
    groups = unique(groups);
    groups = sort(groups);

    % Get the number of rows and columns in the table
    [rows, cols] = size(tb);
    col_names = tb.Properties.VariableNames;

    % Create new column names and types for the output table
    newColNames = {'subj', 'Group'};
    newColTypes = {'string', 'string'};
    
    % Create additional columns based on the tasks
    x = length(newColNames);
    for co = 3:length(col_names)
        for ta = 1:length(tasks)
            x = x + 1;
            newColNames{x} = [col_names{co} '_' tasks{ta}];
            newColTypes{x} = 'double';
        end
    end
    
    % Initialize the output table with the new structure
    tbOut = table('Size', [0, numel(newColNames)], 'VariableNames', newColNames, 'VariableTypes', newColTypes);

    % Fill the new table with data
    col_namesNew = tbOut.Properties.VariableNames;
    newline = 1;
    for l = 1:rows
        % Extract subject, task, and group info from each row
        [subj, task, grp] = separateSubj(tb.Name{l}, mask);
        line = find(strcmp(tbOut.subj, subj) .* strcmp(tbOut.Group, grp));
        
        % If the subject and group are not yet in the output table, add them
        if isempty(line)
            tbOut(newline, 1) = {subj};
            tbOut(newline, 2) = {grp};
            line = newline;
            newline = newline + 1;
        end
        
        % Fill in the data for the appropriate columns
        for c = 3:cols
            column = [col_names{c} '_' task]; 
            tbId = find(strcmp(col_namesNew, column));
            tbOut(line, tbId) = tb(l, c);
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
    - name: The string to be parsed (subject name).
    - mask: Mask pattern defining which characters correspond to subject (S),
      group (G), and task (T).

OUTPUTS:
    - subj: Subject identifier parsed from the name.
    - task: Task identifier parsed from the name.
    - grp: Group identifier parsed from the name.
%}
function [subj, task, grp] = separateSubj(name, mask)
    subj = [];
    grp = [];
    task = [];
    name = upper(name);
    
    % Loop through the mask and parse the corresponding parts from the name
    for i = 1:length(mask)
        cd = mask(i);
        if strcmp(cd, 'S')
            subj = [subj name(i)];
        elseif strcmp(cd, 'G')
            grp = [grp name(i)];
        elseif strcmp(cd, 'T')
            task = [task name(i)];
        end
    end
end