%script to run all the recruitment curve stuff

%get all the file name information
%generalize this
clear all; close all; 
filedate = '170418';
ratName = '170418'; 
startnum = 86; %I need a better way of organizing these files...
muscle = 'BFp'; 
force_name = [muscle '_force'];
foldername = '/Users/mariajantz/Documents/Work/data/';
kin_data = [foldername 'kinematics/' filedate '_files/' ratName];
force_data = [foldername 'forces/' filedate '_iso/' force_name];



%% Get the force data, filter, and plot it
%import the force data (which includes the amt of stim)
%yields something called "out_struct" where the field "data" contains the
%forces
%modulation_channel_multipliers contains the multipliers for base_amp
%check that mode is "mod_amp" and get the correct 
load(force_data);
act_ch = out_struct.act_ch_list;
if out_struct.mode=='mod_amp'
    stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
end

%for each of the trials...
cutoff = 500;
[b,a] = butter(4,cutoff/1000);

%get the magnitudes and angles between direction vectors
[allmag, allang, allang2] = forcefilt(out_struct.data, out_struct.calmat, b, a);

figure(100);
plot(allmag.');
% figure(101);
% plot(allang.');
% figure(102);
% plot(allang2.');
figure(105); 
plot(allmag(10, :)); 
force_mnmag = []; 

%average over .1s
for i=1:size(allmag, 1)
    force_mnmag(i) = mean(allmag(i, 2400:2600)); 
end
figure(106); 
plot(stim_vals, force_mnmag, '-d', 'LineWidth', 3, 'MarkerSize', 5); 

%graph preferences
box off; 
xlabel('Stimulation (mA)'); 
ylabel('Mean force (N)'); 
set(gca, 'FontSize', 24); 
set(gca, 'XTick', stim_vals); 
set(gca, 'TickDir', 'out'); 

pause(1);





%FINALLY, find the best section of the code to use as the point for
%comparison to acceleration



%...not actually sure what I need to plot here but I can play with this a
%bit. Matt also did something with "forcetime" which I should look into.

%in a modular version, enter cutoff, out_struct and get as output the
%currents used to stimulate, the allmag, allang, and allang2


%% now Vicon:

%cycle through to import the vicon data from every file and add to a cell
%array

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
    %read in the Vicon file
%     path = ['/Users/mariajantz/Documents/Work/data/kinematics/' filedate '_files/' ratName num2str(i+startnum-1, '%02d') '.csv'];
%     [events,rat,treadmill] = importViconData(path,[filedate(1:2) '-' filedate(3:4) '-' filedate(5:6)],tdmName,ratMks,tdmMks);
%     
%     for j=1:length(ratMks)
%         rat.(ratMks{j}) = rat.(ratMks{j})/4.7243; %calibrate
%     end
    path = '/Users/mariajantz/Documents/Work/data/kinematics/processed/'; 
    load([path filedate '_' num2str(i+startnum-1, '%02d') '_rat.mat']); 
    
    %that returns a struct named "rat"
    %import every marker on the rat (oh boy)
    %data is unfiltered version, data2 is filtered version
    data.x = cell2mat(cellfun(@(x) rat.(x)(:, 1), ratMks, 'UniformOutput', 0));
    data.y = cell2mat(cellfun(@(x) rat.(x)(:, 2), ratMks, 'UniformOutput', 0));
    data.z = cell2mat(cellfun(@(x) rat.(x)(:, 3), ratMks, 'UniformOutput', 0));
    figure(1); plot(data.x(:, 11));
    
    [traceacc{i}, mnacc(i), pkvels(i)] = accfilt(data, cutoff); 
    
end

t = cell2mat(cellfun(@(x) mean(x), traceacc, 'UniformOutput', 0));
t2 = cell2mat(cellfun(@(x) mean(x(2:end)), traceacc, 'UniformOutput', 0));

figure; hold on; 
plot(mnacc); 
plot(t); 
plot(t2); 

figure; 
plot(stim_vals, t2,  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
%graph preferences
box off; 
xlabel('Stimulation (mA)'); 
ylabel('Mean acceleration (mm/s^2)'); 
set(gca, 'FontSize', 24); 
set(gca, 'XTick', stim_vals); 
set(gca, 'TickDir', 'out'); 

%% Somehow or other I should probably look at direction of force/acceleration


%% Save the stimulation values and the corresponding force/acceleration

path = '/Users/mariajantz/Documents/Work/data/kinematics/rc_data/'; 
save([path muscle '_' filedate], 'stim_vals', 't', 'mnacc', 't2', 'force_mnmag'); 



%need two modular versions: one with detection of the point that the
%stimulation starts and one where you have new files for each one.
%first (easier) version: cycle through each file
%second (harder) version: detect onset

%QUESTIONS:
% Why the different cutoffs for the two filters/reduce to basically same
% thing? (50/100, 499.99/1000)
% Why is your data using temp(:, 8:13) when each of my out_struct.data{x}
% only contain 11 columns? What are each of the columns?
% How to plot the force stuff (just pick a point in time??)
% Is Vicon triggering one extra time at the end?
% Filtering: fig 1 and 2 don't look that different to me, what's going on?
% Also, I may need to recalibrate this and I think I forget how
% Unrelated, but: why is my error on Vicon so high right now? (try fixing
% wand)