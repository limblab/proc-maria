function plot_families(force_data, vicon_data)
    ax_fields = {'x', 'y', 'z'};
    %make a figure to do families of:
    %filtered force trace (TODO: maybe move this up?)
    figure(71); 
    for xyz = 1:3
        subplot(3, 1, xyz); hold on;
        plot(force_data(:, xyz));
        title(['Filtered Force ' ax_fields{xyz}]);
    end
    
    %kinematics
    %raw kinematic trace (x, y)
    figure(72); 
    for xyz = 1:3
        h(xyz) = subplot(3, 2, xyz*2-1); hold on;
        plot(vicon_data.(ax_fields{xyz}).u(:, 11))
        title(['Raw Kinematics ' ax_fields{xyz}]);
    end
    linkaxes(h, 'x');
     
    %filtered kinematic trace (x, y) 
    hold on; 
    for xyz = 1:3
        h(xyz) = subplot(3, 2, xyz*2); hold on;
        plot(vicon_data.(ax_fields{xyz}).ufilt(:, 11))
        title(['Filtered Kinematics ' ax_fields{xyz}]);
    end
    linkaxes(h, 'x');
    
    figure(73); 
    for xyz = 1:3
        h(xyz) = subplot(3, 2, xyz*2-1); hold on;
        plot(vicon_data.(ax_fields{xyz}).du(:, 11))
        title(['Raw Velocity ' ax_fields{xyz}]);
    end
    linkaxes(h, 'x');
    
    hold on; 
    for xyz = 1:3
        h(xyz) = subplot(3, 2, xyz*2); hold on;
        plot(vicon_data.(ax_fields{xyz}).du_filt(:, 11))
        title(['Filtered Velocity ' ax_fields{xyz}]);
    end
    linkaxes(h, 'x');
    
    %accel trace
    figure(74); 
    for xyz = 1:3
        h(xyz) = subplot(3, 2, xyz*2-1); hold on;
        plot(vicon_data.(ax_fields{xyz}).ddu(:, 11))
        title(['Raw Accel ' ax_fields{xyz}]);
    end
     
    hold on; 
    for xyz = 1:3
        h(xyz) = subplot(3, 2, xyz*2); hold on;
        plot(vicon_data.(ax_fields{xyz}).ddu_filt(:, 11))
        title(['Filtered Accel ' ax_fields{xyz}]);
    end
    linkaxes(h, 'x');
    
    %plot the magnitude of velocity and of acceleration, with and
    %without filter
    clear('h'); 
    figure(75); 
    h(1) = subplot(2, 1, 1); hold on; 
    plot(vicon_data.mag_vel); 
    title('Velocity Mag'); 
     
    h(2) = subplot(2, 1, 2); hold on; 
    plot(vicon_data.fmag_vel); 
    title('Filt Velocity Mag'); 
    linkaxes(h, 'x');
    
    figure(76); 
    h(1) = subplot(2, 1, 1); hold on; 
    plot(vicon_data.mag_acc); 
    title('Accel Mag'); 
    
    h(2) = subplot(2, 1, 2); hold on; 
    plot(vicon_data.fmag_acc); 
    title('Filt Accel Mag'); 
    linkaxes(h, 'x');
    
end
    