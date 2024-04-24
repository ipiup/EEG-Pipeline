

%% Analysis Golden Subject Seminaire 2024

EEG = pop_loadset('filename','GoldenS.set','filepath','E:\\ISAE-Autre\\SeminaireMai2024\\');

%Channloc

%Reref
EEG = reref(EEG,[]);
%Filter
EEG = pop_eegfiltnewEEG, A 40, 1690, 0 , [],0);
%Draw
pop_eegplot(EEG,1,1,1);
redra