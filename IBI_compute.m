% For creating interbeat interval files from ECG R-peak location data

clear all

cd('... '); %Where ever your R peak files are located

Data = dir('RPeaks*.txt');


 for subjID =1:length(Data) 
     
     loadName = Data(subjID).name;
     dataName = loadName(1:end-4);
    
        FID=fopen(loadName);
        datacell = textscan(FID, '%f', 'HeaderLines', 1, 'CollectOutput', 1);
        fclose(FID);
    
        EKG = datacell{1};
    
        EKG1 = [0; EKG];
        EKG2 = [EKG; 0];
        IBI = EKG2 - EKG1;
        IBI2 = IBI(1:end-2);
    
     filename1 = sprintf('IBI_%s.txt',dataName);
     header = {'RR'}
% 
csvwrite_with_headers(filename1,IBI2, header);
 end
 


