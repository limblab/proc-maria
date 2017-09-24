%height summary for given days

savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';
load([savepath filename]); 

ratpath = '/Users/mariajantz/Documents/Work/data/kinematics/processed/';
%name a day
%list the trial sets in format: {[std, 100%, 120%, 140%, 160%, 180%]}
filedate_val = '170713'; 
trialsets = {61:65, 68:72, 75:79, 82:86, 89:93, 96:100, 103:107, 110:114, 117:121};
%filedate = '170715'; 
%trialsets = {62:66, 69:73, 98:102, 76:80, 113:117, [90 92:95], 127:131, 134:138, 141:145}; 

%for each trial set
%load the trial data
for ts = 1:length(trialsets)
    hpts = []; 
    load([ratpath filedate_val '_' num2str(trialsets{ts}(1)) '_rat.mat']);
    %determine index of the trial in the summary statistics sheet
    date_idx = find(~cellfun(@isempty, strfind(filedate, filedate_val)));
    tr_idx = find(cell2mat(filenum(date_idx))==trialsets{ts}(1));
    sw_vals = sw_idx{date_idx(tr_idx)};
    hi_pts(:, i) = extreme_vals{date_idx(tr_idx)}.hi(:, 2); 
    
    for t = 2:length(trialsets{ts})
        load([ratpath filedate_val '_' num2str(trialsets{ts}(t)) '_rat.mat']);
        
    end
%find the high points in the step from the summary stats
%calculate high point of mean of std
%calculate high point of mean of each other + SD
%subtract every high point from std

end