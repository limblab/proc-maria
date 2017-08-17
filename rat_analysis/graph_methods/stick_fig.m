clear all;

filedates = {'170713'};
filenums = 29:32;
steps = false;
avg_steps = false;

%load the summary info
savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
filename = 'summary_steps.mat';
load([savepath filename]);
%[s_fdate, s_idx] = sort(filedate);

%load correct file
for f=1:length(filenums)
    
    fnum = filenums(f);
    fdate = filedates{1};
    
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
    
    rat_mat = {rat.hip_top    ...
        rat.hip_bottom ...
        rat.hip_middle ...
        rat.knee       ...
        rat.heel       ...
        rat.foot_mid   ...
        rat.toe };
    
    if steps
        %to select a smaller section:
        b_ind = sw_idx{idx(fidx)}(3, 1);
        e_ind = sw_idx{idx(fidx)}(4, 1);
    elseif avg_steps
        sw_vals = sw_idx{idx(fidx)};
        for marker=1:length(rat_mat)
            trace_x = {};
            trace_y = {};
            trace_z = {};
            for j=2:size(sw_vals, 1)-1
                trace_x{end+1} = rat_mat{marker}(sw_vals(j, 1):sw_vals(j+1, 1), 1);
                trace_y{end+1} = rat_mat{marker}(sw_vals(j, 1):sw_vals(j+1, 1), 2);
                trace_z{end+1} = rat_mat{marker}(sw_vals(j, 1):sw_vals(j+1, 1), 3);
            end
            %up_endpt = [upsamp(trace_x); upsamp(trace_y); upsamp(trace_z)];
            rat_mat{marker} = [nanmean(upsamp(trace_x)); nanmean(upsamp(trace_y)); nanmean(upsamp(trace_z))]';
        end
        b_ind = 1;
        e_ind = size(rat_mat{1}, 1); %size of the new averaged rat thing
    else
        b_ind = 1;
        e_ind = size(rat_mat{1}, 1);
    end
    
    pt_dist = 10;
    t_interval = b_ind:e_ind;
    for val=b_ind:e_ind
        valdist = sqrt((rat_mat{end}(val, 1)-rat_mat{end}(t_interval(end), 1))^2 + ...
            (rat_mat{end}(val, 2)-rat_mat{end}(t_interval(end), 2))^2 + ...
            (rat_mat{end}(val, 3)-rat_mat{end}(t_interval(end), 3))^2); % TODO: check endpt distance in 3d (is there a built in option for this?)
        if valdist > pt_dist
            t_interval(end+1) = val;
        end
    end
    %t_interval = b_ind:1:e_ind;
    skip_frames = 1; %2 for every other etc
    
    
    rat_mat_orig = cellfun(@(x) x-rat_mat{2}(:, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    rat_mat = cellfun(@(array) array(t_interval, :), rat_mat_orig, 'UniformOutput', false);
    rat_mat_s = cellfun(@(x) x(1:skip_frames:end, :), rat_mat, 'UniformOutput', false); %set origin to bottom of hip in every frame
    
    annotate = false;
    hold_prev_frames = true;
    saving = false;
    
    figure;
    [an, footstrike, footoff] = saveGaitMovie(rat_mat_s, rat.f, hold_prev_frames, 'step.avi', saving, annotate);
    xlabel('X (mm)');
    ylabel('Y (mm)');
    ylim([-100 30])
    xlim([-60 70])
    
    %plot trace on top of this
    xvals = rat_mat_orig{end}(:, 1);
    yvals = rat_mat_orig{end}(:, 2);
    zvals = (max(rat_mat_orig{end}(:, 3))+1)*ones(length(xvals), 1);
    
    plot3(xvals, yvals, zvals, 'linewidth', 3, 'color', 'k');
    
    title([fdate ' trial ' num2str(fnum)]);
    set(gca, 'fontsize', 24);
    
    figpath = '/Users/mariajantz/Documents/Work/figures/summary/indiv_steps/';
    savefig([figpath fdate '_' num2str(fnum) '_stickfig']);
    
    
end