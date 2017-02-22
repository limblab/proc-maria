%adapt current axis values 
%need to adjust the force/accel values by factor of 200 (to deal with
%sampling rate of vicon)

ax = gca; 
cur_xlabel = cell2mat(cellfun(@(x) str2num(x), ax.XTickLabel, 'UniformOutput', 0)); 
cur_ylabel = cell2mat(cellfun(@(x) str2num(x), ax.YTickLabel, 'UniformOutput', 0)); 

% ax.YTickLabel = cur_ylabel*20; %converts to cm
% ylabel('Mean acceleration (cm/s^2)'); 

%adjust x digits
cur_xlabel = cell2mat(cellfun(@(x) str2num(x), ax.XTickLabel, 'UniformOutput', 0));
ax.XTickLabel = round(cur_xlabel, 1)