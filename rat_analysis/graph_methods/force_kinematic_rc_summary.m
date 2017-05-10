%makes a set of plots to view different components of 
%the force and kinematic recruitment curves - plots all 
%in same figure

clear all; close all; 

%set variables for each run
filedate = '170503'; 
startnum = 1; 
muscle = 'IP'; 

%set paths
path = '/Users/mariajantz/Documents/Work/data/';
kin_path = [path 'kinematics/' filedate '_files/processed/']; 
force_path = [path 'forces/' filedate '_iso/' muscle '_force']; 

%load and filter force data
load(force_path); 
%access the stimulation values 
act_ch = out_struct.act_ch_list;
if out_struct.mode=='mod_amp'
    stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
end

%set filter parameters
cutoff = 500;
[b,a] = butter(4,cutoff/1000);

%filter and get magnitudes and angles between direction vectors
[fdata, allmag, allang, allang2] = forcefilt(out_struct.data, out_struct.calmat, b, a);
mnrange = 2350:2800; 
mnang1 = mean(allang(:, mnrange)');
mnang2 = mean(allang2(:, mnrange)');
force_mnmag = []; 
%average over .1s
for i=1:size(allmag, 1)
    force_mnmag(i) = mean(allmag(i, mnrange)); 
end
%then plot each of those vectors, kind of on top of each other?
figure; 
subplot(3, 3, 1);
plot(stim_vals, force_mnmag, '-d', 'LineWidth', 3, 'MarkerSize', 5);
fig_prefs(gca, stim_vals);
title('Force Mag'); 
subplot(3, 3, 2); hold on; 
title('Force \Theta'); 
plot(stim_vals, rad2deg(mnang1), 'linewidth', 2); 
plot(stim_vals, rad2deg(mnang2), 'linewidth', 2); 
fig_prefs(gca, stim_vals); 
hold off; 
%normalize all of the force magnitude values and plot
subplot(3, 3, 3); hold on; 
title('Force XYZ'); 
plot(stim_vals, cell2mat(cellfun(@(x) mean(x(mnrange, 1)), fdata, 'UniformOutput', 0))); 
plot(stim_vals, cell2mat(cellfun(@(x) mean(x(mnrange, 2)), fdata, 'UniformOutput', 0))); 
plot(stim_vals, cell2mat(cellfun(@(x) mean(x(mnrange, 3)), fdata, 'UniformOutput', 0))); 
fig_prefs(gca, stim_vals); 


%kinematic values: find peaks
%filter the vicon data and calculate acceleration - as many files as there
%are in the list of currents
ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};
tdmName = ''; tdmMks = [];

cutoff=50;

mnacc = 1:length(stim_vals); 
pkvels = 1:length(stim_vals); 
traceacc = {}; 
for i=1:length(stim_vals)
    %read in the kinematics file
    load([kin_path filedate '_' num2str(i+startnum-1, '%02d') '_rat.mat']); 
    
    %that returns a struct named "rat"
    %import every marker on the rat (oh boy)
    %data is unfiltered version, data2 is filtered version
    data.x = cell2mat(cellfun(@(x) rat.(x)(:, 1), ratMks, 'UniformOutput', 0));
    data.y = cell2mat(cellfun(@(x) rat.(x)(:, 2), ratMks, 'UniformOutput', 0));
    data.z = cell2mat(cellfun(@(x) rat.(x)(:, 3), ratMks, 'UniformOutput', 0));
    figure(1); plot(data.x(:, 11));
    
    [traceacc{i}, mnacc(i), pkvels(i)] = accfilt(data, cutoff);     
end

%TODO: update the accfilt function to return the individual 
%xyz vals, not just the magnitude. Also, joint angles. 


