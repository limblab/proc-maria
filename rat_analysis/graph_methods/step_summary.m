%step summary graphs
%first import rats to compare
clear all; close all; 

%set variables for each run
filedate = '170418'; 
filenum = 99;

%set paths
path = '/Users/mariajantz/Documents/Work/data/';
kin_path = [path 'kinematics/processed/' filedate '_' num2str(filenum) '_rat.mat']; 
%load data
load(kin_path);

%next draw all traces for a trial, relative to the hip marker at zero
figure(1); hold on;
rel_endpoint = rat.toe-rat.hip_bottom; 
plot(rel_endpoint(:, 1), rel_endpoint(:, 2))

%on that graph, plot the high/low and front/back points (for height and length)
%deal with step splitting somehow??? um. drat. okay here goes. 

%find the peaks, then pick the ten highest, invert, and pick ten lowest -
%those are the high/low and front/back points in the steps.
%Note: "front" goes negatively on the x axis
figure; findpeaks(rel_endpoint(:, 1), 'SortStr', 'descend', 'MinPeakDistance', 80)
title('Back peaks'); 
[b_pks, b_locs] = findpeaks(rel_endpoint(:, 1), 'SortStr', 'descend', 'MinPeakDistance', 80);
inv_arr = max(rel_endpoint(:, 1))*1.01 - rel_endpoint(:, 1); 
figure; findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 80)
title('Forward peaks'); 
[~, f_locs] = findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 80);
f_pks = rel_endpoint(f_locs, 1); 

%front and back peak locations are also a good way to denote swing and
%stance phases - swing starts at the back and goes forward - so pick the
%top ten and then sort them 
sw_idx = [sort(f_locs(1:11)) sort(b_locs(1:11))];

%choose indices to exclude when determining high peaks - otherwise the back
%swing of the foot gets included
vals = []; 

for i = 1:size(sw_idx, 1)-1
    diffval = round((sw_idx(i+1, 1)-sw_idx(i, 2))/3, 0); 
    vals = [vals sw_idx(i+1, 1)-diffval:sw_idx(i+1, 1)]; 
    %vals = [vals sw_idx(i, 2)-dist:sw_idx(i, 2)+dist]; 
end
idx = setdiff(1:size(rel_endpoint, 1), vals); 
temp = rel_endpoint(:, 2); 
temp(idx) = rel_endpoint(1, 2)-100; 

figure; findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', 20)
title('High peaks'); 
[h_pks, h_locs] = findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', 20);
inv_arr = max(rel_endpoint(:, 2))*1.01 - rel_endpoint(:, 2); 
figure; findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 20)
title('Low peaks'); 
[~, l_locs] = findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 20);
l_pks = rel_endpoint(l_locs, 2); 


hl_vals = [[sort(h_locs(1:10)); 0] sort(l_locs(1:11))];

%check this by plotting each full step, splitting the parts
figure(100); 
for step=1:size(sw_idx, 1)-1
    subplot(5, 2, step); hold on;
    %plot stance
    plot(rel_endpoint(sw_idx(step, 1):sw_idx(step, 2), 1), rel_endpoint(sw_idx(step, 1):sw_idx(step, 2), 2), 'color', 'b'); 
    %plot starting point
    plot(rel_endpoint(sw_idx(step, 1), 1), rel_endpoint(sw_idx(step, 1), 2), 'o'); 
    %plot high and low points
    plot(rel_endpoint(hl_vals(step, 1), 1), rel_endpoint(hl_vals(step, 1), 2), 'o'); 
    plot(rel_endpoint(hl_vals(step, 2), 1), rel_endpoint(hl_vals(step, 2), 2), 'o'); 
    %plot swing
    plot(rel_endpoint(sw_idx(step, 2):sw_idx(step+1, 1), 1), rel_endpoint(sw_idx(step, 2):sw_idx(step+1, 1), 2), 'color', 'r'); 
end

%calculate and draw average trace of trial minus 1st and last step
%calculate avg high and low points, and avg front and back points
steps = 2:size(sw_idx, 1)-1
fr = rel_endpoint(sw_idx(steps, 1), 1);
bk = rel_endpoint(sw_idx(steps, 2), 1);
hi = rel_endpoint(hl_vals(steps, 1), 2);
lo = rel_endpoint(hl_vals(steps, 2), 2);
steplen = bk-fr; 
avlen = mean(steplen); 
stepht = hi-lo; 
avht = mean(stepht); 


%save some shit down here probs

%save fr, bk, hi, lo step values so I can make summary figs with mean and
%standard deviation