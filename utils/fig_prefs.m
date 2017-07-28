function fig_prefs(ax, stim_vals)
set(ax, 'FontSize', 14); 
set(ax, 'TickDir', 'out');
set(ax, 'XTick', round(stim_vals(1:3:length(stim_vals)), 2)); 
xlim([stim_vals(1) stim_vals(end)]); 
box off; 
end