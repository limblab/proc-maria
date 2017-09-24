load('/Users/mariajantz/Documents/Work/data/rccorr.mat'); 

%figure; hold on; 

for i=1:length(matched)
    %plot(1, matched{i}.spline_acc_corr, 'o'); 
    match_corr(i) = matched{i}.spline_acc_mse; 
end

for i=1:length(mismatched)
    %plot(2, mismatched{i}.spline_acc_corr, 'o'); 
    mis_corr(i) = mismatched{i}.spline_acc_mse; 
end

figure; hold on; 

match_mn = mean(match_corr); 
match_sd = std(match_corr); 

mis_mn = mean(mis_corr); 
mis_sd = std(mis_corr); 

bar([match_mn mis_mn]); 
errorbar(1:2, [match_mn mis_mn], [match_sd mis_sd], '.', 'LineWidth', 2)


