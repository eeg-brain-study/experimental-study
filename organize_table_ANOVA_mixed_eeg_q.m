clear all
dirName=['C:\Users\dhyeg\OneDrive\Área de Trabalho\Nova pasta\EEGq300Epocas'];

mascara='SSSGTTTT'; %% G = grupo S=sujeito   T=tarefa   X=Ignore


files=dir([dirName '\*.csv']);
%% CRIA TABELA DE TAREFAS
sujeitos={};
tarefas={};
grupos={};
for j=1:length(files)
    tb=readtable([dirName '\' files(j).name]);
    for i=1:length(tb.Name)
        [suj,tar,gp]=separaSuj(tb.Name{i},mascara);
        sujeitos{i}=suj;
        tarefas{i}=tar;
        grupos{i}=gp;
    end
   
    sujeitos=unique(sujeitos);
    sujeitos=sort(sujeitos);
    tarefas=unique(tarefas);
    tarefas=sort(tarefas);
    grupos=unique(grupos);
    grupos=sort(grupos);
    % Monta tabela nova com as colunas corretas
    [lin,col]=size(tb);
    col_names = tb.Properties.VariableNames;
    newColNames={'suj','Grupo'};
    newColTypes={'string','string'};
    %% Monta novo cabeçalho
    x=length(newColNames);
    for co=3:length(col_names)
        for ta=1:length(tarefas)
            x=x+1;
            newColNames{x}=[col_names{co} '_' tarefas{ta}];
            newColTypes{x} = 'double';
        end
    end
    tbOut=table('Size', [0, numel(newColNames)], 'VariableNames', newColNames, 'VariableTypes',newColTypes);

    
    %% preenche tabela nova
    col_namesNew = tbOut.Properties.VariableNames;
    newline=1;
    for l=1:lin
        [suj,tar,gp]=separaSuj(tb.Name{l},mascara);
        linha = find(strcmp(tbOut.suj,suj) .* strcmp(tbOut.Grupo,gp));
        if isempty(linha)
            tbOut(newline,1)={suj};
            tbOut(newline,2)={gp};
            linha=newline;
            newline=newline+1;
        end
        for c=3:col
            colum=[col_names{c} '_' tar]; 
            tbId=find(strcmp(col_namesNew,colum));
            tbOut(linha,tbId)=tb(l,c);
        end
    end
    newName = [dirName '\' files(j).name(1:end-4) '_ANOVA.csv'];
    disp(newName);
    writetable(tbOut, newName);
    
end



function [suj,tar,grp]=separaSuj(nome,mascara)
suj=[];
grp=[];
tar=[];
nome=upper(nome);
for i=1:length(mascara)
    cd=mascara(i);
    if strcmp(cd,'S')
        suj=[suj nome(i)];
    elseif strcmp(cd,'G')
        grp=[grp nome(i)];
    elseif strcmp(cd,'T')
        tar=[tar nome(i)];
    end
end
end



