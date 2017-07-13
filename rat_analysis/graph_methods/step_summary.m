%step summary graphs
%TODO: figure out whether kinematics are sampled at 100 or 200 Hz and
%relabel axes accordingly
%TODO: deal with weird labeling on trials that have a spike "back" and then
%forward - what's swing, what's stance? 
%first import rats to compare
clear all; close all;

%set variables for each run

pkdist = 100;
pkwid = 10; 
err_trials = []; %rig this up for catching errored trials
numsteps = 11; 

filedates = {'160908', '161006', '161101', '161116', '170406'};
filenums = [1, 6, 2, 9, 115];

for f=5
    filenum = filenums(f);
    try
        if exist('filedate')
            clear('filedate', 'sw_idx', 'pk_positions', 'extreme_vals');
            close all;
        end
        filedate = filedates{f};
        %set paths
        path = '/Users/mariajantz/Documents/Work/data/';
        kin_path = [path 'kinematics/processed/' filedate '_' num2str(filenum, '%02d') '_rat.mat'];
        %load data
        load(kin_path);
        
        
        
        %next draw all traces for a trial, relative to the hip marker at zero
        figure(1); subplot(4, 4, [3 4 7 8 11 12]); hold on;
        rel_endpoint = rat.toe-rat.hip_bottom;
        finpt = min(5000, size(rel_endpoint, 1)); 
        plot(rel_endpoint(1:finpt, 1), rel_endpoint(1:finpt, 2))
        title([filedate ' Trial ' num2str(filenum)]);
        
        %on that graph, plot the high/low and front/back points (for height and length)
        %deal with step splitting somehow??? um. drat. okay here goes.
        
        %find the peaks, then pick the ten highest, invert, and pick ten lowest -
        %those are the high/low and front/back points in the steps.
        %Note: "front" goes negatively on the x axis
        
        pk_positions = struct();
        figure(2); subplot(2, 2, 1); hold on;
        findpeaks(rel_endpoint(1:finpt, 1), 'SortStr', 'descend', 'MinPeakDistance', pkdist, 'MinPeakProminence', 1, 'MinPeakWidth', pkwid)
        title('Back peaks');
        [pk_positions.b_pks, pk_positions.b_locs] = findpeaks(rel_endpoint(1:finpt, 1), 'SortStr', 'descend', 'MinPeakDistance', pkdist, 'MinPeakProminence', 1, 'MinPeakWidth', pkwid);
        inv_arr = max(rel_endpoint(1:finpt, 1))*1.01 - rel_endpoint(1:finpt, 1);
        subplot(2, 2, 2); findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', pkdist, 'MinPeakProminence', 1)
        title('Forward peaks');
        [f_pks, pk_positions.f_locs] = findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', pkdist, 'MinPeakProminence', 1); 
        pk_positions.f_pks = rel_endpoint(pk_positions.f_locs, 1);
        
        %front and back peak locations are also a good way to denote swing and
        %stance phases - swing starts at the back and goes forward - so pick the
        %top ten and then sort them
        %%%%%%
        %TODO: check that front peak #1 happens before back peak #1, deal with
        %this.
        f_vals = sort(pk_positions.f_locs(1:numsteps));
        b_vals = sort(pk_positions.b_locs(1:numsteps));
        %if there are higher peaks for the swing than backswing of stance
        if f_vals(1)>b_vals(1) && f_vals(2)>b_vals(2) %TODO: this is kind of janky
%             B = [pk_positions.b_locs(1:12), pk_positions.b_pks(1:12)]; %makes a matrix
%             [values, order] = sort(B(:,1));
%             sortedB = B(order,:); 
            %TODO: currently hard coded, switch to numsteps
            b_vals = sort(pk_positions.b_locs(12:22));
            pk_positions.b_pks = [pk_positions.b_pks(12:22); pk_positions.b_pks(1:11)]; 
            pk_positions.b_locs = [pk_positions.b_locs(12:22); pk_positions.b_locs(1:11)]; 
            %b_vals(1) = [];
        end
        %just use swing phase, and do the overlay+avg of hip, knee, ankle angles
        
        %TODO: SWITCH THIS BACK VERY IMPORTANT
        %TODO: FIGURE OUT WHY THIS NEEDS TO BE SWITCHED AND WHAT'S
        %HAPPENING
        sw_idx = [f_vals(1:numsteps) b_vals(1:numsteps)];
        
        %choose indices to exclude when determining high peaks - otherwise the back
        %swing of the foot gets included
        vals = [];
        %plot angles
        figure(3);
        set(gcf, 'Position', [380 150 1300 380]);
        h_arr = {};
        k_arr = {};
        a_arr = {};
        for i=1:numsteps-1
            subplot(1, 3, 1); hold on;
            plot(rat.angles.hip(sw_idx(i, 1):sw_idx(i+1, 1)));
            h_arr{i} = rat.angles.hip(sw_idx(i, 1):sw_idx(i+1, 1));
            subplot(1, 3, 2); hold on;
            plot(rat.angles.knee(sw_idx(i, 1):sw_idx(i+1, 1)));
            k_arr{i} = rat.angles.knee(sw_idx(i, 1):sw_idx(i+1, 1));
            subplot(1, 3, 3); hold on;
            plot(rat.angles.ankle(sw_idx(i, 1):sw_idx(i+1, 1)));
            a_arr{i} = rat.angles.ankle(sw_idx(i, 1):sw_idx(i+1, 1));
        end
        subplot(1, 3, 1); title('Hip');
        plot(mean(upsamp(h_arr)), 'linewidth', 2, 'color', 'k');
        subplot(1, 3, 2); title('Knee');
        plot(mean(upsamp(k_arr)), 'linewidth', 2, 'color', 'k');
        subplot(1, 3, 3); title('Ankle');
        plot(mean(upsamp(a_arr)), 'linewidth', 2, 'color', 'k');
        
        for i = 1:size(sw_idx, 1)-1
            diffval = round((sw_idx(i+1, 1)-sw_idx(i, 2))/3, 0);
            vals = [vals sw_idx(i+1, 1)-diffval:sw_idx(i+1, 1)];
            %vals = [vals sw_idx(i, 2)-dist:sw_idx(i, 2)+dist];
        end
        idx = setdiff(1:size(rel_endpoint, 1), vals);
        temp = rel_endpoint(1:finpt, 2);
        temp(idx) = rel_endpoint(1, 2)-100;
        
        figure(2);
        subplot(2, 2, 3); findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', pkdist)
        title('High peaks');
        [pk_positions.h_pks, pk_positions.h_locs] = findpeaks(temp, 'SortStr', 'descend', 'MinPeakDistance', pkdist);
        inv_arr = max(rel_endpoint(1:finpt, 2))*1.01 - rel_endpoint(1:finpt, 2);
        subplot(2, 2, 4); findpeaks(inv_arr, 'SortStr', 'descend', 'MinPeakDistance', pkdist)
        title('Low peaks');
        %different way of finding low peaks to set window correctly
        %low peaks - this is the most effective way to find them
        for i=1:10
            %find the correct section of step
            %find the minimum value and index within that section
            %subplot(4, 4, fig_idx(i)); hold on;
            disp(['Finding low peaks idx ' num2str(i)]); 
           
                pk_positions.l_pks(i) = min(rel_endpoint(sw_idx(i, 1):sw_idx(i, 2), 2));
                pk_positions.l_locs(i) = find(pk_positions.l_pks(i)==rel_endpoint(sw_idx(i, 1):sw_idx(i, 2), 2))+sw_idx(i, 1)-1;
%             
%                 %manually enter the correct val
%                 disp('Possible values'); 
%                 %TODO: DO A SORT HERE, THEN MANUALLY PICK THE CORRECT
%                 %VALUE. MAYBE MOVE THIS EARLIER AND JUST DO IT IF THE AUTO
%                 %OPTIONS DON'T LEAVE THEM FAIRLY EVENLY SPACED. YEAH. DO
%                 %THAT.
%                 disp(mat2str(sort(pk_positions.l_locs))); 
%                 pk_positions.l_locs(i) = input(['Correct index of peak #' num2str(i) ': ']);
%                 pk_positions.l_pks(i) = find(pk_positions.l_locs(i)==rel_endpoint(sw_idx(i, 1):sw_idx(i, 2), 2))+sw_idx(i, 1)-1;
            
            %pk_positions.l_pks(i) = min(rel_endpoint(sw_idx(i, 2):sw_idx(i+1, 1), 2))
            %pk_positions.l_locs(i) = find(pk_positions.l_pks(i)==rel_endpoint(sw_idx(i, 2):sw_idx(i+1, 2), 2))+sw_idx(i, 1)-1;
            
            %plot
            %plot(rel_endpoint(alt_l_locs(i), 1), rel_endpoint(alt_l_locs(i), 2), 'o', 'color', 'g', 'linewidth', 3);
        end
        pk_positions.l_pks = pk_positions.l_pks';
        pk_positions.l_locs = pk_positions.l_locs';
        % [l_pks, pk_positions.l_locs] = findpeaks(inv_arr(min(pk_positions.h_locs):end, :), 'SortStr', 'descend', 'MinPeakDistance', pkdist);
        % pk_positions.l_pks = rel_endpoint(pk_positions.l_locs, 2);
        % pk_positions.l_locs = pk_positions.l_locs + min(pk_positions.h_locs);
        
        if size(pk_positions.l_locs, 1)==10
            sw_idx(:, 3:4) = [[sort(pk_positions.h_locs(1:10)); 1] [sort(pk_positions.l_locs(1:10)); 1]];
        else
            sw_idx(:, 3:4) = [[sort(pk_positions.h_locs(1:10)); 1] sort(pk_positions.l_locs(1:11))];
        end
        
        %plot the peaks chosen to check that correct ones were chosen
        figure(2); subplot(2, 2, 1); hold on;
        plot(pk_positions.b_locs(1:length(sw_idx(:, 1))), pk_positions.b_pks(1:length(sw_idx(:, 1))), 'o', 'color', 'r', 'linewidth', 3);
        figure(2); subplot(2, 2, 2); hold on;
        plot(pk_positions.f_locs(1:length(sw_idx(:, 1))), f_pks(1:length(sw_idx(:, 1))), 'o', 'color', 'r', 'linewidth', 3);
        figure(2); subplot(2, 2, 3); hold on;
        plot(pk_positions.h_locs(1:10), pk_positions.h_pks(1:10), 'o', 'color', 'r', 'linewidth', 3);
        figure(2); subplot(2, 2, 4); hold on;
        plot(pk_positions.l_locs(1:10), inv_arr(pk_positions.l_locs(1:10)), 'o', 'color', 'r', 'linewidth', 3);
        fig = gcf;
        fig.Position = [100 155 1000 800];
        
        %check this by plotting each full step, splitting the parts
        figure(1);
        fig_idx = [1 2 5 6 9 10 13 14 15 16];
        for step=1:size(sw_idx, 1)-1
            subplot(4, 4, fig_idx(step)); hold on;
            title(['Step ' num2str(step)]);
            %plot stance
            plot(rel_endpoint(sw_idx(step, 1):sw_idx(step, 2), 1), rel_endpoint(sw_idx(step, 1):sw_idx(step, 2), 2), 'color', 'b', 'linewidth', 2);
            %plot swing
            plot(rel_endpoint(sw_idx(step, 2):sw_idx(step+1, 1), 1), rel_endpoint(sw_idx(step, 2):sw_idx(step+1, 1), 2), 'color', 'r', 'linewidth', 2);
            %plot starting point
            plot(rel_endpoint(sw_idx(step, 1), 1), rel_endpoint(sw_idx(step, 1), 2), 'o', 'color', 'k', 'linewidth', 3);
            plot(rel_endpoint(sw_idx(step, 2), 1), rel_endpoint(sw_idx(step, 2), 2), 'o', 'color', 'k', 'linewidth', 3);
            %plot high and low points
            plot(rel_endpoint(sw_idx(step, 3), 1), rel_endpoint(sw_idx(step, 3), 2), 'o', 'color', 'k', 'linewidth', 3);
            plot(rel_endpoint(sw_idx(step, 4), 1), rel_endpoint(sw_idx(step, 4), 2), 'o', 'color', 'k', 'linewidth', 3);
        end
        fig = gcf;
        fig.Position = [500 155 1200 800];
        
        %calculate and draw average trace of trial minus 1st and last step
        %make each step the same length (start with second, end before last)
        %average these together - maybe just make into cell array and send to
        %dnsamp function that I use to design the arrays
        trace_x = {};
        trace_y = {};
        trace_z = {};
        for i=2:size(sw_idx, 1)-1
            trace_x{end+1} = rel_endpoint(sw_idx(i, 1):sw_idx(i+1, 1), 1);
            trace_y{end+1} = rel_endpoint(sw_idx(i, 1):sw_idx(i+1, 1), 2);
            trace_z{end+1} = rel_endpoint(sw_idx(i, 1):sw_idx(i+1, 1), 3);
        end
        up_endpt = [upsamp(trace_x); upsamp(trace_y); upsamp(trace_z)];
        mn_endpt = [mean(upsamp(trace_x)); mean(upsamp(trace_y)); mean(upsamp(trace_z))];
        figure(1); subplot(4, 4, [3 4 7 8 11 12]); hold on;
        plot(mn_endpt(1, :), mn_endpt(2, :), 'linewidth', 3, 'color', 'k');
        
        %%%
        figure(4); hold on; %step plotted on equal axes
        plot(rel_endpoint(1:finpt, 1), rel_endpoint(1:finpt, 2)); 
        plot(mn_endpt(1, :), mn_endpt(2, :), 'linewidth', 3, 'color', 'k');
        title([filedate ' Trial ' num2str(filenum)]);
        ylim([-95 0]);
        xlim([-60 70]); 
        set(gca, 'FontSize', 14); 
        set(gca, 'TickDir', 'out');
        box off; 
        
        %calculate avg high and low points, and avg front and back points
        extreme_vals = struct();
        ext_fields = {'front', 'back', 'hi', 'lo'};
        steps = 2:size(sw_idx, 1)-1
        for i=1:length(ext_fields)
            extreme_vals.(ext_fields{i}) = rel_endpoint(sw_idx(steps, i), :);
            plot(mean(extreme_vals.(ext_fields{i})(:, 1)), mean(extreme_vals.(ext_fields{i})(:, 2)), 'o', 'linewidth', 3, 'color', 'r');
        end
        steplen = extreme_vals.back(:, 1)-extreme_vals.front(:, 1);
        avlen = mean(steplen);
        stepht = extreme_vals.hi(:, 2)-extreme_vals.lo(:, 2);
        avht = mean(stepht);
        
    catch ME
        err_trials(end+1) = filenum;
        disp(['skipping trial ' num2str(filenum)]);
        continue
    end
    
    %save some stuff down here if it all looks good
    usr_in = input('Do you want to save file? (y/n) ', 's');
    if usr_in == 'y'
        savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed_summary/';
        figpath = '/Users/mariajantz/Documents/Work/figures/summary/indiv_steps/';
        filename = 'summary_steps.mat';
        vars = {'filedate', 'filenum', 'sw_idx', 'pk_positions', 'extreme_vals'}; %list all variables in the file
        %temporary save of each variable in the set of vars so I can load a
        %different file with same variable names
        varnm = genvarname(vars);
        tempvar = genvarname(cellfun(@(x) [x '_temp'], vars, 'UniformOutput', false));
        for i=1:length(vars)
            eval([tempvar{i} '= eval(varnm{i});']);
        end
        
        %load and append to a save file
        if exist([savepath filename])
            %load the file and append all variables to array
            load([savepath filename]);
            %check if this file from that date has been saved already and ask to
            %save over it
            cont_write = 'x'; %x = append, y = overwrite, n = quit and don't save
            if contains(filedate, filedate_temp)
                %if one of the fields labeled "filedate" matches the index of the
                %filenum field...
                file_idx = find(strcmp([filedate{:}], filedate_temp));
                for j=1:length(file_idx)
                    %TODO: fix this? check
                    if filenum{file_idx(j)} == filenum_temp
                        cont_write = input(['Do you want to overwrite the previous save of this file? '...
                            '(y to overwrite/x to append/n to quit without saving) '], 's');
                        break
                    end
                end
            end
            %append variables like this:
            %filedate(size(filedate, 1)+1, :) = filedate_temp;
            for i=1:length(vars)
                varlen(i) = length(eval(varnm{i}));
            end
            if length(unique(varlen))>1
                cont_write = 'n';
                disp('Save file contains variables of different lengths; data not saved.');
            end
            if cont_write == 'x'
                for i=1:length(vars)
                    %append every variable
                    %this should go in a cell array
                    eval([varnm{i} '{end+1} = eval(tempvar{i});']);
                end
                %save those variables
                save([savepath filename], 'filedate', 'filenum', 'sw_idx', 'pk_positions', 'extreme_vals');
                if exist([figpath filedate_temp '_' num2str(filenum_temp) '_path.fig'])
                    figure(1); %make sure current figure is the one to save
                    savefig([figpath filedate_temp '_' num2str(filenum_temp) '_path_1']);
                    figure(3); %make sure current figure is the one to save
                    savefig([figpath filedate_temp '_' num2str(filenum_temp) '_angles_1']);
                else
                    figure(1); %make sure current figure is the one to save
                    savefig([figpath filedate_temp '_' num2str(filenum_temp) '_path']);
                    figure(3); %make sure current figure is the one to save
                    savefig([figpath filedate_temp '_' num2str(filenum_temp) '_angles']);
                end
                
            elseif cont_write == 'y'
                %overwrite at the index of the repeated value
                for i=1:length(vars)
                    %overwrite variables
                    eval([varnm{i} '{file_idx(j)} = eval(tempvar{i});']);
                end
                save([savepath filename], 'filedate', 'filenum', 'sw_idx', 'pk_positions', 'extreme_vals');
                figure(1); %make sure current figure is the one to save
                savefig([figpath filedate_temp '_' num2str(filenum_temp) '_path']);
                figure(3); %make sure current figure is the one to save
                savefig([figpath filedate_temp '_' num2str(filenum_temp) '_angles']);
            end
        else
            %convert everything to cells and then save.
            for i=1:length(vars)
                eval([varnm{i} '= {eval(tempvar{i})};']);
            end
            save([savepath filename], 'filedate', 'filenum', 'sw_idx', 'pk_positions', 'extreme_vals');
            %save figure
            figure(1); %make sure current figure is the one to save
            savefig([figpath filedate_temp '_' num2str(filenum_temp) '_path']);
            figure(3); %make sure current figure is the one to save
            savefig([figpath filedate_temp '_' num2str(filenum_temp) '_angles']);
        end
    end
    %save fr, bk, hi, lo step values so I can make summary figs with mean and
    %standard deviation
    
end

err_trials


