# EEG experimental-study

## This repository contains the replication package, analysis scripts, and additional information of the paper


# Replication Package

In `/replication` we provide:

 - all used stimuli provided for the participants (`/tasks`)
 - images for baseline conditions
 - the task viewer, task editor (`/task_viewer`) and the .xml with its configurations

# Forms

In `/forms` we provide the pre experiment forms that was used on our experiment.

# Data Results

For convenience, we provide the `/data` folder that contains all the data resulted from our experiment:

 - Wave_ELE = power of especified wave from each electrode and activity
 - Wave_IND = power of especified wave from each participant and activity
 - Wave_REG = power of especified wave from each brain region and activity

# Statistics

We provided the statistics results from our experiment on `/statistic`

# Analisys 

In `/scripts` we share our analysis scripts that process the input data.

To run the scripts yourself, you will need:

 - Matlab R2018b or latest 
 - EEGLAB v2023.1 or latest

Once your system is ready follow this order of execution:

 - Execute `ICA.m`  with all the .EDF files obteined on your experiment
 - Execute `Unificado_GUI.m` with all the .SET files obteined on `ICA.m` script
 - Execute `eeg_q_Script.m` or `eeg_q_UNI_REG.m` with all the .SET files obteined on `Unificado_GUI.m`

If for any reason you need to merge .EDF file we provide the `MergeEDF.m` script














