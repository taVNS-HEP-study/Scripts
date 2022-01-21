%Extracts physio channels from EEG record, performs ECG Filtering and R-wave Peak Detection

clear all

%For now need to do this for each subject separately... it is important to inspect
%peak detection quality for each dataset, so no looping through all subject folders

cd('...');


[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

rawData = dir('*.edf');


 for subjID = 1:length(rawData) 
%  
    loadName = rawData(subjID).name;
    dataName = loadName(1:end-4);


% Import data.
    EEG = pop_biosig(loadName);

%% Extract ECG channel

index = find(strcmp({EEG.chanlocs.labels}, 'ECG1+')==1)  %for tVNS data
ECG = EEG.data(index,:);

     ECG = double(ECG);
       
% Filter Noise:

samplingrate = 1024;

%Remove lower frequencies (takes care of detrending)
    fresult=fft(ECG); 
    fresult(1 : round(length(fresult)*5/samplingrate)) = 0; 
    fresult(end - round(length(fresult)*5/samplingrate) : end)=0; 
    ECGf  =real(ifft(fresult));

    
%%
%May need to adjust these params depending on your data: MinPeakHeight and MinPeakDistance
%I just make sure get really good quality ECG signals with very high
%amplitude R-waves otherwise you probably need to use a template matching
%method or some other more sophisticated approach.

[RRPeaks,RRLocs] = findpeaks(ECGf,'MinPeakHeight',500,'MinPeakDistance',500); 

t = 1:length(ECGf);
f = figure
hold on
plot(t,ECGf)
plot(RRLocs, ECGf(RRLocs),'rv','MarkerFaceColor','r');

%Not fun, but if necessary... manually add or remove points. If you have to
%do this a lot, above is not the best approach for R-wave peak detection. If
%this method is bad for your dataset, then probably better to use a
%different approach

%Remove Points 
    %RRLocs = RRLocs(RRLocs ~=  119204);

%Add Points
    %RRLocs = [RRLocs,8256];
    %RRLocs = sort(RRLocs);

filename = sprintf('Physio_analyses/RPeaks_%s.txt',dataName);

RR_ECG_corr = sprintf('Physio_analyses/Peaks_ECG_corrected_%s.mat',dataName);

%Save Peaks and corrected ECG data for manual corrections
save(RR_ECG_corr,'RRLocs', 'ECGf');

%Save Event file as ascii txt - Peak latencies in milliseconds
RRLocs = RRLocs'
%RRLocs = RRLocs(2:end-1); %Removes first and last peak-> sometimes these need to be removed since they don't often fall on an actual peak
header = {'Latency'}

csvwrite_with_headers(filename,RRLocs, header);


%% Extract Respiration

index2 = find(strcmp({EEG.chanlocs.labels}, 'R+')==1) 

RESP = EEG.data(index2,:);
       
RESPfname = sprintf('Physio_analyses/RESP_%s.mat',dataName);

%Save Peaks and corrected ECG data for manual corrections
save(RESPfname, 'RESP');

%% Extract PPG

index3 = find(strcmp({EEG.chanlocs.labels}, 'PULS+')==1)
PULSE = EEG.data(index3,:);

PULSE = PULSE*-1;

plot(PULSE)
       
PPGfname = sprintf('Physio_analyses/PPG_%s.mat',dataName);


%Save Peaks and corrected ECG data for manual corrections
save(PPGfname, 'PULSE');



 end

 





