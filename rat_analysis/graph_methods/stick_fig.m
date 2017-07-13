clear all;

filedates = {'161006', '161006','161006', '161116', '161116', '161116', '170406', '170406', '170406'};
filenums = [11, 15, 16, 9:11, 129:131];

%load the summary info
savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';
load([savepath filename]); 
%[s_fdate, s_idx] = sort(filedate); 

%load correct file
for f=1:length(filedates)
    
    fnum = filenums(f);
    fdate = filedates{f};
    
    %find indices in the file for filedates, filenums
    locs = strfind(filedate, fdate);
    idx = find(~cellfun(@isempty,locs));
    fidx = max(find([filenum{idx}]==fnum)); %assume the better processing happened later if there's a double
    
    %set paths
    path = '/Users/mariajantz/Documents/Work/data/';
    kin_path = [path 'kinematics/processed/' fdate '_' num2str(fnum, '%02d') '_rat.mat'];
    %load data
    load(kin_path);
    
    
    rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.knee       ...
        rat.heel       ...
        rat.foot_mid   ...
        rat.toe };
    
    %to select a smaller section:
    b_ind = sw_idx{idx(fidx)}(3, 1);
    e_ind = sw_idx{idx(fidx)}(4, 1);
    t_interval = b_ind:1:e_ind;
    skip_frames = 3; %2 for every other etc
    
    rat_mat = cellfun(@(array) array(t_interval, :), rat_mat, 'UniformOutput', false);
    
    rat_mat = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    rat_mat_s = cellfun(@(x) x(1:skip_frames:end, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    
    annotate = false;
    hold_prev_frames = true;
    saving = false; 
   
    xlabel('X (mm)');
    ylabel('Y (mm)');
    
    figure;
    [an, footstrike, footoff] = saveGaitMovie(rat_mat_s, rat.f, hold_prev_frames, 'step.avi', saving, annotate);
    ylim([-100 30])
    xlim([-60 70])
    
    %plot trace on top of this
    xvals = rat_mat{end}(:, 1);
    yvals = rat_mat{end}(:, 2);
    zvals = (max(rat_mat{end}(:, 3))+1)*ones(length(xvals), 1); 
    
    plot3(xvals, yvals, zvals, 'linewidth', 3, 'color', 'k'); 
    
    title([fdate ' trial ' num2str(fnum)]); 
    set(gca, 'fontsize', 24);
    
    figpath = '/Users/mariajantz/Documents/Work/figures/summary/indiv_steps/';
    savefig([figpath fdate '_' num2str(fnum) '_stickfig']);
    
    
    
    
end