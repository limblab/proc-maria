%height summary for given days

savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';
load([savepath filename]);

ratpath = '/Users/mariajantz/Documents/Work/data/kinematics/processed/';
%name a day
%list the trial sets in format: {[std, 100%, 120%, 140%, 160%, 180%]}
%filedate_val = '170713';
%trialsets = {61:65, 68:72, 96:100, 103:107, 110:114, 117:121};
filedate_val = '170715';
trialsets = {62:66, 69:73, [90 92:95], 127:131, 134:138, 141:145};

date_idx = find(~cellfun(@isempty, strfind(filedate, filedate_val)));

figure(1); hold on; 
%for each trial set
%load the trial data
for ts = 1:length(trialsets)
    hpts = [];
    load([ratpath filedate_val '_' num2str(trialsets{ts}(1)) '_rat.mat']);
    %determine index of the trial in the summary statistics sheet
    %find the high points in the step from the summary stats
    for t = 1:length(trialsets{ts})
        load([ratpath filedate_val '_' num2str(trialsets{ts}(t)) '_rat.mat']);
        tr_idx = find(cell2mat(filenum(date_idx))==trialsets{ts}(t));
        temploc = date_idx(tr_idx); 
        loc = temploc(end); 
        try
            hi_pts(:, t) = extreme_vals{loc}.hi(:, 2);
        catch
            hi_pts(:, t) = [extreme_vals{loc}.hi(:, 2); NaN];
        end
    end
    
    %TODO: set all 1s to NaN, then do a nanmean
    
    %calculate high point of mean of std
    %calculate high point of mean of each other + SD
    %subtract every high point from std
    h_change = nanmean(hi_pts - mean(hi_pts(:, 1)));
    h_change_dev = nanstd(hi_pts - mean(hi_pts(:, 1)));
    
    %temp graph
    %bar(h_change(2:end));
    ln_stl = {'+', 'o', '*', 'x', 's', 'd', '^', 'p', 'v'}; 
    errorbar(1:size(hi_pts, 2)-1, h_change(2:end), h_change_dev(2:end), [ln_stl{ts} '-'], 'linewidth', 2)
    ax = gca;

    clear('hi_pts', 'tr_idx', 'rat');
end

title(['Height variation ' filedate_val]);
ylabel('Height change from standard (mm)');
xlabel('Stimulation change from standard for selected muscles');
set(ax, 'XTick', [1:size(trialsets{ts}, 2)-1]);
set(ax, 'XTickLabel', {'120%', '140%', '160%', '180%'});
set(ax, 'fontsize', 20);
set(gca,'TickDir','out');
legend('1', '2', '3', '4', '5', '6', '7', '8', '9'); 