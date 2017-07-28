dir_path = '/Users/mariajantz/Documents/Work/figures/epidural/'; 
paths = {''}; 
savepdf = false; 
saveeps = true; 

%cycle through whole folder, loading each one, and save as (pdf?)
for i=1:length(paths)
    figs = dir(fullfile([dir_path paths{i}], '*.fig'));
    if savepdf
    if ~exist([dir_path 'pdfs/' paths{i}])
        mkdir([dir_path 'pdfs/' paths{i}]); 
    end
    cd([dir_path 'pdfs/' paths{i}]); 
    for j=1:size(figs, 1)
        openfig([dir_path paths{i} '/' figs(j).name]); 
        h=gcf; 
        set(h,'PaperOrientation','landscape');
        fname = [figs(j).name(1:end-4) '.pdf'];
        print(gcf, '-dpdf', fname, '-bestfit'); 
        close all; 
    end
    end
    if saveeps
    if ~exist([dir_path 'eps/' paths{i}])
        mkdir([dir_path 'eps/' paths{i}]); 
    end
    cd([dir_path 'eps/' paths{i}]); 
    for j=1:size(figs, 1)
        openfig([dir_path paths{i} '/' figs(j).name]); 
        saveas(gcf, figs(j).name(1:end-4), 'epsc');
        close all; 
    end
    end
end