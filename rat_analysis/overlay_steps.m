clear all; close all;

err_trials = []; %rig this up for removing steps from set
numsteps = 11;

filedate_val = '170715';
trials = [42:49];
ax_check = 1; %1 for length (x), 2 for height (y); 
sumpath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/summary_steps.mat';
load(sumpath);

%get the indices of files
date_idx = find(~cellfun(@isempty, strfind(filedate, filedate_val)));

figure(31); hold on; title('Mean endpoint trace');
figure(32); hold on; title('2nd step trace');
figure(33); hold on; title('9th step trace');


for i=1:length(trials)
    %load a trial
    path = '/Users/mariajantz/Documents/Work/data/';
    kin_path = [path 'kinematics/processed/' filedate_val '_' num2str(trials(i), '%02d') '_rat.mat'];
    load(kin_path);
    rel_endpoint = rat.toe-rat.hip_bottom;
    
    %determine index of the trial in the summary statistics sheet
    tr_idx = find(cell2mat(filenum(date_idx))==trials(i));
    sw_vals = sw_idx{date_idx(tr_idx)};
    
    lvals(i) = mean(extreme_vals{date_idx(tr_idx)}.back(:, 1)-(extreme_vals{date_idx(tr_idx)}.front(:, 1)));
    lstd(i) = std(extreme_vals{date_idx(tr_idx)}.back(:, 1)-(extreme_vals{date_idx(tr_idx)}.front(:, 1)));
    hvals(i) = mean(extreme_vals{date_idx(tr_idx)}.hi(:, 2)-(extreme_vals{date_idx(tr_idx)}.lo(:, 2)));
    hstd(i) = std(extreme_vals{date_idx(tr_idx)}.hi(:, 2)-(extreme_vals{date_idx(tr_idx)}.lo(:, 2)));
    
    %plot the mean of the trial
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
    mn_endpt = [mean(upsamp(trace_x)); mean(upsamp(trace_y)); mean(upsamp(trace_z))];
    
    %if i~=1
    plot(mn_endpt(1, :), mn_endpt(2, :), 'linewidth', 3);
    %end
    
    %?? plot steps otherwise? maybe extremes or something? Second step, 8th
    %step
    figure(32);
    plot(rel_endpoint(sw_vals(2, 1):sw_vals(2+1, 1), 1), rel_endpoint(sw_vals(2, 1):sw_vals(2+1, 1), 2), 'linewidth', 3);
    
    figure(33);
    plot(rel_endpoint(sw_vals(9, 1):sw_vals(9+1, 1), 1), rel_endpoint(sw_vals(9, 1):sw_vals(9+1, 1), 2), 'linewidth', 3);
end

ax_x = [min(rel_endpoint(sw_vals(9, 1):sw_vals(9+1, 1), 1))-10, max(rel_endpoint(sw_vals(9, 1):sw_vals(9+1, 1), 1))+10];
ax_y = [min(rel_endpoint(sw_vals(9, 1):sw_vals(9+1, 1), 2))-10, max(rel_endpoint(sw_vals(9, 1):sw_vals(9+1, 1), 2))+10];

legendinfo = cellstr(num2str(trials', 'trial=%-d'))
figure(31);
xlim(ax_x);
ylim(ax_y);
legend(legendinfo); axis equal
figure(32);
xlim(ax_x);
ylim(ax_y);
legend(legendinfo); axis equal
figure(33);
xlim(ax_x);
ylim(ax_y);
legend(legendinfo); axis equal

%add bar chart
figure(1); hold on;
bar(hvals);
errorbar(1:length(trials), hvals, hstd, '.', 'linewidth', 4)
ax = gca;
ylabel('Y (mm)');
xlabel('Trial');
title(['Height variation ' filedate_val]);
%lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
set(ax, 'XTick', [1:length(trials)]);
set(ax, 'XTickLabel', trials);
set(ax, 'fontsize', 20);
set(gca,'TickDir','out');

%add bar chart
figure(2); hold on;
bar(lvals);
errorbar(1:length(trials), lvals, lstd, '.', 'linewidth', 4)
ax = gca;
ylabel('X (mm)');
xlabel('Trial');
title(['Length variation ' filedate_val]);
%lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
set(ax, 'XTick', [1:length(trials)]);
set(ax, 'XTickLabel', trials);
set(ax, 'fontsize', 20);
set(gca,'TickDir','out');

%% save stuff
savepath = '/Users/mariajantz/Documents/Work/figures/summary/trialsets/'; 
figure(1); 
saveas(gcf, [savepath filedate_val '_' num2str(trials(1), '%02d') 'HeightBar'], 'epsc'); 
figure(2); 
saveas(gcf, [savepath filedate_val '_' num2str(trials(1), '%02d') 'LengthBar'], 'epsc'); 
figure(31); set(gca, 'FontSize', 20); 
saveas(gcf, [savepath filedate_val '_' num2str(trials(1), '%02d') 'Traces'], 'epsc'); 



%% add chart with all length variables
chartall = false; 
if chartall
load('hlvals161006'); 
hm = {hvals}; 
hs = {hstd};
lm = {lvals}; 
ls = {lstd}; 

load('hlvals161116'); 
hm{end+1} = hvals; 
hs{end+1} = hstd;
lm{end+1} = lvals;
ls{end+1} = lstd;

load('hlvals170406'); 
hm{end+1} = hvals; 
hs{end+1} = hstd;
lm{end+1} = lvals;
ls{end+1} = lstd;

%take the mean percent change from the first one in each array
del_l = cellfun(@(x) x/x(1), lm, 'UniformOutput', false)

plot_l = [1]; 
plot_l(2) = mean([del_l{1}(3), del_l{2}(2), del_l{3}(3)]);
s_l = [0]; 
s_l(2) = std([del_l{1}(3), del_l{2}(2), del_l{3}(3)]);

figure; hold on;
bar(plot_l);
errorbar(1:length(s_l), plot_l, s_l, '.', 'linewidth', 4)
ax = gca;
ylabel('X (mm)');
xlabel('VL inc at');
title(['Length variation']);
%lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
set(ax, 'XTick', [1:length(s_l)]);
set(ax, 'XTickLabel', {'none', '20%'});
set(ax, 'fontsize', 20);
set(gca,'TickDir','out');



plot_l = [1]; 
plot_l(2) = mean([del_l{1}(2), del_l{3}(2)]);
plot_l(3) = mean([del_l{1}(3), del_l{3}(3)]);
plot_l(4) = mean([del_l{1}(4), del_l{3}(4)]);
s_l = [0]; 
s_l(2) = std([del_l{1}(2), del_l{3}(2)]);
s_l(3) = std([del_l{1}(3), del_l{3}(3)]);
s_l(4) = std([del_l{1}(4), del_l{3}(4)]);

figure; hold on;
bar(plot_l);
errorbar(1:length(s_l), plot_l, s_l, '.', 'linewidth', 4)
ax = gca;
ylabel('X %');
xlabel('VL inc at');
title(['Length variation']);
%lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
set(ax, 'XTick', [1:length(s_l)]);
set(ax, 'XTickLabel', {'none', '15%', '20%', '25%'});
set(ax, 'fontsize', 20);
set(gca,'TickDir','out');
end