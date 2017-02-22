fieldnames = {'sep08', 'oct06', 'nov16'}; 
tr = {[1, 8, 9], [8, 22, 23], [3, 4, 5]}; 

% [vals, idx] = intersect(heights.(fieldnames{1}).trnum, tr{1}); 
% h = heights.(fieldnames{1}).h(idx)
% 
% figure(); hold on; 
% mean_h = cell2mat(cellfun(@(x) mean(x), h, 'UniformOutput', false));
% std_h = cell2mat(cellfun(@(x) std(x), h, 'UniformOutput', false));
% bar(mean_h)
% errorbar(1:length(idx), mean_h, std_h, '.', 'linewidth', 4)
norm_vals = {}; 
for f=1:length(fieldnames)
    %let the normal step (100%) always be the first number in the set
    [vals, idx] = intersect(heights.(fieldnames{f}).trnum, tr{f})
    h = heights.(fieldnames{f}).h(idx); 
    for arr=1:length(h)
        h{arr}(h{arr}<1)=[]; 
    end
    
    
    mean_h = cell2mat(cellfun(@(x) mean(x), h, 'UniformOutput', false));    
    std_h = cell2mat(cellfun(@(x) std(x), h, 'UniformOutput', false));
    
    norm_mean = cell2mat(cellfun(@(x) mean(x/mean_h(1)), h, 'UniformOutput', false)); 
    norm_std = cell2mat(cellfun(@(x) std(x/mean_h(1)), h, 'UniformOutput', false)); 
    
    
    %divide by normal step to get percentages
    for m=1:length(mean_h)
%         norm_mean = mean_h(m)/mean_h(1); 
%         norm_std = std_h(m)/std_h(1);
        norm_vals{end+1} = {fieldnames{f}, tr{f}(m), norm_mean(m), norm_std(m)}; 
    end
end


%now manually average together the necessary things
%that is, norm_vals{n}(3:4) for 2, 3 first col
% 1, 4, 7 for second col
% 5, 8 third col (120%)
% 6, 9

finalmns = []; 
finalsts = []; 

temp= [2, 3];
mns = 0; 
sts = 0; 
for tempval=temp
    mns = mns + norm_vals{tempval}{3}; 
    sts = sts + norm_vals{tempval}{4}; 
end
finalmns(end+1) = mns/length(temp);
finalsts(end+1) = sts/length(temp);

temp= [1, 4, 7];
mns = 0; 
sts = 0; 
for tempval=temp
    mns = mns + norm_vals{tempval}{3}; 
    sts = sts + norm_vals{tempval}{4}; 
end
finalmns(end+1) = mns/length(temp);
finalsts(end+1) = sts/length(temp);

temp= [5, 8];
mns = 0; 
sts = 0; 
for tempval=temp
    mns = mns + norm_vals{tempval}{3}; 
    sts = sts + norm_vals{tempval}{4}; 
end
finalmns(end+1) = mns/length(temp);
finalsts(end+1) = sts/length(temp);

temp= [6, 9];
mns = 0; 
sts = 0; 
for tempval=temp
    mns = mns + norm_vals{tempval}{3}; 
    sts = sts + norm_vals{tempval}{4}; 
end
finalmns(end+1) = mns/length(temp);
finalsts(end+1) = sts/length(temp);

x_lbls = {'70%', '100%', '120%', '140%'}; 

figure(); hold on; 
bar(finalmns)
errorbar(1:4, finalmns, finalsts, '.', 'linewidth', 4)

ax = gca; 
ylabel('\Delta height');
xlabel('Change in IP/ST stim');
title('Height variation'); 
%lbls = cellfun(@(x) x.trial, trialname(idx(:, 2)), 'UniformOutput', 0)
set(ax, 'XTick', [1:4]);
set(ax, 'XTickLabel', x_lbls); 
set(ax, 'fontsize', 24);
set(gca,'TickDir','out')


