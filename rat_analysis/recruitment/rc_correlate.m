
filedate = '170126';
path = '/Users/mariajantz/Documents/Work/data/kinematics/rc_data/'; 
muscle = 'VL'; 
load([path muscle '_' filedate])


figure; hold on; 
plot(stim_vals, t2,  '-d', 'LineWidth', 3, 'MarkerSize', 5); 
plot(stim_vals, force_mnmag, '-d', 'LineWidth', 3, 'MarkerSize', 5);
%graph preferences
box off; 
xlabel('Stimulation (mA)'); 
set(gca, 'FontSize', 24); 
set(gca, 'XTick', stim_vals); 
set(gca, 'TickDir', 'out'); 
%adjust x digits
ax = gca;
cur_xlabel = cell2mat(cellfun(@(x) str2num(x), ax.XTickLabel, 'UniformOutput', 0));
ax.XTickLabel = round(cur_xlabel, 1);
title(['corr = ' num2str(corr2(t2, force_mnmag))]); 

