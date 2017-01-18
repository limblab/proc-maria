function ret = traj_trace(rat, swing_times, fig_num, elim_steps)
%Pass in a "rat" struct that includes a field angles, which is itself a
%struct that usually includes limb, hip, knee, and ankle angles. Also pass
%in a cell array of "swing_times" which includes 2-value arrays noting the
%start and end values for each swing phase of the step cycle. Pass in the
%preferred figure number. Pass indices of steps to ignore.

%This function overlays the trajectories of several steps on top of each
%other.

figure(fig_num);
track_marker = rat.toe;

if ~isempty(swing_times)
    x_val = track_marker(:, 1);
    y_val = track_marker(:, 2);
    if ~isempty(elim_steps)
        %sort the steps, eliminate backward so indices of earlier values
        %don't change
        elim_steps = sort(elim_steps, 'descend');
        for i=1:length(elim_steps)
            idc = swing_times{elim_steps(i)}(1):swing_times{elim_steps(i)+1}(1);
            x_val(idc) = []; 
            y_val(idc) = []; 
        end
    end
    plot(x_val, y_val);
    xlabel('x');
    ylabel('y');
    
else
    x_val = rat.foot_mid(:, 1);
    y_val = rat.foot_mid(:, 2);
    plot(x_val, y_val); %not separating into swing and stance so...
    xlabel('x');
    ylabel('y');
end

box off;
set(gca,'TickDir','out')

end