cd /Users/mariajantz/Documents/Work/data/kinematics/processed/

%load files
load('161006_stats.mat')
%now combine a bunch of files so I can look at them all at once!!
fnames = {'161006_stats.mat' 'collate_stats.mat'};

%variable names in the files (to combine)
invnames = {'endpoint_xval_stepranges' 'endpoint_xvals' 'endpoint_yval_stepranges' ...
    'endpoint_yvals' 'hip_angle_ranges' 'knee_angle_ranges' 'ankle_angle_ranges' ...
    'swing_time_idx' 'trialname'}; 
outvnames = {'xval_range', 'xval', 'yval_range', 'yval', 'hip_range', 'knee_range', ...
    'ankle_range', 'swing_time', 'tname'}; 
%make these into variable names
invnames = cellfun(@genvarname, invnames, 'UniformOutput', false); 
outvnames = cellfun(@genvarname, outvnames, 'UniformOutput', false); 
%now set every output variable to an empty cell
outvnames = cellfun(@eval, outvnames, 'UniformOutput', false); 

for j=1:length(invnames) %for all of the variables that were in that file
    %concatenate them to the end of the working variables
    eval([outvnames{j} '= [eval(outvnames{j}) eval(invnames{j})];']);
end

for i=1:length(fnames)
    load(fnames{i}); 
    %add the files to the values that already exist
    for j=1:length(invnames) %for all of the variables that were in that file
        %concatenate them to the end of the working variables
        eval([outvnames{j} '= [eval(outvnames{j}) eval(invnames{j})];']); 
    end
end



mnrange = []; 

for i=1:length(xval_range)
    mnrange(i) = mean(xval_range{i}); 
    stds(i) = std(xval_range{i}); 
end

hold on;
bar(mnrange(15:20)); 
errorbar(mnrange(15:20), stds(15:20), '.'); 