clear all; 

savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';

load([savepath filename]);

%sort everything
%golly this is annoying
[s_fdate, s_idx] = sort(filedate); 
%rearrange all other values to match this - extreme_vals, filenum,
%pk_positions, sw_idx
filenum = filenum(s_idx); 
extreme_vals = extreme_vals(s_idx); 
pk_positions = pk_positions(s_idx); 
sw_idx = pk_positions(s_idx); 
%now rearrange to sort by filenum - do this inside for loop



%find dates to cycle through
fdates = unique(filedate);

for i=1:length(fdates)
    %find number of trials that day
    clear('h', 'l'); 
    locs = strfind(s_fdate, fdates{i});
    idx = find(~cellfun(@isempty,locs));
    [s_fnum, sfn_idx] = sort([filenum{idx}]); 
    sfn_idx = sfn_idx+idx(1)-1; 
    %need to add these indices to those from previous trials (so second
    %round through the for loop is +5)
    %TODO: ignore duplicate rows
    for j=1:length(sfn_idx)
        %heights, lengths for all trials on a given day
        h(:, j) = extreme_vals{sfn_idx(j)}.hi(:, 2) - extreme_vals{sfn_idx(j)}.lo(:, 2);
        l(:, j) = extreme_vals{sfn_idx(j)}.back(:, 1) - extreme_vals{sfn_idx(j)}.front(:, 1);
        %angles??? ankle peak time, knee peak time, hip peak time???
    end
    %plot
    figure(); subplot(2, 1, 1); hold on; 
    bar(mean(h));
    errorbar(1:length(sfn_idx), mean(h), std(h), '.', 'linewidth', 4)
    ax = gca;
    ylabel('Y (mm)');
    xlabel('Trial');
    title(['Height variation ' fdates{i}]);
    %lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
    set(ax, 'XTick', [1:length(sfn_idx)]);
    set(ax, 'XTickLabel', [filenum{sfn_idx}]);
    set(ax, 'fontsize', 20);
    set(gca,'TickDir','out');
    
    subplot(2, 1, 2); hold on; 
    bar(mean(l));
    errorbar(1:length(sfn_idx), mean(l), std(l), '.', 'linewidth', 4)
    ax = gca;
    ylabel('X (mm)');
    xlabel('Trial');
    title(['Length variation ' fdates{i}]);
    %lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
    set(ax, 'XTick', [1:length(sfn_idx)]);
    set(ax, 'XTickLabel', [filenum{sfn_idx}]);
    set(ax, 'fontsize', 20);
    set(gca,'TickDir','out');
    set(gcf, 'Position', [35 150 1000 800]); 
end

