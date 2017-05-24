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

%choose indices to exclude when determining high peaks - otherwise the back
%swing of the foot gets included
vals = []; 

for i = 1:size(sw_idx, 1)-1
    diffval = round((sw_idx(i+1, 1)-sw_idx(i, 2))/3, 0); 
    vals = [vals sw_idx(i+1, 1)-diffval:sw_idx(i+1, 1)]; 
    %vals = [vals sw_idx(i, 2)-dist:sw_idx(i, 2)+dist]; 
end
idx = setdiff(1:size(rat.toe, 1), vals); 
temp = rat.toe(:, 2); 
temp(idx) = rat.toe(1, 2)-100; 

figure; findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', 20)
title('High peaks'); 
[h_pks, h_locs] = findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', 20);
inv_arr = max(rat.toe(:, 2))*1.01 - rat.toe(:, 2); 
figure; findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 20)
title('Low peaks'); 
[~, l_locs] = findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', 20);
l_pks = rat.toe(l_locs, 2); 


hl_vals = [[sort(h_locs(1:10)); 0] sort(l_locs(1:11))];

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
%calculate avg high and low points, and avg front and back points
steps = 2:size(sw_idx, 1)-1
fr = mean(rat.toe(sw_idx(steps, 1)))
bk = mean(rat.toe(sw_idx(steps, 2)))
hi = mean(rat.toe(hl_vals(steps, 1)))
lo = mean(rat.toe(hl_vals(steps, 2)))


%save some shit down here probs