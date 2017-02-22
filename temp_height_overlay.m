% get the rat date and import
cd('/Users/mariajantz/Documents/Work/data/kinematics/processed/');
load('161006_stats.mat');
datert = '161006';
a = dir([datert '*']);
rats = cell(size(a, 1), 1);
for i=1:size(a, 1)
    load(a(i).name); %will overwrite previous set of data so append to array
    %assign "rat" struct to an array
    rat.trial = a(i).name;
    rats{i} = rat;
end

% get the rat trial numbers
trnums = [8, 22, 23];
% pick the step number to trace
stepnum = 6;
figure(); hold on;

for t=1:length(trnums)
    %get index of trial (important in case of skipped trials)
    rat_ind = cellfun(@(x) isempty(strfind(x.trial, [datert '_' num2str(trnums(t), '%02d')])), rats, 'UniformOutput', false);
    sw_time_ind = cellfun(@(x) isempty(strfind(x, [datert '_' num2str(trnums(t), '%02d')])), trialname, 'UniformOutput', false);
    idx(t, :) = [find([rat_ind{:}] == 0) find([sw_time_ind{:}] == 0)];
    
    %now use that index to get the correct data, for the correct steps
    rat = rats{idx(t, 1)};
    swing_set = swing_time_idx{idx(t, 2)}{stepnum}(1):swing_time_idx{idx(t, 2)}{stepnum+1}(1);
    
    %track the correct values
    track_marker = rat.toe;
    xzero = rat.hip_bottom(:, 1); 
    yzero = rat.hip_bottom(:, 2);
    xzero = xzero(1); 
    yzero = yzero(1); 
    xvals = track_marker(:, 1)-xzero;
    yvals = track_marker(:, 2)-yzero;
    
    %now plot
    plot(xvals(swing_set), yvals(swing_set), 'linewidth', 4);

end

    axis equal;
    ax = gca;
    ax.XLim = [-20 40];
    ax.YLim = [-90 -40];
    %TODO: set YLim
    ylabel('Y (mm)');
    xlabel('X (mm)');
    set(ax, 'fontsize', 24);
    set(gca,'TickDir','out')
    
    legend({'100%', '120%', '140%'}); 


