clear all; close all;
%define necessary import variables
filedate = '170715';
filenum = [116 119, 120, 121];
sample_freq = 100; %give this value in Hz
filepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed/';

for f=filenum
    load([filepath filedate '_' num2str(f, '%02d') '_rat']);
    
    if ~isfield(rat, 'swing_times')
        disp('Error: no swing times included in this rat file');119:122
        %calculate means and std dev from swing time value
    else
        swing_times = rat.swing_times; 
        xvals = rat.toe(:, 1)-rat.hip_bottom(:, 1);
        yvals = rat.toe(:, 2)-rat.hip_bottom(:, 2);
        
        steps = {};
        angles = {};
        if length(swing_times)>0
            for i=2:length(swing_times)-1
                steps{i-1} = rat.toe(swing_times{i}:swing_times{i+1}, 1:2);
                angles{i-1} = [rat.angles.hip(swing_times{i}:swing_times{i+1}), ...
                    rat.angles.knee(swing_times{i}:swing_times{i+1}), ...
                    rat.angles.ankle(swing_times{i}:swing_times{i+1})];
            end
        else
            steps{1} = rat.toe(:, 1:2);
            angles{1} = [rat.angles.hip(:), ...
                rat.angles.knee(:), ...
                rat.angles.ankle(:)];
        end
        
        stepry = [];
        steprx = [];
        for i=1:length(steps)
            %find range of each step
            stepry(i) = range(steps{i}(:, 2));
            steprx(i) = range(steps{i}(:, 1));
            rhip(i) = range(angles{i}(:, 1));
            rknee(i) = range(angles{i}(:, 2));
            rankle(i) = range(angles{i}(:, 3));
        end
        if exist('endpoint_xvals')
            %define vars as something appended to a cell
            endpoint_xvals{end+1} = xvals;
            endpoint_xval_stepranges{end+1} = steprx;
            endpoint_yvals{end+1} = yvals;
            endpoint_yval_stepranges{end+1} = stepry;
            hip_angle_ranges{end+1} = rhip;
            knee_angle_ranges{end+1} = rknee;
            ankle_angle_ranges{end+1} = rankle;
            swing_time_idx{end+1} = swing_times;
        else
            %define vars
            endpoint_xvals = {xvals};
            endpoint_xval_stepranges = {steprx};
            endpoint_yvals = {yvals};
            endpoint_yval_stepranges = {stepry};
            hip_angle_ranges = {rhip};
            knee_angle_ranges = {rknee};
            ankle_angle_ranges = {rankle};
            swing_time_idx = {swing_times};
        end
        figure(101); hold on; 
        %plot(rat.toe(swing_times{2}(1):swing_times{3}(1), 1), rat.toe(swing_times{2}(1):swing_times{3}(1), 2), 'linewidth', 2, 'DisplayName', num2str(f))
        [plot_x, plot_y] = traj_avg(rat, swing_times, 0, []); 
        plot(plot_x, plot_y, 'linewidth', 3); 
    end

end
figure(101); legend({'standard', 'GS', 'IP', 'ST'}); 
set(gca, 'fontsize', 20); 

means = []; 
stds = []; 
for i=1:length(filenum)
    means = [means mean(endpoint_yval_stepranges{i})]; 
    stds = [stds std(endpoint_yval_stepranges{i})]; 
end

figure; hold on;
bar(means, 'FaceColor', [.5 .5 .5]);
errorbar(1:length(means), means, stds, '.', 'color','k', 'linewidth', 2);
set(gca, 'TickDir', 'out'); 
set(gca, 'XTick', []); 
set(gca, 'fontsize', 16); 
ylabel('Step Height (mm)');
set(gca, 'XTick', 1:length(filenum), 'XTickLabel', filenum);


means = []; 
stds = []; 
for i=1:length(filenum)
    means = [means mean(endpoint_xval_stepranges{i})]; 
    stds = [stds std(endpoint_xval_stepranges{i})]; 
end
figure; hold on;
bar(means, 'FaceColor', [.5 .5 .5]);
errorbar(1:length(means), means, stds, '.', 'color','k', 'linewidth', 2);
set(gca, 'TickDir', 'out'); 
set(gca, 'XTick', []); 
set(gca, 'fontsize', 16); 
ylabel('Step Length (mm)');
set(gca, 'XTick', 1:length(filenum), 'XTickLabel', filenum);