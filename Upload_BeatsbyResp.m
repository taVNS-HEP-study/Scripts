% ------------------------------------------------
%This version may or may not be compatible with current versions of EEGLAB.
%recommend importing events via GUI, then once you've set that up successfully, exporting the resulting code
%using commandline function eegh to get the correct inputs to
%pop_importevent().

clear all
subfolder = 's001';
path = sprintf('/Users/Tasha/Desktop/Research/tVNS_Study/Data/%s/', subfolder)
cd(path)
Path = sprintf('/Users/Tasha/Desktop/Research/tVNS_Study/Data/%s/Events_EEG/', subfolder)

rawData = dir('*.edf');

 for Cond =  1:length(rawData) 
     loadName = rawData(Cond).name;
     dataName = loadName(1:end-4);

% Import data.
    EEG = pop_biosig(loadName);
    EEG = eeg_checkset( EEG );

EventFilePath = sprintf('/Users/Tasha/Desktop/Research/tVNS_Study/Data/%s/Physio_analyses/Beats_by_Resp_%s.txt',   subfolder, dataName);
EEG = pop_importevent( EEG, 'event',EventFilePath,'fields',{ 'type', 'latency'},'skipline',1,'timeunit',0.00097656, 'append', 'no','align',[])
FiltSampData = sprintf('%s_BeatbyBreath.set', dataName);

EEG = pop_saveset( EEG, 'filename',FiltSampData,'filepath',Path);

% %%%%%%%% Uncomment to upload repiratory peak & trough events %%%%%%%%
%   EventFilePath2 = sprintf('/Users/Tasha/Desktop/Research/Ghent/tVNS/Data/%s/Physio_analyses/INSP_EXP_RESP_%s.txt', subfolder, dataName);
%   EEG = pop_importevent( EEG, 'event',EventFilePath2,'fields',{'type', 'latency'},'skipline',1,'timeunit',0.00097656, 'append', 'no','align',[])
%   FiltSampData2 = sprintf('%s_RespiratoryEvents.set', dataName);
%  
%   EEG = pop_saveset( EEG, 'filename',FiltSampData2,'filepath',Path);
% 

 end
 