%Copyright Tasha Poppa
%Sorts R-wave events according to whether they occur during inspiration or
%expiration. Used BreathMetrics toolbox to extract respiratory phase info,
%but can pool all events in later analyses.

clear
subfolder = 's001';

path = sprintf('/Users/Tasha/Desktop/Research/Ghent/tVNS/Data/%s/Physio_analyses/', subfolder)
cd(path)

ECG_Data = dir('Peaks_ECG_corrected*.mat');

INEXP = dir('INSPEXP_RESP*.mat');

 for Cond =1:length(ECG_Data) 
          
     loadName = ECG_Data(Cond).name;
     dataName = loadName(1:end-4);
     
     ECG= load(loadName);
     
     loadName2 = INEXP(Cond).name;
     dataName2 = loadName2(14:end-4);
     
     RESP= load(loadName2);
     
INSP_beats = [];
EXP_beats = [];
 
for j = 1 : length(ECG.RRLocs)
    for i = 1:length(RESP.InspExpEvents_ordered)-1
        if RESP.InspExpEvents_ordered(i,1) == 2 ...
           && ECG.RRLocs(j) >= RESP.InspExpEvents_ordered(i,2) ...
           && ECG.RRLocs(j) <= RESP.InspExpEvents_ordered(i+1,2);
           EXP_beats(i+1,j) = ECG.RRLocs(j);
        elseif RESP.InspExpEvents_ordered(i,1) == 3 ...
            && ECG.RRLocs(j) >= RESP.InspExpEvents_ordered(i,2) ...
            && ECG.RRLocs(j) <= RESP.InspExpEvents_ordered(i+1,2);
            INSP_beats(i+1,j) = ECG.RRLocs(j);
        end
    end
end

    INSP_beats(INSP_beats==0) = [];
    EXP_beats(EXP_beats==0) = [];

    B = repmat(4, 1, length(EXP_beats));
    C = repmat(5, 1, length(INSP_beats));

    EXP_beat = vertcat(B, EXP_beats);
    EXP_beat = EXP_beat';

    INSP_beat = vertcat(C, INSP_beats);
    INSP_beat = INSP_beat';

    BOTH = vertcat(EXP_beat, INSP_beat);
    Insp_Exp = sortrows(BOTH, 2);

    filename3 = sprintf('Beats_by_Resp_%s.txt',dataName2);

    header = {'Type', 'Latency'};

    csvwrite_with_headers(filename3, Insp_Exp, header);

 end
 
