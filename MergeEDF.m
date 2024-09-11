% Limpar Workspace
clear;
close all;
clc;

% Adicionar o diretório do EEGLAB ao path do MATLAB
%eeglab_path = 'caminho/para/o/EEGLAB';
%addpath(eeglab_path);

% Carregar EEGLAB
eeglab;

% Definir o diretório onde os arquivos .edf estão localizados
diretorio = 'C:\Users\dhyeg\OneDrive\Dhyego\Mestrado\Matlab\Scripts\EDF_Rose\MERGE\007';

% Listar arquivos .edf no diretório
arquivos_edf = dir(fullfile(diretorio, '*.edf'));
num_arquivos = length(arquivos_edf);

if num_arquivos < 2
    error('Pelo menos dois arquivos .edf são necessários para unificar.');
end

% Carregar o primeiro arquivo .edf
EEG = pop_biosig(fullfile(diretorio, arquivos_edf(1).name));

% Loop para unir os demais arquivos .edf
for i = 2:num_arquivos
    arquivo_atual = fullfile(diretorio, arquivos_edf(i).name);
    EEG_tmp = pop_biosig(arquivo_atual);
    EEG = pop_mergeset(EEG, EEG_tmp, 1);
end

% Salvar o arquivo unificado como .edf
arquivo_unificado = fullfile(diretorio, '007_BL23.edf');
pop_writeeeg(EEG, arquivo_unificado, 'TYPE', 'EDF');

disp('Arquivos .edf unificados e salvos com sucesso.');
