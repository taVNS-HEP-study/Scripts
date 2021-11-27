%% Non-parametric, spatio-temporal cluster-based permutation test (Multiple Comparison Controls)
% Extract spatial values from topoplot.m function
% Compute T-tests for every grid pixel and then generate null-hypothesis clusters
% ideally used with high-density eeg
% Copyright: Lars Benschop & Tasha Poppa

%To run this script, you need:
% 1. 3D matrices of erp timecourses: (subject, channels,
%timepoints) for condition A and condition B
% 2. EEG struct (saved from EEGLAB containing channel positions) 


%% Load in the data
eeglab

load dataA
load dataB

A  = dataA(:, :, :);  %choose range of time points (3rd dimension) if you only want to test within certain time window
B  = dataB(:, :, :);

% Specifiy timing parameters for plotting (actual time in milliseconds, not
% in terms of samples) 
start_time = -100;
end_time   =  300; %arbitrary numbers here, change to what makes sense for your analysis 
time_bins  = size(A,3);
time       = linspace(start_time,end_time,time_bins);

%% Extract electrode-space grid

% Initialize condition A matrix (ppn x gridX x gridY x timepnts)
condition_A = NaN(size(A,1),67,67,size(A,3));

for ppi = 1:size(A,1)
    
    for ti = 1:size(A,3)
        
        [~,condition_A(ppi,:,:,ti)] = topoplot(squeeze(verum(ppi,:,ti)),EEG.chanlocs,'noplot','on');
    
        disp([num2str(round(ti/size(A,3),2)*100) '% of time points for subject ' num2str(ppi)]);
        
    end
end


% Initialize condition B matrix (ppn x gridX x gridY x timepnts)
condition_B = NaN(size(B,1),67,67,size(B,3));

for ppi = 1:size(B,1)
    
    for ti = 1:size(B,3)
        
        [~,condition_B(ppi,:,:,ti)] = topoplot(squeeze(B(ppi,:,ti)),EEG.chanlocs,'noplot','on');
        
        disp([num2str(round(ti/size(B,3),2)*100) '% of time points for subject ' num2str(ppi)]);
        
    end
end


%% non-parametric permutation testing (cluster thresholding for mcc)
% Specify alpha
voxel_pval       = 0.05;
mcc_voxel_pval   = 0.05;
mcc_cluster_pval = 0.05;

% Number of permutations
n_perm = 2000;

% Calculate the observed t-scores
t_num   = squeeze( mean(condition_A,1) - mean(condition_B,1) );
t_denom = squeeze( sqrt( (std(condition_A,0,1).^2) ./ size(condition_A,1) + (std(condition_B,0,1).^2) ./ size(condition_B,1) ));
t_real  = t_num./t_denom;

% Initialize the permutation matrices
permuted_tvals      = NaN(n_perm,size(t_real,1),size(t_real,2),size(t_real,3));
max_pixel_pvals     = NaN(n_perm,2);
max_clust_info      = NaN(n_perm,1);
max_mass_clust_info = NaN(n_perm,1);

% Concatenate the two conditions and get the ppn size per condition
concat_conditions = cat(1,condition_A,condition_B);
n_cond_A          = size(condition_A,1);
n_cond_B          = size(condition_B,1);

% Loop over the number of permutations
for permi = 1:n_perm
    
    % Shuffle participants and extract the fake conditions
    fake_cond_mapping = randperm(n_cond_A + n_cond_B);
    n_data            = concat_conditions(fake_cond_mapping,:,:,:);
    fake_cond_A       = n_data(1:n_cond_A,:,:,:);
    fake_cond_B       = n_data(n_cond_A+1:end,:,:,:);
    
    % Calculate the permuted t-values
    t_num   = squeeze( mean(fake_cond_A,1) - mean(fake_cond_B,1) );
    t_denom = squeeze( sqrt( (std(fake_cond_A,0,1).^2) ./ size(fake_cond_A,1) + (std(fake_cond_B,0,1).^2) ./ size(fake_cond_B,1) ));
    t_map   = t_num./t_denom;
    
    permuted_tvals(permi,:,:,:) = t_map;
    
    % Extract the most extreme t-values
    max_pixel_pvals(permi,:) = [ min(t_map(:)) max(t_map(:)) ];
    
    % threshold the t-values
    t_map(abs(t_map) < tinv(1-(voxel_pval/2), n_cond_A + n_cond_B - 1)) = 0;
    
    % Extract clusters
    clust_info = bwconncomp(t_map);
    max_clust_info(permi) = max([0 cellfun(@numel,clust_info.PixelIdxList)]);
    mass = NaN(length(clust_info.PixelIdxList),1);
    
    for clusti = 1:length(clust_info.PixelIdxList)
        
        mass(clusti) = sum(t_map(clust_info.PixelIdxList{1,clusti}));

    end
    
    % If no cluster is found assign 0
    try        
     max_mass_clust_info(permi) = max(abs(mass));     
    catch        
        max_mass_clust_info(permi) = 0;
        disp([ 'No cluster for the #' num2str(permi) ' iteration' ]);
    end
    
    disp([num2str(round(permi/n_perm,2)*100) '%']);
    
end

% Cluster mass threshold = 5% most extreme values
cluster_mass_thresh = prctile(max_mass_clust_info,95);

% Plot the cluster distribution
figure; 
histogram(max_mass_clust_info); 
line([cluster_mass_thresh, cluster_mass_thresh], [0,1000]);

clear clust_info;

% Apply cluster based thresholding
t_thresh = t_real;
t_thresh(abs(t_thresh) < tinv(1-(mcc_cluster_pval/2),n_cond_A + n_cond_B - 1)) = 0;

clust_info = bwconncomp(t_thresh);
mass = NaN(length(clust_info.PixelIdxList),1);

for clusti = 1:length(clust_info.PixelIdxList)
    
    mass(clusti) = sum(abs(t_thresh(clust_info.PixelIdxList{1,clusti})));

end

clust2remove = find(abs(mass) < cluster_mass_thresh);

for i = 1:length(clust2remove)
    
    t_thresh(clust_info.PixelIdxList{clust2remove(i)}) = 0;

end

%% Plot the data
figure;
for i = 1:time_bins 
    contourf(t_thresh(:,:,i),40,'linecolor','none');
    title([ 'Time: ' num2str(time(i)) ' Ms' ]);
    pause();
    
end