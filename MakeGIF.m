%% Make Gif of differences 
% needs time_diff variable from PlotDifferences.m
% t_thresh output from ClusterPermutationTest.m
% and gif.m function (not our function, but not sure who to give credit to)
%Copyright Lars Benschop and Tasha Poppa

% plots point 64. Can run it through dsearchn(time','millisec of interest'); 

c = turbo;
figure;
subplot(1,1,1);
[h] = topoplot(squeeze(time_diff(:,64)),EEG.chanlocs,'electrodes','on','maplimits',[-3.5 3.5],'numcontour',0,'conv','on', 'colormap', c);
h.CData = squeeze(t_thresh(:,:,64));
colorbar
set(gcf,'color','w');

set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.1, 0.24, 0.6, 0.54]);

gif('test.gif','DelayTime',0.3,'frame',gcf); % verum_vs_sham_BL_corr_Lap_manuscript_t_thresh
for i = 1:size(t_thresh, 3) 
    subplot(1,1,1);
    [h] = topoplot(squeeze(time_diff(:,i)),EEG.chanlocs,'electrodes','labels','maplimits',[-3.5 3.5],'numcontour',0,'conv','on', 'colormap', c);
    h.CData = squeeze(t_thresh(:,:,i)); 
   % title('Cluster thresholded map: p<0.05');

   [h3] = suplabel(['A - B (' num2str(round(time(i),1)) ' Ms)'],'t',[0.08 0.08 0.84 0.84]);
    set(h3,'fontsize',14);

    gif;
    
end

