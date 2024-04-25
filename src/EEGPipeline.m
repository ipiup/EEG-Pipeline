%% Extract Epochs for Restings State, Oddball and Arithmetic Tsk

input_folder = 'E:\ISAE-Autre\SeminaireMai2024\EEGPipeline\Data\EEG';
file_name = 'GoldenS.set';
output_folder = 'E:\ISAE-Autre\SeminaireMai2024\EEGPipeline\Data\Epochs';
advanced = input("Advanced Pipeline? [Y/N]","s");

%cd(input_folder);
[ALLEEG, EEG, CURRENTSET] = eeglab;
%% LOAD DATA
EEG = pop_loadset('filename','GoldenS.set','filepath',input_folder);
EEG = pop_select( EEG,'channel',{'A1' 'A2' 'A3' 'A4' 'A5' 'A6' 'A7' 'A8' 'A9' 'A10' 'A11' 'A12' 'A13' 'A14' 'A15' 'A16' 'A17' 'A18' 'A19' 'A20' 'A21' 'A22' 'A23' 'A24' 'A25' 'A26' 'A27' 'A28' 'A29' 'A30' 'A31' 'A32' 'B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9' 'B10' 'B11' 'B12' 'B13' 'B14' 'B15' 'B16' 'B17' 'B18' 'B19' 'B20' 'B21' 'B22' 'B23' 'B24' 'B25' 'B26' 'B27' 'B28' 'B29' 'B30' 'B31' 'B32'});
% XDF : EEG = pop_loadxdf([input_folder, filesep, file_name] , 'streamtype', 'EEG', 'exclude_markerstreams', {});
%% CHANNEL LOCALIZATION
%[ChanLoc, folder2]= uigetfile('*.elp');%select the file for channel location 'Loc_10-20_64Elec.elp'
chanloc_file= 'E:\ISAE-Autre\SeminaireMai2024\EEGPipeline\Data\Loc_10-20_64Elec.elp';
EEG = pop_editset(EEG, 'chanlocs', chanloc_file);
EEG = pop_chanedit(EEG, 'load',{chanloc_file 'filetype' 'autodetect'});
%% REREFERENCE AVERAGE
EEG = pop_reref( EEG, []); % re-referencage et filtre pour la visualisation seulement
%% FILTER 1-40Hz
EEG = pop_eegfiltnew(EEG, 1, 40, 1690, 0, [], 0);
%% redraw EEGLAB GUI
eeglab redraw
%% EPOCH EXTRACTION
% Resting State
saveEpoch(EEG, ALLEEG,output_folder, 'EC',[-0.5 25]);
saveEpoch(EEG, ALLEEG,output_folder, 'EO',[-0.5 25]);
% Oddball
saveEpoch(EEG, ALLEEG,output_folder, 'odd',[-0.5 1]);
saveEpoch(EEG, ALLEEG,output_folder, 'normal',[-0.5 1]);
% Arithmetic Task
saveEpoch(EEG, ALLEEG,output_folder, 'F pressed',[-0.5 5]);
saveEpoch(EEG, ALLEEG,output_folder, 'D pressed',[-0.5 5]);

%% ADVANCED PIPELINE
if advanced == "Y"
    
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',1,'study',0); %Set EEG data back to first EEG set
    %% Cleaning
    EEG = pop_rejchan(EEG, 'elec', 1:64 ,'threshold',10,'norm','on','measure','kurt'); %reject bad channel based on dispersion
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
    eeglab redraw
    
    %% ICA
    EEG = pop_runica(EEG, 'extended',1,'interupt','on'); % To actually run ICA and calculate weights
    EEG = pop_iclabel(EEG, 'default');%Too see how comonent are labelled
    EEG = pop_icflag(EEG, [NaN NaN;0.8 1;0.8 1;NaN NaN;NaN NaN;0.8 1;0.8 1]);% To flag bad component
    EEG = pop_subcomp( EEG, [1   2 ], 0);% !!Component indexes must be checked !!
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off');
    eeglab redraw
else
    disp("End of Epoch Extraction");
end
%% FUNCTIONS
function saveEpoch(EEG, ALLEEG,output_folder, triggerlabel, timelimits)
EEG = pop_epoch( EEG, {triggerlabel}, timelimits, 'epochinfo', 'yes');
EEG = pop_rmbase( EEG, [timelimits(1)*1000 0]); %Remove baseline
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'setname',[triggerlabel,' Epochs'],'gui','off'); 
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename',['Epoch',triggerlabel,'.set'],'filepath',output_folder);
[ALLEEG, EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
pop_eegplot( EEG, 1, 1, 1);
eeglab redraw
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 3,'retrieve',1,'study',0); %Set EEG data back to first EEG set
end
