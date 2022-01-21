%% Load in the data to Brainstorm

% Create an empty protocol in Brainstorm GUI, selecting default anatomy and
% 1 channel file per subject

% Define main folder
start_path = fullfile('C:\Users\tasha\Documents\Research\tVNS_Study');

% Confirm or change main folder
top_level_folder = uigetdir(start_path);
if top_level_folder == 0
	return;
end

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
            end
            
            list_of_folder_names_load = [list_of_folder_names_load single_sub_folder];
        end
        
    number_of_folders = length(list_of_folder_names_load);
end

% Sort the folders (PP1, PP2, ...)
list_of_folder_names_load = natsortfiles(list_of_folder_names_load);

%% Input files

% Dynamically create subject labels and their file locations
subjfold2 = {};
file_dir = {};
%% Load in the data
% Define main folder
start_path = fullfile('C:\Users\tasha\Documents\Research\tVNS_Study');

% Confirm or change main folder
top_level_folder = uigetdir(start_path);
if top_level_folder == 0
	return;
end

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
            end
            
            list_of_folder_names_load = [list_of_folder_names_load single_sub_folder];
        end
        
    number_of_folders = length(list_of_folder_names_load);
end

% Sort the folders (PP1, PP2, ...)
list_of_folder_names_load = natsortfiles(list_of_folder_names_load);

%% Input files

% Dynamically create subject labels and their file locations
subjfold2 = {};
file_dir = {};

% Dynamically create subject labels and their file locations
subjfold2 = {};
file_dir = {};

% = 46
% 46 is idiosyncratic and due to the higher level directories being listed
% whereas we only want the subdirectories "Sham" and "Verum" for each
% subject. Examine the variable "list_of_folder_names_load" to see where
% the subfolder list begins. Certainly someone committed can automate this
% aspect, but worked well enough as is.

for i = 46:number_of_folders
    fold          = dir(fullfile(list_of_folder_names_load{i}, '*MARA_cleaned_alt.set' ));
    subjfold = strcat(list_of_folder_names_load{i});
    subjfold2(i-45) = {strcat(subjfold(64:69), subjfold(70:end),'_TVNS')};
    for w = 1:length(fold)
    file_dir(i-45, w) = {[list_of_folder_names_load{i} '\' fold(w).name]};
    end
end

SubjectNames = subjfold2;
RawFiles     = file_dir;


% Start a new report
bst_report('Start');

for iSubject = 1:length(SubjectNames)
    
    sFiles = [];
    %for q = 1:6
    % Process: Import MEG/EEG: Existing epochs
    sFiles = bst_process('CallProcess', 'process_import_data_raw', sFiles, [], ...
        'subjectname',    SubjectNames{iSubject}, ...
        'datafile',       {RawFiles{ iSubject}, 'EEG-EEGLAB'}, ...
        'channelreplace', 1, ...
        'channelalign',   1, ...
        'evtmode',        'value');
end
%end

% Save and display report
ReportFile = bst_report('Save');
bst_report('Open', ReportFile);
% bst_report('Export', ReportFile, ExportDir);