%Script para colocar as localizações dos canais ,

clear all
tic
pastaDados= 'C:\Users\dhyeg\OneDrive\Dhyego\Mestrado\Matlab\Scripts\EDF_Rose\MERGE\'; % pasta onde estão os dados, coloque uma \ no final

arq=dir([pastaDados, '*.edf']); % Pega os arquivos na pastaDados
tamanho=length(arq); % Diz quantos arquivos tem na pasta
mkdir([pastaDados 'SET\']);

for i=1:tamanho
       
    disp(arq(i).name);
    EEG = pop_biosig([pastaDados arq(i).name], 'importevent','off','blockepoch','off','importannot','off');
    EEG = pop_select( EEG,'nochannel',{'M1','M2','Cb2','Cb1','VEOG','HEOG','EMG','EKG','Fz','FT11','F11','F12','FT12','Status'});%excluindo%
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',50);
    EEG=pop_chanedit(EEG, 'lookup','C:\Users\dhyeg\OneDrive\Dhyego\Mestrado\Matlab\Scripts\standard_1005.elc'); %Caminho do arquivo standard_1005.elc
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on','pca',55);
    EEG = pop_subcomp( EEG, [1  2  3  4], 0);
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',arq(i).name,'filepath',[pastaDados 'SET\']);
    
end

tempo_total = toc;  % Finaliza a contagem do tempo de execução
tempo_total1 = tempo_total/60;
disp(['Tempo total de execução: ' num2str(tempo_total1) ' Minutos']); %Printa o tempo de execução em minutos
disp ('FIM')
