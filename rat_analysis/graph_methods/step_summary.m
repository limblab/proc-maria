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
plot(rat.toe(:, 1)-rat.hip_bottom(:, 1), rat.toe(:, 2)-rat.hip_bottom(:, 2))

%on that graph, plot the high/low and front/back points (for height and length)
%deal with step splitting somehow??? um. drat. okay here goes. 

%find the peaks, then pick the ten highest, invert, and pick ten lowest -
%those are the high/low and front/back points in the steps.
%Note: "front" goes negatively on the x axis
figure; findpeaks(rat.toe(:, 1), 'SortStr', 'descend', 'MinPeakDistance', 80)
title('Back peaks'); 
[b_pks, b_locs] = findpeaks(rat.toe(:, 1), 'SortStr', 'descend', 'MinPeakDistance', 80);
inv_arr = max(rat.toe(:, 1))*1.01 - rat.toe(:, 1); 
figure; findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 80)
title('Forward peaks'); 
[~, f_locs] = findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 80);
f_pks = rat.toe(f_locs, 1); 

%front and back peak locations are also a good way to denote swing and
%stance phases - swing starts at the back and goes forward - so pick the
%top ten and then sort them 
sw_idx = [sort(f_locs(1:11)) sort(b_locs(1:11))];

%TODO: um. figure out which section to limit the high values to. and low
%values while i'm at it? not sure if i can do this broadly for all datasets
%but it shouldn't be at the back of the step. so maybe eliminate all points
%within a certain fraction of the step from the back of the step. but I
%don't want to eliminate things that lift up from the back of the step,
%right? huh. maybe deal with that special case if it comes up but for the
%moments I don't need to deal with it I think. how to limit those peaks??

%choose indices to exclude when determining high peaks - otherwise the back
%swing of the foot gets included
vals = []; 
dist = 50;
for i = 1:size(sw_idx, 1)-1
    diffval = sw_idx(i, 2)-sw_idx(i+1, 1); 
    vals = [vals sw_idx(i+1, 1)-diffval/2:sw_idx(i+1, 1)]; 
    %vals = [vals sw_idx(i, 2)-dist:sw_idx(i, 2)+dist]; 
end
idx = setdiff(1:size(rat.toe, 1), vals); 
temp = rat.toe(:, 2); 
temp(idx) = NaN; 

figure; findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', 20)
title('High peaks'); 
[h_pks, h_locs] = findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', 20);
inv_arr = max(rat.toe(:, 2))*1.01 - rat.toe(:, 2); 
figure; findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 20)
title('Low peaks'); 
[~, l_locs] = findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 20);
l_pks = rat.toe(l_locs, 2); 



hl_vals = [sort(h_locs(1:11)) sort(l_locs(1:11))];
%check this by plotting each full step, splitting the parts
figure(100); 
for step=1:size(sw_idx, 1)-1
    subplot(5, 2, step); hold on;
    %plot stance
    plot(rat.toe(sw_idx(step, 1):sw_idx(step, 2), 1), rat.toe(sw_idx(step, 1):sw_idx(step, 2), 2), 'color', 'b'); 
    %plot starting point
    plot(rat.toe(sw_idx(step, 1), 1), rat.toe(sw_idx(step, 1), 2), 'o'); 
    %plot high and low points
    plot(rat.toe(hl_vals(step, 1), 1), rat.toe(hl_vals(step, 1), 2), 'o'); 
    plot(rat.toe(hl_vals(step, 2), 1), rat.toe(hl_vals(step, 2), 2), 'o'); 
    %plot swing
    plot(rat.toe(sw_idx(step, 2):sw_idx(step+1, 1), 1), rat.toe(sw_idx(step, 2):sw_idx(step+1, 1), 2), 'color', 'r'); 
end


%calculate and draw average trace of trial minus 1st and last step
%


%save some shit down here probs