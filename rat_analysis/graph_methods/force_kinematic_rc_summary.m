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

% %coords from stick_fig of the initial point: 
% coords = [13.6505 -47.0104 -8.8521]; 
% trial_force = fdata{11}; 
% trial_vectors = mean(trial_force(mnrange, 1:3));
% figure(8); hold on; 
% color = [18 75 178]/255;
% quiver(coords(1), coords(2), trial_vectors(1)*100, trial_vectors(2)*100, 'MaxHeadSize', 0.5, 'Linewidth', 3, 'Color', 'k');
% axis equal;
% ax = gca; 

%TODO: plot these vectors from origin--> location
%TODO: label and place on ankle of stick figure

%% kinematics
%kinematic values: find peaks
%filter the vicon data and calculate acceleration - as many files as there
%are in the list of currents
ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};
tdmName = ''; tdmMks = [];
ratAng = {'limb', 'hip', 'knee', 'ankle'};

cutoff=8;

mnacc = 1:length(stim_vals);
pkvels = 1:length(stim_vals);
traceacc = {};
vfdata = {};
for i=1:length(stim_vals)
    %read in the kinematics file
    load([kin_path filedate '_' num2str(i+startnum-1, '%02d') '_rat.mat']);
    
    %that returns a struct named "rat"
    %most peaks occur between point 220 and 240
    data.x = cell2mat(cellfun(@(x) rat.(x)(:, 1), ratMks, 'UniformOutput', 0));
    data.y = cell2mat(cellfun(@(x) rat.(x)(:, 2), ratMks, 'UniformOutput', 0));
    data.z = cell2mat(cellfun(@(x) rat.(x)(:, 3), ratMks, 'UniformOutput', 0));
    %add the angles
    data.angles = cell2mat(cellfun(@(x) rat.angles.(x)(:, 1), ratAng, 'UniformOutput', 0));
    
    %figure(2); plot(data.x(:, 11));
    %choose range in which stimulation occurs
    checkrange = 210:255;
    plotrange = 210:255;
    
    [traceacc{i}, mnacc(i), pkvels(i), vfdata{i}] = accfilt2(data, cutoff, checkrange, plotrange);
    
    %TODO: deal with this
    %v_idx(i, :) = (fdata.locs.vpk-3):fdata.locs.vpk;
    
    %figures! families
    %colors = [170, 203, 255; 0, 38, 99];
    colors = [255 192 0; 255 58 25];
    colors2 = [255 58 25; 18 75 178]; %202, 7, 62 red?
    nPt = size(stim_vals,2);
    %ranges = [0 nPt];
    save_folder = [];
    map = [interp1([0 1],colors,linspace(0,1,round(nPt/2)))/255; ...
        interp1([0 1],colors2,linspace(1/round(nPt/2),1,round(nPt/2)-mod(nPt, 2)))/255;];
    plot_color = map(i, :);
    plot_families(fdata{i}, vfdata{i}, plot_color, save_folder);
    
    
    pkacc(i) = vfdata{i}.pks.aval;
    pkaccmn(i) = vfdata{i}.pks.amean;
    %save figure showing velocity, accel for this trace
    trfigpath = [path '../figures/summary/force_kinematic_rc/' filedate '/' muscle];
    figure(77); h(1) = gcf; set(gca, 'FontSize', 20);
    if ~exist([trfigpath '/traces' h(1).Name])
        mkdir([trfigpath '/traces' h(1).Name]);
    end
    fname = [muscle '_' num2str(stim_vals(i), '%0.2f')];
    fname(fname=='.') = '-';
    savefig(h(1), [path '../figures/summary/force_kinematic_rc/' filedate '/' muscle '/traces' h(1).Name '/' fname]);
    saveas(h(1), [path '../figures/summary/force_kinematic_rc/' filedate '/' muscle '/traces' h(1).Name '/' fname], 'epsc');
    if i~=length(stim_vals)
        close([77]);
    end
    close(201);
end

figure(62); 
ax = gca; 
patch([mnrange(1) mnrange(end) mnrange(end) mnrange(1)],...
    sort([ax.YLim ax.YLim]), [.9 .9 .9], 'LineStyle', 'none');
set(ax,'children',flipud(get(gca,'children')))

%do example of peak velocity and acceleration calculation


%TODO: update the accfilt function to return the individual
%xyz vals, not just the magnitude. Also, joint angles.

%deal with pkvel - check correlation
%calculate and check whether pkacc correlates


%calculate traces
%t = cell2mat(cellfun(@(x) mean(x), traceacc, 'UniformOutput', 0));
%t2 = cell2mat(cellfun(@(x) mean(x(2:end)), traceacc, 'UniformOutput', 0));
%t3 = cell2mat(cellfun(@(x) mean(x(1:end-1)), traceacc, 'UniformOutput', 0));

figure(1); subplot(3, 3, 4);
plot(stim_vals, pkaccmn,  '-d', 'LineWidth', 3, 'MarkerSize', 5);
title('Accel Trace');
fig_prefs(gca, stim_vals);

%plot joint angle accel values
%take the vfdata.loc variable, then get and filter the joint angle
%acceleration at all of those points

%get angles from vfdata arrays, use those values at the locs values to
%calculate mean angles (say 3 points before?)
ang_mean = zeros(length(stim_vals), 4);
for i=1:length(vfdata)
    v_idx(i, :) = (vfdata{i}.pks.vloc-3):vfdata{i}.pks.vloc;
    A = vfdata{i}.angles.ddu(v_idx(i, :), :);
    A(any(isnan(A), 2),:)=[];
    ang_mean(i, :) = mean(A);
end
subplot(3, 3, 5); hold on;
plot(stim_vals, ang_mean,  '-d', 'LineWidth', 3, 'MarkerSize', 5);
title('Joint \Theta');
fig_prefs(gca, stim_vals);
legend(ratAng);

%endpoint trace XYZ vals
tr_mean = zeros(length(stim_vals), 3);
for i=1:length(vfdata)
    A = [vfdata{i}.x.ddu(v_idx(i, :), 11) vfdata{i}.y.ddu(v_idx(i, :), 11) vfdata{i}.z.ddu(v_idx(i, :), 11)];
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
title('Normalized Peaks');
%set(gcf, 'Name', '_pks_norm');
plot(stim_vals, (force_mnmag - min(force_mnmag))/(max(force_mnmag)- min(force_mnmag)), '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, (pkvels - min(pkvels))/(max(pkvels)- min(pkvels)), '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, (pkacc - min(pkacc))/(max(pkacc)- min(pkacc)), '-d', 'LineWidth', 3, 'MarkerSize', 5);
plot(stim_vals, (pkaccmn - min(pkaccmn))/(max(pkaccmn)- min(pkaccmn)), '-d', 'LineWidth', 3, 'MarkerSize', 5);
legend({'force', ['pk vel ' num2str(round(corr2(pkvels, force_mnmag), 3))],...
    ['pk acc ' num2str(round(corr2(pkacc, force_mnmag), 3))], ...
    ['mean acc ' num2str(round(corr2(pkaccmn, force_mnmag), 3))]}, 'Location', 'northwest');
fig_prefs(gca, stim_vals);
%plot(stim_vals, (force_mnmag-min(force_mnmag))/(max(force_mnmag)-min(force_mnmag)),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
%plot(stim_vals, (mnacc-min(mnacc))/(max(mnacc)-min(mnacc)),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
%plot(stim_vals, (t-min(t))/(max(t)-min(t)),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
%plot(stim_vals, (t2-min(t2))/(max(t2)-min(t2)),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
%plot(stim_vals, (t3-min(t3))/(max(t3)-min(t3)),  '-d', 'LineWidth', 3, 'MarkerSize', 5);
% leg_info = {'force', ['mnacc ' num2str(round(corr2(mnacc, force_mnmag), 3))], ...
%     ['t ' num2str(round(corr2(t, force_mnmag), 3))], ['t2 ' num2str(round(corr2(t2, force_mnmag), 3))], ...
%     ['t3 ' num2str(round(corr2(t3, force_mnmag), 3))]};
% legend(leg_info);


%% save vals calculated, save peak locations in the data file? or in the
%filtered data file
%stim_vals, ratMks, ratAng, kinematics - vfdata, t, t2, t3, mnacc, vfdata.loc; forces - fdata,
%allmag, allang, allang2, mnang1, mnang2, force_mnmag
usr_in = input('Do you want to save file? (y/n) ', 's');
if usr_in == 'y'
    save([path '../figures/summary/force_kinematic_rc/' muscle '_' filedate '.mat'], ...
        'stim_vals', 'ratMks', 'ratAng', 'vfdata', ... %'t', 't2', 't3', 'mnacc', ...
        'fdata', 'allmag', 'allang', 'allang2', 'mnang1', 'mnang2', 'force_mnmag');
    %savefig([figpath filedate '_' muscle]);
    
    figpath = ['/Users/mariajantz/Documents/Work/figures/summary/force_kinematic_rc/' filedate '/' muscle '/'];
    if ~exist([figpath 'fig/'])
        mkdir([figpath 'fig/']);
        mkdir([figpath 'eps/']);
    end
    %cycle through all the figures
    allfigs = get(0, 'children');
    for f = 1:length(allfigs)
        savefig(allfigs(f), [figpath 'fig/' allfigs(f).Name]);
        saveas(allfigs(f), [figpath 'eps/' allfigs(f).Name], 'epsc');
    end
end

