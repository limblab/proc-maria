%stick figure with force arrows

%this is hardcoded using ST from 4-18 (trials 74-85)
%plot stick figure, single frame 200, from late trial
clear all;

filedates = {'170418'};
filenums = 74;

%load the summary info
savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';
load([savepath filename]);
%[s_fdate, s_idx] = sort(filedate);

%load correct file
for f=1:length(filenums)
    
    fnum = filenums(f);
    fdate = filedates{1};
    
    %find indices in the file for filedates, filenums
    locs = strfind(filedate, fdate);
    idx = find(~cellfun(@isempty,locs));
    fidx = max(find([filenum{idx}]==fnum)); %assume the better processing happened later if there's a double
    
    %set paths
    path = '/Users/mariajantz/Documents/Work/data/';
    kin_path = [path 'kinematics/processed/' fdate '_' num2str(fnum, '%02d') '_rat.mat'];
    %load data
    load(kin_path);
    
    [row, col] = find(isnan(rat.knee));
    %     temp_knee = rat.knee;
    %     temp_knee(row, 1) = mean(rat.knee([row(1)-1 row(end)+1], 1));
    %     temp_knee(row, 2) = mean(rat.knee([row(1)-1 row(end)+1], 2));
    %     temp_knee(row, 3) = mean(rat.knee([row(1)-1 row(end)+1], 3));
    
    rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.knee       ...
        rat.heel       ...
        rat.foot_mid   ...
        rat.toe };
    
    
        b_ind = 200;
        e_ind = 200;

    t_interval = b_ind:1:e_ind;
    skip_frames = 1; %2 for every other etc
    
    
    rat_mat_orig = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    rat_mat = cellfun(@(array) array(t_interval, :), rat_mat_orig, 'UniformOutput', false);
    rat_mat_s = cellfun(@(x) x(1:skip_frames:end, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    
    disp(rat_mat_s{5}(1, :))
    
    annotate = false;
    hold_prev_frames = true;
    saving = false;
    
    xlabel('X (mm)');
    ylabel('Y (mm)');
    
    figure;
    [an, footstrike, footoff] = saveGaitMovie(rat_mat_s, rat.f, hold_prev_frames, 'step.avi', saving, annotate);
    ylim([-100 30])
    xlim([-60 70])
    
    %plot trace on top of this
    xvals = rat_mat_orig{end}(:, 1);
    yvals = rat_mat_orig{end}(:, 2);
    zvals = (max(rat_mat_orig{end}(:, 3))+1)*ones(length(xvals), 1);
    
    plot3(xvals, yvals, zvals, 'linewidth', 3, 'color', 'k');
    
    title([fdate ' trial ' num2str(fnum)]);
    set(gca, 'fontsize', 24);
    
    figpath = '/Users/mariajantz/Documents/Work/figures/summary/indiv_steps/';
    savefig([figpath fdate '_' num2str(fnum) '_stickfig']);
    
    
end

%load forces and plot all force arrows
%makes a set of plots to view different components of
%the force and kinematic recruitment curves - plots all
%in same figure

clear all; 

%set variables for each run
filedate = '170418';
startnum = 74;
muscle = 'ST';

%set paths
path = '/Users/mariajantz/Documents/Work/data/';
kin_path = [path 'kinematics/processed/'];
force_path = [path 'forces/' filedate '_iso/' muscle '_force'];


%% force
%load and filter force data
load(force_path);
%access the stimulation values
act_ch = out_struct.act_ch_list;
if out_struct.mode=='mod_amp'
    stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
end

%set filter parameters
cutoff = 50;
[b,a] = butter(4,cutoff/1000);

%filter and get magnitudes and angles between direction vectors
[fdata, allmag, allang, allang2] = forcefilt(out_struct.data, out_struct.calmat, b, a);
figure(1); set(gcf, 'Name', '_sum_fig');
set(gcf, 'Position', [100, 155, 1200, 860]);
subplot(3, 3, 1);

mnrange = 2400:2700; %formerly 2350:2800;

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

%coords from stick_fig of the initial point: 
coords = [13.6505 -47.0104 -8.8521]; 
trial_force = fdata{11}; 
trial_vectors = mean(trial_force(mnrange, 1:3));
figure(8); hold on; 
color = [18 75 178]/255;
quiver(coords(1), coords(2), trial_vectors(1)*100, trial_vectors(2)*100, 'MaxHeadSize', 0.5, 'Linewidth', 3, 'Color', 'k');
axis equal;
ax = gca; 

%TODO: plot these vectors from origin--> location
%TODO: label and place on ankle of stick figure
