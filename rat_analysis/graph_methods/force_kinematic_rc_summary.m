%makes a set of plots to view different components of 
%the force and kinematic recruitment curves - plots all 
%in same figure

clear all; close all; 

%set variables for each run
filedate = '170503'; 
startnum = 16; 
muscle = 'GS'; 

%set paths
path = '/Users/mariajantz/Documents/Work/data/';
kin_path = [path 'kinematics/processed/']; 
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
figure(1);
set(gcf, 'Position', [100, 155, 1200, 860]);  
subplot(3, 3, 1);

mnrange = 2350:2800; 

mnang1 = mean(allang(:, mnrange)');
mnang2 = mean(allang2(:, mnrange)');
force_mnmag = []; 
%average over .1s
for i=1:size(allmag, 1)
    force_mnmag(i) = mean(allmag(i, mnrange)); 
end
%then plot each of those vectors, kind of on top of each other?

plot(stim_vals, force_mnmag, '-d', 'LineWidth', 3, 'MarkerSize', 5);
fig_prefs(gca, stim_vals);
title('Force Mag'); 
subplot(3, 3, 2); hold on; 
title('Force \Theta'); 
plot(stim_vals, rad2deg(mnang1),  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
plot(stim_vals, rad2deg(mnang2),  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
fig_prefs(gca, stim_vals); 
hold off; 
%normalize all of the force magnitude values and plot
subplot(3, 3, 3); hold on; 
title('Force XYZ'); 
plot(stim_vals, cell2mat(cellfun(@(x) mean(x(mnrange, 1)), fdata, 'UniformOutput', 0)),  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
plot(stim_vals, cell2mat(cellfun(@(x) mean(x(mnrange, 2)), fdata, 'UniformOutput', 0)),  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
plot(stim_vals, cell2mat(cellfun(@(x) mean(x(mnrange, 3)), fdata, 'UniformOutput', 0)),  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
fig_prefs(gca, stim_vals); 
legend({'x', 'y', 'z'}); 


%kinematic values: find peaks
%filter the vicon data and calculate acceleration - as many files as there
%are in the list of currents
ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};
tdmName = ''; tdmMks = [];
ratAng = {'limb', 'hip', 'knee', 'ankle'};

cutoff=50;

mnacc = 1:length(stim_vals); 
pkvels = 1:length(stim_vals); 
traceacc = {}; 
locs = {};  
vfdata = {}; 
for i=1:length(stim_vals)
    %read in the kinematics file
    load([kin_path filedate '_' num2str(i+startnum-1, '%02d') '_rat.mat']); 
    
    %that returns a struct named "rat"
    %import every marker on the rat (oh boy)
    %data is unfiltered version
    %most peaks occur between point 220 and 240 in the data so only look at that
    %section
    data.x = cell2mat(cellfun(@(x) rat.(x)(200:260, 1), ratMks, 'UniformOutput', 0));
    data.y = cell2mat(cellfun(@(x) rat.(x)(200:260, 2), ratMks, 'UniformOutput', 0));
    data.z = cell2mat(cellfun(@(x) rat.(x)(200:260, 3), ratMks, 'UniformOutput', 0));
    %add the angles
    data.angles = cell2mat(cellfun(@(x) rat.angles.(x)(200:260, 1), ratAng, 'UniformOutput', 0));

    %figure(2); plot(data.x(:, 11));
    
    [locs{i}, traceacc{i}, mnacc(i), pkvels(i), vfdata{i}] = accfilt2(data, cutoff);     
end

%TODO: update the accfilt function to return the individual 
%xyz vals, not just the magnitude. Also, joint angles.

%calculate traces
t = cell2mat(cellfun(@(x) mean(x), traceacc, 'UniformOutput', 0));
t2 = cell2mat(cellfun(@(x) mean(x(2:end)), traceacc, 'UniformOutput', 0));
t3 = cell2mat(cellfun(@(x) mean(x(1:end-1)), traceacc, 'UniformOutput', 0));

figure(1); subplot(3, 3, 4);
plot(stim_vals, t2,  '-d', 'LineWidth', 3, 'MarkerSize', 5);
title('Accel Trace'); 
fig_prefs(gca, stim_vals); 

%plot joint angle accel values
%take the locs variable, then get and filter the joint angle
%acceleration at all of those points

%get angles from vfdata arrays, use those values at the locs values to
%calculate mean angles (say 3 points before?)
ang_mean = zeros(length(stim_vals), 4);
for i=1:length(vfdata)
    A = vfdata{i}.angles.ddu(locs{i}, :); 
    disp(A);
    A(any(isnan(A), 2),:)=[];
    ang_mean(i, :) = mean(A); 
end
subplot(3, 3, 5);
plot(stim_vals, ang_mean,  '-d', 'LineWidth', 3, 'MarkerSize', 5);
title('Joint \Theta'); 
fig_prefs(gca, stim_vals); 
legend(ratAng); 

%endpoint trace XYZ vals
tr_mean = zeros(length(stim_vals), 3);
for i=1:length(vfdata)
    A = [vfdata{i}.x.ddu(locs{i}, 11) vfdata{i}.y.ddu(locs{i}, 11) vfdata{i}.z.ddu(locs{i}, 11)]; 
    disp(A);
    A(any(isnan(A), 2),:)=[];
    tr_mean(i, :) = mean(A); 
end
subplot(3, 3, 6); hold on;
plot(stim_vals, tr_mean,  '-d', 'LineWidth', 3, 'MarkerSize', 5);
title('Endpoint XYZ acc'); 
fig_prefs(gca, stim_vals); 
legend({'x', 'y', 'z'}); 


%normalize and plot endpoint accel - multiple trace options
subplot(3, 3, [7 8 9]); hold on; 
title('Diff traces'); 
plot(stim_vals, force_mnmag/max(force_mnmag),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, mnacc/max(mnacc),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, t/max(t),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, t2/max(t2),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, t3/max(t3),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
fig_prefs(gca, stim_vals); 

leg_info = {'force', ['mnacc ' num2str(round(corr2(mnacc, force_mnmag), 3))], ...
['t ' num2str(round(corr2(t, force_mnmag), 3))], ['t2 ' num2str(round(corr2(t2, force_mnmag), 3))], ...
['t3 ' num2str(round(corr2(t3, force_mnmag), 3))]}; 
legend(leg_info); 

%save vals calculated, save peak locations in the data file? or in the
%filtered data file
%stim_vals, ratMks, ratAng, kinematics - vfdata, t, t2, t3, mnacc, locs; forces - fdata,
%allmag, allang, allang2, mnang1, mnang2, force_mnmag
save([path '../figures/summary/force_kinematic_rc/' muscle '_' filedate '.mat'], ...
    'stim_vals', 'ratMks', 'ratAng', 'vfdata', 't', 't2', 't3', 'mnacc', 'locs', ...
    'fdata', 'allmag', 'allang', 'allang2', 'mnang1', 'mnang2', 'force_mnmag'); 

