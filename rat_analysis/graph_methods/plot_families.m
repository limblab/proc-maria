function plot_families(force_data, vicon_data, plot_color, save_dir)
%set save_dir to [] if saving is not desired
%TODO: add save dir

ax_fields = {'x', 'y', 'z'};
%make a figure to do families of:
%filtered force trace
figure(61); set(gcf, 'Name', '_filt_force'); 
for xyz = 1:3
    subplot(3, 1, xyz); hold on;
    plot(force_data(:, xyz), 'Color', plot_color, 'LineWidth', 2);
    title(['Filtered Force ' ax_fields{xyz}]);
end
set(gcf, 'Position', [500 100 1000 900])

figure(62); set(gcf, 'Name', '_filt_forcemag'); 
hold on;
%TODO: plot force magnitude with a window overall
force_mag = sqrt(force_data(:, 1).^2 + force_data(:, 2).^2 + force_data(:, 3).^2);
%set filter parameters
cutoff = 50;
[b,a] = butter(4,cutoff/1000);
filtforcemag = filtfilt(b,a,force_mag); 
plot(filtforcemag, 'Color', plot_color, 'LineWidth', 2); 
title('Force magnitude'); 

%kinematics

figure(77); hold on; plotrange = 220:255;
title('Determining peaks');
set(gcf, 'Name', '_findpeak'); 
plot(plotrange, vicon_data.mag.vel(plotrange), 'linewidth', 2, 'Color', plot_color, 'LineStyle', ':') %magnitude of vel
plot(plotrange, vicon_data.mag.dvel(plotrange), 'linewidth', 2, 'Color', plot_color) %magnitude of accel
ax = gca;
line([vicon_data.pks.vloc vicon_data.pks.vloc], ax.YLim, 'LineStyle','--', 'color', 'k')
line([vicon_data.pks.aloc vicon_data.pks.aloc], ax.YLim, 'LineStyle','--', 'color', 'k')
patch([vicon_data.pks.aloc-1 vicon_data.pks.aloc+1 vicon_data.pks.aloc+1 vicon_data.pks.aloc-1],...
    sort([ax.YLim ax.YLim]), [.9 .9 .9], 'LineStyle', 'none');
legend({'Mag vel', 'Mag acc'}, 'Location', 'northeast');
set(ax,'children',flipud(get(gca,'children')))
hold off;

%raw kinematic trace (x, y)
figure(72); set(gcf, 'Name', '_position_family');
for xyz = 1:3
    h(xyz) = subplot(3, 2, xyz*2-1); hold on;
    plot(vicon_data.(ax_fields{xyz}).u(:, 11), 'Color', plot_color, 'Linewidth', 2)
    title(['Raw Kinematics ' ax_fields{xyz}]);
end
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])

%filtered kinematic trace (x, y)
hold on;
for xyz = 1:3
    h(xyz) = subplot(3, 2, xyz*2); hold on;
    plot(vicon_data.(ax_fields{xyz}).ufilt(:, 11), 'Color', plot_color, 'Linewidth', 2)
    title(['Filtered Kinematics ' ax_fields{xyz}]);
end
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])

figure(73); set(gcf, 'Name', '_vel_family'); 
for xyz = 1:3
    h(xyz) = subplot(3, 2, xyz*2-1); hold on;
    plot(vicon_data.(ax_fields{xyz}).du(:, 11), 'Color', plot_color, 'Linewidth', 2)
    xlim([plotrange(1) plotrange(end)]);
    title(['Raw Velocity ' ax_fields{xyz}]);
end
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])

hold on;
for xyz = 1:3
    h(xyz) = subplot(3, 2, xyz*2); hold on;
    plot(vicon_data.(ax_fields{xyz}).du_filt(:, 11), 'Color', plot_color, 'Linewidth', 2)
    xlim([plotrange(1) plotrange(end)]);
    title(['Filtered Velocity ' ax_fields{xyz}]);
end
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])

%accel trace
figure(74); set(gcf, 'Name', '_accel_family');
for xyz = 1:3
    h(xyz) = subplot(3, 2, xyz*2-1); hold on;
    plot(vicon_data.(ax_fields{xyz}).ddu(:, 11), 'Color', plot_color, 'Linewidth', 2)
    xlim([plotrange(1) plotrange(end)]);
    title(['Raw Accel ' ax_fields{xyz}]);
end

hold on;
for xyz = 1:3
    h(xyz) = subplot(3, 2, xyz*2); hold on;
    plot(vicon_data.(ax_fields{xyz}).ddu_filt(:, 11), 'Color', plot_color, 'Linewidth', 2)
    xlim([plotrange(1) plotrange(end)]);
    title(['Filtered Accel ' ax_fields{xyz}]);
end
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])

%plot the magnitude of velocity and of acceleration, with and
%without filter
clear('h');
figure(75); set(gcf, 'Name', '_vel_mag'); 
h(1) = subplot(2, 1, 1); hold on;
plot(vicon_data.mag.vel, 'Color', plot_color, 'Linewidth', 2);
xlim([plotrange(1) plotrange(end)]);
title('Speed Mag');

h(2) = subplot(2, 1, 2); hold on;
plot(vicon_data.mag.vel_filt, 'Color', plot_color, 'Linewidth', 2);
title('Filt Speed Mag');
xlim([plotrange(1) plotrange(end)]);
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])

figure(76); set(gcf, 'Name', '_accel_mag'); 
h(1) = subplot(2, 1, 1); hold on;
plot(vicon_data.mag.acc, 'Color', plot_color, 'Linewidth', 2);
xlim([plotrange(1) plotrange(end)]);
title('Accel Mag');

h(2) = subplot(2, 1, 2); hold on;
plot(vicon_data.mag.acc_filt, 'Color', plot_color, 'Linewidth', 2);
xlim([plotrange(1) plotrange(end)]);
title('Filt Accel Mag');
linkaxes(h, 'x');
set(gcf, 'Position', [500 100 1000 900])


%TODO: shift these to be centered on peak velocity. 
centerpt = round(length(plotrange)*.5)+plotrange(1); 
centeridx = centerpt-vicon_data.pks.vloc; 
%disp(['centerpt: ' num2str(centerpt) ' centeridx: ' num2str(centeridx)]); 
if centeridx<0
    st_idx = abs(centeridx); 
    xidx = 0; 
elseif centeridx==0
    st_idx = 1; 
    xidx = 1; 
else
    st_idx = 0; 
    xidx = centeridx; 
end
%disp(['xidx: ' num2str(xidx) ' stidx: ' num2str(st_idx)]);
figure(78); set(gcf, 'Name', '_speed_family'); 
h(1) = subplot(2, 1, 1); hold on; 
xvals = 1:length(vicon_data.mag.vel); 
plot(xvals(xidx+1:end-st_idx), vicon_data.mag.vel(st_idx+1:end-xidx), 'Color', plot_color, 'Linewidth', 2); 
xlim([plotrange(1) plotrange(end)]);
ax= gca; 
%line([centerpt centerpt], [0 ax.YLim(2)], 'color', 'k'); 
title('Speed family'); 
h(1) = subplot(2, 1, 2); hold on; 
plot(xvals(xidx+1:end-st_idx), [vicon_data.mag.dvel(st_idx+1:end-xidx); 0], 'Color', plot_color, 'Linewidth', 2); 
xlim([plotrange(1) plotrange(end)]);
title('\Delta Speed family'); 


% 
% %Spline version
% figure(78); hold on; 
% set(gcf, 'Name', '_findpeaks_spline');
% interp_seg = .25; 
% plot(1:.25:size(vicon_data.mag.acc, 1),vicon_data.mag.acc_spline, 'linewidth', 2);
% plot(1:.25:size(vicon_data.mag.vel, 1), vicon_data.mag.vel_spline, 'linewidth', 2);
% plot(plotrange, vicon_data.mag.acc(plotrange), 'o', 'linewidth', 3) %magnitude of accel
% plot(plotrange, vicon_data.mag.vel(plotrange), 'o', 'linewidth', 3) %magnitude of accel
% legend({'Mag vel', 'Vel spline', 'Mag acc', 'Acc Spline'}, 'Location', 'northwest');
% xlim([plotrange(1) plotrange(end)]);
% line([vicon_data.pks.spl_vloc vicon_data.pks.spl_vloc]*interp_seg + .75, ax.YLim, 'LineStyle','--', 'color', 'k')
% line([vicon_data.pks.spl_aloc vicon_data.pks.spl_aloc]*interp_seg + .75, ax.YLim, 'LineStyle','--', 'color', 'k')
% 

end
