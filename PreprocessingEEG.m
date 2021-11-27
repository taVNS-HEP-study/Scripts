%% Preprocessing Script for EEG
%  Tasha Poppa & Lars Benschop 
        
%%
clear all
%% Start EEGLAB
eeglab

%% Load in the data
% Define main folder
start_path = fullfile('C:\Users\...\studyDir');

% Confirm or change main folder
top_level_folder = uigetdir(start_path);
if top_level_folder == 0
	return;
end;

% Get subfolder list
all_sub_folders = genpath(top_level_folder);

% Parse into a cell array.
for i = 1:size(all_sub_folders)

    remain = all_sub_folders;
    list_of_folder_names_load = {};
        while true
            [single_sub_folder, remain] = strtok(remain, ';');
            
            if isempty(single_sub_folder)
               break;
            end;
            
            list_of_folder_names_load = [list_of_folder_names_load single_sub_folder];
        end;
        
    number_of_folders = length(list_of_folder_names_load);
end;

% Sort the folders (subj1, subj2, ...)
list_of_folder_names_load = natsortfiles(list_of_folder_names_load);

%% Get save location
% Define main folder
start_path = fullfile('C:\Users\,,,\StudyDir\');

% Confirm or change main folder
top_level_folder = uigetdir(start_path);
if top_level_folder == 0
	return;
end;

% Get subfolder list
all_sub_folders = genpath(top_level_folder);

% Parse into a cell array.
for i = 1:size(all_sub_folders)

    remain = all_sub_folders;
    list_of_folder_names2save = {};
        while true
            [single_sub_folder, remain] = strtok(remain, ';');
            
            if isempty(single_sub_folder)
               break;
            end;
            
            list_of_folder_names2save = [list_of_folder_names2save single_sub_folder];
        end;
        
    number_of_folders = length(list_of_folder_names2save);
end;

% Sort the folders (subj1, subj2, ...)
list_of_folder_names2save = natsortfiles(list_of_folder_names2save);

%Initialize vector to save info about retained variance after ICA cleaning
subject_variance = cell(46, 2);
%% Steps 2 & 3: Pre-processing
%Start at ppi = 46; this is a bit annoying, one needs to look at their
%list_of_folder_names_load variable to see what the index is for their
%subject 1, condition 1.
for ppi = 46:length(list_of_folder_names_load)
    
  fold = dir(fullfile(list_of_folder_names_load{ppi},'*.set'));
    
% Import the specific participant and experimental condition
  for cndi = 1: length(fold);

  EEG = pop_loadset([fold(1).folder '/' fold(cndi).name]);
  EEG = eeg_checkset( EEG );
  
  %Adjust channel names to standard, and create Cz for re-referencing at
  %later time
  EEG=pop_chanedit(EEG, 'lookup','C:\Users\t\Documents\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp',...
    'changefield',{1 'labels' 'Fp1'},'changefield',{2 'labels' 'Fpz'},'changefield',{3 'labels' 'Fp2'},'changefield',...
    {4 'labels' 'F7'},'changefield',{5 'labels' 'F3'},'changefield',{6 'labels' 'Fz'},'changefield',{7 'labels' 'F4'},...
    'changefield',{8 'labels' 'F8'},'changefield',{9 'labels' 'T7'},'changefield',{10 'labels' 'C3'},'changefield',...
    {11 'labels' 'CPZ'},'changefield',{12 'labels' 'C4'},'changefield',{13 'labels' 'T8'},'changefield',...
    {14 'labels' 'P7'},'changefield',{15 'labels' 'P3'},'changefield',{16 'labels' 'Pz'},'changefield',{17 'labels' 'P4'},...
    'changefield',{18 'labels' 'P8'},'changefield',{19 'labels' 'M1'},'changefield',{20 'labels' 'Oz'},'changefield',...
    {21 'labels' 'M2'},'changefield',{22 'labels' 'FC5'},'changefield',{23 'labels' 'FC1'},'changefield',...
    {24 'labels' 'FC2'},'changefield',{25 'labels' 'FC6'},'changefield',{26 'labels' 'TP8'},'changefield',...
    {27 'labels' 'CP5'},'changefield',{28 'labels' 'CP1'},'changefield',{29 'labels' 'CP2'},'changefield',...
    {30 'labels' 'CP6'},'changefield',{31 'labels' 'POZ'},'changefield',{32 'labels' 'AF7'},'changefield',...
    {33 'labels' 'AF3'},'changefield',{34 'labels' 'AF4'},'changefield',{35 'labels' 'AF8'},'changefield',...
    {36 'labels' 'F5'},'changefield',{37 'labels' 'F1'},'changefield',{38 'labels' 'F2'},'changefield',{39 'labels' 'F6'},...
    'changefield',{40 'labels' 'FC3'},'changefield',{41 'labels' 'FCZ'},'changefield',{42 'labels' 'FC4'},...
    'changefield',{43 'labels' 'C5'},'changefield',{44 'labels' 'C1'},'changefield',{45 'labels' 'C2'},...
    'changefield',{46 'labels' 'C6'},'changefield',{47 'labels' 'CP3'},'changefield',{48 'labels' 'CP4'},...
    'changefield',{49 'labels' 'P5'},'changefield',{50 'labels' 'P1'},'changefield',{51 'labels' 'P2'},...
    'changefield',{52 'labels' 'P6'},'changefield',{53 'labels' 'PO5'},'changefield',{54 'labels' 'PO3'},...
    'changefield',{55 'labels' 'PO4'},'changefield',{56 'labels' 'PO6'},'changefield',{57 'labels' 'FT7'},...
    'changefield',{58 'labels' 'FT8'},'changefield',{59 'labels' 'TP7'},'changefield',{60 'labels' 'PULS'},...
    'changefield',{61 'labels' 'ECG'},'changefield',{62 'labels' 'H_eog'},'changefield',{63 'labels' 'SpO2'},...
    'changefield',{64 'labels' 'MKR'},'changefield',{65 'labels' 'BEAT'},'changefield',{66 'labels' 'RESP'},...
    'changefield',{67 'labels' 'V_eog'},'insert',68,'changefield',{68 'labels' 'Cz'},'save',...
    'C:\Users\t\Documents\Research\tVNS_Study\EEG_Physio\ChannelLocs.ced','lookup',...
    'C:\Users\t\Documents\eeglab2020_0\plugins\dipfit\standard_BESA\standard-10-5-cap385.elp');

  %Set Cz as reference here:
   EEG = pop_chanedit(EEG, 'setref',{'68' 'Cz'});
   EEG = eeg_checkset( EEG );
  
  %Remove irrelevant channels
   EEG = pop_select( EEG,'nochannel',{'BEAT' 'MKR' 'SpO2', 'PULS', 'RESP', 'ECG'});
 
  %Filter the data, high-Pass = 1 Hz, low-Pass = 80
   EEG = pop_eegfiltnew(EEG, 'locutoff',1,'plotfreqz',0);
   EEG = pop_eegfiltnew(EEG, 'hicutoff',80,'plotfreqz',0); 
   
  %Downsample the data from 1024Hz to 256Hz
   EEG = pop_resample( EEG, 256);
   
   OriginalEEG = EEG; 

    EEG = pop_cleanline(EEG, 'bandwidth',2,'chanlist', [1:EEG.nbchan] ,'computepower',0,'legacy',0,...
        'linefreqs', [25, 50, 75] ,'normSpectrum',0,'p',0.05,'pad',2,'plotfigures',0,'scanforlines',...
        1,'sigtype','Channels','taperbandwidth',2,'tau',100,'verb',1,'winsize',4,'winstep',1);
        EEG = eeg_checkset( EEG );
    

 % Use clean_rawdata
    EEG = pop_clean_rawdata(EEG, 'FlatlineCriterion',5,'ChannelCriterion',0.8,...
        'LineNoiseCriterion',4,'Highpass','off','BurstCriterion',20,'WindowCriterion',...
        0.25,'BurstRejection','on','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] );
        EEG = eeg_checkset( EEG );
  
   %Take out more bad segments from continuous data % This is rather
   %optional given clean_rawdata
    [EEG, selectedregions] = pop_rejcont(EEG, 'elecrange',[1:EEG.nbchan] ,'freqlimit',[1 40] ,'threshold',10,'epochlength',0.5,'contiguous',2,'addlength',1,'taper','hamming')     
        EEG = eeg_checkset( EEG );   

%% Dealing with bad channels

 [EEG_chanrej1, index_nonEEGchanselec1a]  = pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',5,'norm','on','measure','kurt'); 
 [EEG_chanrej1, index_nonEEGchanselec1b] = pop_rejchan(EEG, 'elec',[1:EEG.nbchan] ,'threshold',5,'norm','on','measure','spec','freqrange',[1 128] );
%     
 EEG_chans_remove_a = {EEG.chanlocs(index_nonEEGchanselec1a).labels};
 EEG_chans_remove_b = {EEG.chanlocs(index_nonEEGchanselec1b).labels};
 EEG_chans_remove   = [EEG_chans_remove_a, EEG_chans_remove_b];
%       
 bad_chans = [EEG_chans_remove];
   
% % Keep bipolar chans, mastoids        
 chans_remove = unique(bad_chans);
 nonEEG_chans = {'M1', 'M2'}; %If bipolar not tossed in earlier part, then can include in list here
 bipolar_index_nonEEGchans=find(ismember(chans_remove,nonEEG_chans)); %It seems pop_rejchan looks through all channels even if not specified. 
 chans_remove(bipolar_index_nonEEGchans) = []; 

%% Remove bad channels dataset
EEG = pop_select( EEG,'nochannel', chans_remove);

%Re-reference data. Omitting non-EEG channels
%from re-referencing scheme

% %interp
    EEG = pop_interp(EEG, OriginalEEG.chanlocs, 'spherical');
    EEG = eeg_checkset( EEG );
    ChanLabels = {EEG.chanlocs.labels};
    index_nonEEGchans = find(ismember(ChanLabels, nonEEG_chans));

%reref 2 average
    EEG = pop_reref( EEG, [],'refloc',struct('labels',{'Cz'},'type',...
    {''},'theta',{0},'radius',{0},'X',{5.2047e-15},'Y',{0},'Z',{85},...
    'sph_theta',{0},'sph_phi',{90},'sph_radius',{85},'urchan',{68},...
    'ref',{'Cz'},'datachan',{0},'sph_theta_besa',{0},'sph_phi_besa',{90}),'exclude', index_nonEEGchans );
     EEG = eeg_checkset( EEG );
    
%Run ICA

    g.chanind = 1:EEG.nbchan
    tmpdata = reshape( EEG.data(g.chanind,:,:), length(g.chanind), EEG.pnts*EEG.trials);
    [tmprank2 tmprank3] = getrank2(double(tmpdata(:,1:min(3000, size(tmpdata,2)))));
        
    EEG = pop_runica(EEG, 'extended',1,'interupt','off','pca',tmprank3);
    EEG = eeg_checkset( EEG );
 
%% Step 6: IC artifact rejection
     
   [ALLEEG,EEG,CURRENTSET] = processMARA(ALLEEG,EEG,CURRENTSET);
        mara_logical = 1;
        EEG.reject.gcompreject = zeros(size(EEG.reject.gcompreject));
        EEG.reject.gcompreject(EEG.reject.MARAinfo.posterior_artefactprob > 0.6) = 1;    
        
% Store IC variables and calculate variance of data that will be kept after IC rejection:
   ICs_to_keep = find(EEG.reject.gcompreject == 0);
   ICA_act = EEG.icaact;
   ICA_winv = EEG.icawinv;    
    
% Variance of data to be kept = varianceWav:
   [projWav, varianceData] = compvar(EEG.data, ICA_act, ICA_winv, ICs_to_keep);
   subject_variance(ppi-45, 2) = num2cell(varianceData);
   subject_variance(ppi-45, 1) = {fold(cndi).name};
    
   fsave = strcat(list_of_folder_names2save{ppi}, '\', fold(cndi).name );
   short = fsave(1:end-17);
   fsave = strcat(short, '_MARA_preproc');
   [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',fsave,'setname',[ 'MARA_preproc.set' ],'gui','off');

    
%% BAD COMPONENT REMOVAL
  BAD = find(EEG.reject.gcompreject == 1)          
  EEG = eeg_checkset( EEG );
  EEG = pop_subcomp( EEG,  BAD, 0);
  [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
  EEG = eeg_checkset( EEG );
  
   
  fsave = strcat(list_of_folder_names2save{ppi}, '\', fold(cndi).name );
  short = fsave(1:end-17);
  fsave = strcat(short, '_MARA_cleaned');
  [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',fsave,'setname',[ 'MARA_preproc.set' ],'gui','off');
          
%% Step 6: EPOCHING 
           
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 )         
     EEG = pop_epoch( EEG, {  '4' '5'  }, [-0.2 0.8]); %be sure to define your event names. Here they are '4' and '5'
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'gui','off'); 
     EEG = eeg_checkset( EEG );
      
%Save the EEG file on the disk
    fsave = strcat(list_of_folder_names2save{ppi}, '/', fold(cndi).name );
    short = fsave(1:end-17);
    fsave = strcat(short, '_MARA_hep');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',fsave,'setname',[ 'hep.set' ],'gui','off');
    [ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
     
STUDY = []; CURRENTSTUDY = 0; ALLEEG = []; EEG=[]; CURRENTSET=[];
  end
end
   
save('C:\Users\...\studyDir\subject_variance.mat','subject_variance')  

    