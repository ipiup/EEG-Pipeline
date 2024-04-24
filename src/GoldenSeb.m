%%%% Author : Sebastien Scannella
%%%% Ce programme permet d'importer les XDF files, de faire les
%%%% pretraitements necessaires à l'utilisation d'automagic, de sauvegarder
%%%% les données en .mat en .set sous la structure BIDS demandée par automagic
%%%% puis de visulaiser les données pour faire une vérification visuelle

%%%% Before starting change the input and output Folder below and make sure
%%%% you know where the channel location file 'Loc_10-20_64Elec.elp' is, you
%%%% will be asked to select it after running the program 

%%
clear all
close all
clc
%%
% Choose the directory were the input files (.XDF) are stored and where the output files will be saved (.mat and .set) 
InputFolder = 'D:\DATA\2024\sub-goldenS\ses-goldenS\eeg';
OutpuFolder = 'D:\DATA\2024\sub-goldenS\ses-goldenS\eeg';


%% 
% [file,folder]=uigetfile('*.XDF');
%                 CurrFile=fullfile(folder,file);
%                 EEG = pop_loadxdf(CurrFile , 'streamtype', 'EEG', 'exclude_markerstreams', {});
%                 EEG = pop_select( EEG,'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32'});
% 

%%
%cree une structure avec tous les noms de fichier qui se trouvent dans le
%directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(InputFolder);
%liste fichiers .xdf 
liste_XDF=dir('*.xdf');

%% Channel location
[ChanLoc, folder2]= uigetfile('*.elp');%select the file for channel location 'Loc_10-20_64Elec.elp'
ChannelLoc=fullfile(folder2,ChanLoc);

%% Open EEGLAB and import the XDF file
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
%[file,folder]=uigetfile('*.XDF');

for f=1:length(liste_XDF)%f for files

CurrFile=liste_XDF(f).name;%fullfile(folder,file);
subject=CurrFile(5:11);
session=CurrFile(1:end-4);

%% open the currentfile
%cd(InputFolder);%on se replace dans le bon dossier (different from the one where data are saved at the end pf the loop
EEG = pop_loadxdf(CurrFile , 'streamtype', 'EEG', 'exclude_markerstreams', {});
EEG = pop_select( EEG,'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32'});

%% Channel location
% [ChanLoc, folder2]= uigetfile('*.elp');
% ChannelLoc=fullfile(folder2,ChanLoc);
EEG = pop_editset(EEG, 'chanlocs', ChannelLoc);
EEG=pop_chanedit(EEG, 'load',{ChannelLoc 'filetype' 'autodetect'});

end

%% Display the plot to check visually the quality of the signal and the correct 
%number/position of the triggers (every 35 s, we should oberve bliks
%following the EO event, and no blinks following the EC event
EEG = pop_reref( EEG, []); % re-referencage et filtre pour la visualisation seulement
EEG = pop_eegfiltnew(EEG, 1, 40, 1690, 0, [], 0);
pop_eegplot(EEG, 1, 1, 1);
eeglab redraw
% End of basic preprocess->go to epoching or continue with Evolved
% preprocessing
%% Cleaning
EEG = pop_rejchan(EEG, 'elec',[1:64] ,'threshold',10,'norm','on','measure','kurt'); %reject bad channel based on dispersion
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
% EEG = pop_interp(EEG, [], 'spherical');
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
eeglab redraw

%% ICA
EEG = pop_runica(EEG, 'extended',1,'interupt','on'); % To actually run ICA and calculate weights
EEG = pop_iclabel(EEG, 'default');%Too see how comonent are labelled
EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;0.8 1;0.8 1]);% To flag bad component
EEG = pop_subcomp( EEG, [1   2 ], 0);% !!Component indexes must be checked !!
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
eeglab redraw



%% Example epoching in seconds % Resting [-0.5   25]; Oddball [-0.2   1]; Arithmetics [-0.5   5]
EEG = pop_epoch( EEG, {  'EC'  }, [-0.5 25], 'epochinfo', 'yes');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_rmbase( EEG, [-500    0]);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname','EC Epochs','gui','off'); 
EEG = eeg_checkset( EEG );
%pop_eegplot( EEG, 1, 1, 1);
EEG = pop_saveset( EEG, 'filename','Epoch_EC.set','filepath','D:\\DATA\\2024\\sub-goldenS\\');
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw
Rédui
