function [xvals, yvals] = traj_avg(rat, swing_times, fig_num, elim_steps)
%Pass in a "rat" struct that includes a field angles, which is itself a
%struct that usually includes limb, hip, knee, and ankle angles. Also pass
%in a cell array of "swing_times" which includes 2-value arrays noting the
%start and end values for each swing phase of the step cycle. Pass in the
%preferred figure number. Pass indices of steps to ignore.

%This function averages the trajectories of several steps and plots.

%split the array according to beginning of every swing phase


track_marker = rat.toe; 

b_ind = 2;
ind_end = length(swing_times)-1;

%TODO: DEAL WITH ELIM STEPS OPTION!!
len_sw = zeros(1, ind_end-b_ind);
x_step = cell(1, ind_end-b_ind);
y_step = cell(1, ind_end-b_ind);
xvals = track_marker(:, 1);
yvals = track_marker(:, 2);
for j=b_ind:ind_end
    x_step{j-b_ind+1} = xvals(swing_times{j}(1):swing_times{j+1}(1)); %get full step x vals
    y_step{j-b_ind+1} = yvals(swing_times{j}(1):swing_times{j+1}(1)); %get full step y vals
    len_sw(j-b_ind+1) = swing_times{j}(2)-swing_times{j}(1);
end
%interpolate so they're all the same length
dsx = dnsamp(x_step);
dsy = dnsamp(y_step);
x_zero = mean(rat.hip_bottom(:, 1), 'omitnan');
y_zero = mean(rat.hip_bottom(:, 2), 'omitnan');
xvals = mean(dsx, 'omitnan')-x_zero; 
yvals = mean(dsy, 'omitnan')-y_zero;

%first_y = yvals(1);
if fig_num~=0
figure(fig_num); 
grid off;
hold on;

plot(xvals, yvals, 'linewidth', 4); %average together each step

axis equal;
ax = gca;
%ax.XLim = [-5 30];
%ax.YLim = [-75 -55];
%TODO: set YLim
ylabel('Y (mm)');
xlabel('X (mm)');
set(ax, 'fontsize', 24);
set(gca,'TickDir','out')
end

end