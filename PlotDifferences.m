%% Calculate the differences
%Copyright Lars Benschop and Tasha Poppa

%load EEGLAB if not already loaded
eeglab

% Load in the data

load dataA
load dataB

A = dataA
B = dataB

start_time = -199.22;
end_time   = 699.22;
time_bins  = size(A,3);
time       = linspace(start_time,end_time,time_bins);

size_diff = size(A);

time_diff = zeros(size_diff(2:3));

for chani = 1:size_diff(2)
        
    for ti = 1:size_diff(3)
            
        time_diff(chani,ti) = squeeze(mean(A(:,chani,ti),1)) - squeeze(mean(B(:,chani,ti),1));

    end
end

%% Plotting stuff  
%Manually choose what raw voltage differences you want to plot based on timepoints, it will convert to nearest milliseconds. It will be
%plot will be difference of the averaged timepoints
time2plot(1) = dsearchn(time',206); 
time2plot(2) = dsearchn(time',297);

figure;
c = turbo;
topoplot(mean(time_diff(:,time2plot(1):time2plot(2)), 2),EEG.chanlocs,'electrodes','on','maplimits','absmax','numcontour',0);
cbar;
set(gcf,'color','w');
