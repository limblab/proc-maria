
%% okay, now how would I filter through all the data I have to make a summary height changing figure? 

%define the files to use

filedate_val = '170713';
trials = [103:107]; 
sumpath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/summary_steps.mat';
%get the indices of files
date_idx = find(~cellfun(@isempty, strfind(filedate, filedate_val)));

%start for loop here
%load the rat
path = '/Users/mariajantz/Documents/Work/data/';
    kin_path = [path 'kinematics/processed/' filedate_val '_' num2str(trials(i), '%02d') '_rat.mat'];
    load(kin_path);
%load the swing time indices
%use those indices and interpolation to do average the same as in overlay steps 
%plot the mean of the trial
    sw_vals = sw_idx{date_idx(tr_idx)};
    figure(31);
    %calculate and draw average trace of trial minus 1st and last step
    %make each step the same length (start with second, end before last)
    %average these together - maybe just make into cell array and send to
    %dnsamp function that I use to design the arrays
    trace_x = {};
    trace_y = {};
    trace_z = {};
    for j=2:size(sw_vals, 1)-1
        trace_x{end+1} = rel_endpoint(sw_vals(j, 1):sw_vals(j+1, 1), 1);
        trace_y{end+1} = rel_endpoint(sw_vals(j, 1):sw_vals(j+1, 1), 2);
        trace_z{end+1} = rel_endpoint(sw_vals(j, 1):sw_vals(j+1, 1), 3);
    end
    up_endpt = [upsamp(trace_x); upsamp(trace_y); upsamp(trace_z)];
    mn_endpt = [nanmean(upsamp(trace_x)); nanmean(upsamp(trace_y)); nanmean(upsamp(trace_z))];
    
    plot(mn_endpt(1, :), mn_endpt(2, :), 'linewidth', 3);


%plot the high/low points found before
%options: take the point immediately below the high point and get range between,
%take difference between the high and low point found before, 
%find area inside the path 
%then align them according to % activation (how to do this with 4-6, 11-16, 11-1, 10-6)

%alsoooo find swing times properly for 7-15


