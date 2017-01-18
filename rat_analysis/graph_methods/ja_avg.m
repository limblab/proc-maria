function ret = ja_avg(rat, swing_times, fig_num, elim_steps)
%Pass in a "rat" struct that includes a field angles, which is itself a
%struct that usually includes limb, hip, knee, and ankle angles. Also pass
%in a cell array of "swing_times" which includes 2-value arrays noting the
%start and end values for each swing phase of the step cycle. Pass in the
%preferred figure number.

%This function averages the swing times and the steps over the entire
%series, splitting each step at the beginning of the swing.

%split the array according to beginning of every swing phase
lbls = fieldnames(rat.angles);
figure(fig_num)
sample_freq = 100;

for i=1:length(lbls)
    subplot(2, 2, i);
    hold on;
    len_sw = zeros(1, length(setdiff(1:length(swing_times), elim_steps))-1);
    all_sw = cell(1, length(setdiff(1:length(swing_times), elim_steps))-1);
    idx = 1; 
    for j=1:length(swing_times)-1
        if ~any(j==elim_steps)
            all_sw{idx} = rat.angles.(lbls{i})(swing_times{j}(1):swing_times{j+1}(1));
            len_sw(idx) = swing_times{j}(2)-swing_times{j}(1);
            idx = idx + 1; 
        end
    end
    
    ds = dnsamp(all_sw);
    xvals = 1/sample_freq:1/sample_freq:size(ds, 2)/sample_freq;
    
    plot(xvals, mean(ds, 'omitnan'), 'linewidth', 2);
    ax = gca;
    x_rect = [0 mean(len_sw)/sample_freq mean(len_sw)/sample_freq 0];
    y_rect = [ax.YLim(1) ax.YLim(1) ax.YLim(2) ax.YLim(2)];
    z_rect = -.01*ones(1, 4);
    patch(x_rect, y_rect, z_rect, [.9 .9 .9], 'EdgeColor', 'none')
    ylabel([lbls(i) '(degrees)']);
    xlabel('Time (s)');
end