function ret = ja_time(rat, swing_times, fig_num)
%Pass in a "rat" struct that includes a field angles, which is itself a
%struct that usually includes limb, hip, knee, and ankle angles. Also pass
%in a cell array of "swing_times" which includes 2-value arrays noting the
%start and end values for each swing phase of the step cycle. Pass in the
%preferred figure number.

lbls = fieldnames(rat.angles);
figure(fig_num);

for i=1:length(lbls)
    subplot(length(lbls), 1, i);
    plot(rat.angles.(lbls{i}), '.');
    ylabel([lbls(i) '(degrees)']);
    %set(gca, 'XTick', [])
end
%xlabel('Time (s)');
if ~isempty(swing_times)
    %for first two graphs
    figure(fig_num); hold on;
    num_sub = length(findall(gcf,'type','axes'));
    for j=1:num_sub
        subplot(num_sub, 1, j);
        ax = gca;
        ax.XLim = [round(swing_times{1}(1)-100, -2) swing_times{end}(2)+400];
        h = get(ax,'xtick');
        %set(ax,'xticklabel',(h-ax.XLim(1))/sample_freq); %convert Vicon (100 Hz sample rate) to seconds
        for i=1:length(swing_times)
            x_rect = [swing_times{i}(1) swing_times{i}(2) swing_times{i}(2) swing_times{i}(1)];
            y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
            z_rect = -.01*ones(1, 4);
            patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
        end
    end
end

end