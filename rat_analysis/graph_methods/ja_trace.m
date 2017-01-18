function ret = ja_trace(rat, swing_times, fig_num, elim_steps)
%Pass in a "rat" struct that includes a field angles, which is itself a
%struct that usually includes limb, hip, knee, and ankle angles. Also pass
%in a cell array of "swing_times" which includes 2-value arrays noting the
%start and end values for each swing phase of the step cycle. Pass in the
%preferred figure number. Pass indices of steps to ignore.

%This function splits each step at the beginning of the swing and overlays
%the joint angles

lbls = fieldnames(rat.angles);
figure(fig_num);

for i=1:length(lbls)
    subplot(2, 2, i);
    hold on;
    len_sw = zeros(1, length(swing_times));
    for j=1:length(swing_times)-1
        if ~any(j==elim_steps)
            plot(rat.angles.(lbls{i})(swing_times{j}(1):swing_times{j+1}(1)));
            len_sw(j) = swing_times{i}(2)-swing_times{i}(1);
        end
    end
    ax = gca;
    x_rect = [0 mean(len_sw) mean(len_sw) 0];
    y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
    z_rect = -.01*ones(1, 4);
    patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
    ylabel([lbls(i) '(degrees)']);
end
xlabel('Time (s)');