
%NEED TO AVERAGE FIRST
%import summary file
sumpath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/summary_steps.mat';
%get the indices of files
date_idx = find(~cellfun(@isempty, strfind(filedate, filedate_val)));
%split at steps, interpolate, mean

%set to use whole range
whole = true; 

rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.femur_mid ...
        rat.knee       ...
        rat.tibia_mid ...
        rat.heel       ...
        rat.foot_mid   ...
        rat.toe };
    
    if steps
    %to select a smaller section:
    b_ind = sw_idx{idx(fidx)}(3, 1);
    e_ind = sw_idx{idx(fidx)}(4, 1);
    else if whole
        b_ind = 1; 
        e_ind = size(rat_mat{1}, 1); 
    end

    %check distance from endpoint, if that point is far enough go ahead and plot
    pt_dist = 1; 
    for val=b_ind:e_ind
        rat_mat{end}(val, :) %check endpt distance


    end
    %t_interval = b_ind:1:e_ind;
    skip_frames = 1; %2 for every other etc
    
    rat_mat = cellfun(@(array) array(t_interval, :), rat_mat, 'UniformOutput', false);
    rat_mat = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    rat_mat_s = cellfun(@(x) x(1:skip_frames:end, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    
    disp(rat_mat_s{5}(1, :))
    
    annotate = false;
    hold_prev_frames = true;
    saving = false; 
   
    xlabel('X (mm)');
    ylabel('Y (mm)');
    
    figure(1); hold on; 
    [an, footstrike, footoff] = saveGaitMovie(rat_mat_s, rat.f, hold_prev_frames, 'step.avi', saving, annotate);
    ylim([-100 30])
    xlim([-60 70])