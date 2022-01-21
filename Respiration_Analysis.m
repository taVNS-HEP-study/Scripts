%% Identify respiratory peaks and toughs using BreathMetrics toolbox (https://github.com/zelanolab/breathmetrics)
%  to eventually create respiratory events and EKG events according to respiratory phase
% respiratory phase interactions were not ultimately assessed 
% for the study published in brainstimulation: https://doi.org/10.1016/j.brs.2021.12.004
% But it was an analysis idea initially and it is how the events were defined and
% uploaded in the datasets for preprocessing.

clear all
cd('.../Data/s001/Physio_analyses/');

Data = dir('RESP*.mat');

 for Cond =1:length(Data) 
%  
    loadName = Data(Cond).name;
    dataName = loadName(1:end-4);

    Physio = load(loadName);
    Physio.RESP = double(Physio.RESP);
    Physio.srate = 1024;
    
    respiratoryTrace = Physio.RESP;
    srate = Physio.srate;
    dataType = 'humanAirflow';
    bm = breathmetrics(respiratoryTrace, srate, dataType);
    bm.estimateAllFeatures();
%     fig = bm.plotCompositions('raw');
%     fig = bm.plotFeatures({'extrema','maxflow'});
%     fig = bm.plotCompositions('normalized');
    % fig = bm.plotCompositions('line');
    % bm.launchGUI();
    
    bmfname = sprintf('BM_%s.mat',dataName);
    save(bmfname, 'bm');

    Peak = bm.inhalePeaks';
    Trough = bm.exhaleTroughs';
 
     if length(Peak) > length(Trough) 
      Trough = [Trough; 0];     
        elseif length(Trough) > length(Peak)
             Peak = [Peak; 0];
     end
 
    ExpDur = [Trough - Peak];
    InspDur = [Peak; 0] - [0; Trough];
    InspDur = InspDur(2:end-1);
    InspDur = [5000; InspDur];
    
     I = repmat(2, 1, length(Peak))';
     E = repmat(3, 1, length(Trough))';
     
     InspEvents = [I, Peak, InspDur];
     ExpEvents = [E, Trough, ExpDur];
     InspExpEvents = [InspEvents;ExpEvents];
     InspExpEvents_ordered = sortrows(InspExpEvents, 2);
     InspExpEvents_ordered = (InspExpEvents_ordered(:,1:2));
     
RespAnalysis1 = sprintf('INSP_%s.mat',dataName);
RespAnalysis2 = sprintf('EXP_%s.mat',dataName);
RespAnalysis3 = sprintf('INSPEXP_%s.mat',dataName);

    save(RespAnalysis1, 'InspEvents');
    save(RespAnalysis2, 'ExpEvents');
    save(RespAnalysis3, 'InspExpEvents_ordered');


filename1 = sprintf('INSP_%s.txt',dataName);
filename2 = sprintf('EXP_%s.txt',dataName);
filename3 = sprintf('INSP_EXP_%s.txt',dataName);


header = {'Type', 'Latency','Duration'}

csvwrite_with_headers(filename1,InspEvents, header);
csvwrite_with_headers(filename2,ExpEvents, header);

header = {'Type', 'Latency'}

csvwrite_with_headers(filename3,InspExpEvents_ordered, header);
