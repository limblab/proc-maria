clear all;

filedates = {'170713'};
filenums = [3 32];
%filedates = {'170713'};
%filenums = 3:4:40;
w_startpos = false;

titlename = 'IP\_BFp';

%load the summary info
savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';
load([savepath filename]);
%[s_fdate, s_idx] = sort(filedate);

%load correct file
for f=1:length(filenums)
    fnum = filenums(f);
    fdate = filedates{1};
    disp(fnum)
    
    %find indices in the file for filedates, filenums
    locs = strfind(filedate, fdate);
    idx = find(~cellfun(@isempty,locs));
    fidx = max(find([filenum{idx}]==fnum)); %assume the better processing happened later if there's a double
    
    %set paths
    path = '/Users/mariajantz/Documents/Work/data/';
    kin_path = [path 'kinematics/processed/' fdate '_' num2str(fnum, '%02d') '_rat.mat'];
    %load data
    load(kin_path);
    
    [row, col] = find(isnan(rat.knee));
    %     temp_knee = rat.knee;
    %     temp_knee(row, 1) = mean(rat.knee([row(1)-1 row(end)+1], 1));
    %     temp_knee(row, 2) = mean(rat.knee([row(1)-1 row(end)+1], 2));
    %     temp_knee(row, 3) = mean(rat.knee([row(1)-1 row(end)+1], 3));
    %at position (row, col) compare distances from femur mid and tibia mid
    %at start point and take mean to get current point
    %define the points
 
    for r = 1:length(unique(row))
        %define points for the first line
        Af = [rat.hip_middle(row(r), 1), rat.hip_middle(row(r), 2), rat.hip_middle(row(r), 3)];
        Bf = [rat.femur_mid(row(r), 1), rat.femur_mid(row(r), 2), rat.femur_mid(row(r), 3)];
        %figure; hold on;
        %plot3([Af(1) Bf(1)], [Af(2) Bf(2)], [Af(3) Bf(3)], 'o');
        %extend that line out past the knee
        %take the path and extend it an additional twice the length
        Cf = Bf+(Bf-Af)*2
        %h(1) = line([Af(1) Cf(1)], [Af(2) Cf(2)], [Af(3) Cf(3)])
        
        %define points for the second line and extend it
        At = [rat.heel(row(r), 1), rat.heel(row(r), 2), rat.heel(row(r), 3)];
        Bt = [rat.tibia_mid(row(r), 1), rat.tibia_mid(row(r), 2), rat.tibia_mid(row(r), 3)];
        %plot3([At(1) Bt(1)], [At(2) Bt(2)],[At(3) Bt(3)], 'o');
        %line([At(1) Bt(1)], [At(2) Bt(2)], [At(3) Bt(3)])
        Ct = Bt+(Bt-At)*2
        %h(2) = line([At(1) Ct(1)], [At(2) Ct(2)], [At(3) Ct(3)])
        
        %find intersect between the two lines at the knee
        %uhhhh how to do this with the z part? should check the docs on this
        [x, y] = polyxpoly([Af(1) Cf(1)], [Af(2) Cf(2)], [At(1) Ct(1)], [At(2) Ct(2)]);
        z = mean([Bf(3) Bt(3) Cf(3) Ct(3)]);
        %use that value to replace NaNs
        rat.knee(row(r), :) = [x, y, z];
        %plot3(x, y, z, 'o');
        
    end
    
    %find the values for maximum displacement
    max_disp = 0;
    max_frame = 1;
    for r=1:size(rat.toe, 1)
        change_dist = sqrt((rat.toe(1, 1)-rat.toe(r, 1))^2 + ...
        (rat.toe(1, 2)-rat.toe(r, 2))^2 + ...
        (rat.toe(1, 3)-rat.toe(r, 3))^2); 
  
        if change_dist > max_disp
            max_disp = change_dist; 
            max_frame = r; 
        end
        
    end
    
    
    rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.femur_mid ...
        rat.knee       ...
        rat.tibia_mid ...
        rat.heel       ...
        rat.foot_mid   ...
        rat.toe };
    
    
    
    b_ind = max_frame;
    e_ind = max_frame;
    
    t_interval = b_ind:1:e_ind;
    skip_frames = 1; %2 for every other etc
    
    rat_mat = cellfun(@(array) array(t_interval, :), rat_mat, 'UniformOutput', false);
    rat_mat = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    rat_mat_s = cellfun(@(x) x(1:skip_frames:end, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    
    annotate = false;
    hold_prev_frames = true;
    saving = false;
    startpos = false; 
    
    figure(1); hold on;
    [an, footstrike, footoff] = saveGaitMovie(rat_mat_s, rat.f, hold_prev_frames, 'step.avi', saving, annotate, startpos);
    
    if w_startpos
        startpos = true; 
        %plot starting position for each of them
        t_interval = 100;
        skip_frames = 1; %2 for every other etc
        rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.femur_mid ...
        rat.knee       ...
        rat.tibia_mid ...
        rat.heel       ...
        rat.foot_mid   ...
        rat.toe };
    
        rat_mat = cellfun(@(array) array(t_interval, :), rat_mat, 'UniformOutput', false);
        rat_mat = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
        rat_mat_s = cellfun(@(x) x(1:skip_frames:end, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
        [an, footstrike, footoff] = saveGaitMovie(rat_mat_s, rat.f, hold_prev_frames, 'step.avi', saving, annotate, startpos);
        
    end
    
    xlabel('X (mm)');
    ylabel('Y (mm)');
    ylim([-100 30])
    xlim([-60 70])
    
    %plot trace on top of this
    xvals = rat_mat{end}(:, 1);
    yvals = rat_mat{end}(:, 2);
    zvals = (max(rat_mat{end}(:, 3))+1)*ones(length(xvals), 1);
    
    plot3(xvals, yvals, zvals, 'linewidth', 3, 'color', 'k');
    
    %title([fdate ' trial ' num2str(fnum)]);
    set(gca, 'fontsize', 24);
    title(titlename);
    
end

set(gcf, 'Position', [1000, 350, 550, 600])
figpath = '/Users/mariajantz/Documents/Work/figures/summary/indiv_steps/';
savefig([figpath fdate '_' titlename]);
