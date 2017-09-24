%find cross correlation between different RC
clear all; close all;

%find force file folders
force_path = '/Users/mariajantz/Documents/Work/data/forces/';
filedates = {'170126', '170221', '170418', '170503'};

%find kinematics folder
kin_path = '/Users/mariajantz/Documents/Work/data/kinematics/processed/';
%name muscle each file is correlated with for each day
muscles = {{'GS', 'IP', 'VL', 'RF', 'BF'}, {'GS', 'IP', 'RF', 'ST'}, {'IP', 'GS', 'RF', 'VL', 'SM', 'BFa', 'ST', 'BFp'}, {'IP', 'GS', 'VL', 'BFp', 'BFa'}};
%give starting numbers for each file
kin_startfile = {[1 16 31 42 68], [1 13 25 37], [1 13 26 38 50 62 74 86], [1 16 31 51 65 80 94]};
ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};
tdmName = ''; tdmMks = [];
ratAng = {'limb', 'hip', 'knee', 'ankle'};

matched = {}; 
mismatched = {}; 

%calculate start:end range of each kinematics file
for i=1:length(filedates)
    for j=1:length(muscles{i})
        %load stim vals from force file
        %load a force file
        load([force_path filedates{i} '_iso/' muscles{i}{j} '_force.mat']);
        act_ch = out_struct.act_ch_list;
        stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
        corr_arr{i}.(muscles{i}{j}).kin_files = kin_startfile{i}(j):kin_startfile{i}(j)+length(stim_vals)-1;
        corr_arr{i}.(muscles{i}{j}).stim_vals = stim_vals; 
    end
end

matched = {}; 
mismatched = {}; 
%for each date, load the relevant force folder
for i = 1:length(filedates)
    for j = 1:length(muscles{i})
        
        %load a force file
        load([force_path filedates{i} '_iso/' muscles{i}{j} '_force.mat']);
        act_ch = out_struct.act_ch_list;
        stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
        
        %calculate force mean, normalize and (spline?) interp
        
        %set filter parameters
        cutoff = 50;
        [b,a] = butter(4,cutoff/1000);
        
        %filter and get magnitudes and angles between direction vectors
        [fdata, allmag, allang, allang2] = forcefilt(out_struct.data, out_struct.calmat, b, a);
        
        mnrange = 2400:2700; %formerly 2350:2800;
        force_mnmag = [];
        %average over .1s
        for idx = 1:size(allmag, 1)
            force_mnmag(idx) = mean(allmag(idx, mnrange));
        end
        
        %for every kinematic file, check
        for kdate_idx = 1:length(filedates)
            %TODO: remove this line
            %kdate_idx = 2; 
            cutoff = 8; 
        for k = 1:length(muscles{kdate_idx}) %TODO: eliminate doubles (think of as diagonal matrix?)
            %TODO: remove this line
            %k = 4;
            kin_info = corr_arr{kdate_idx}.(muscles{kdate_idx}{k});
            
            vfdata = {}; 
            for l = 1:length(kin_info.kin_files)
                %pick set of kinematics files
                load([kin_path filedates{kdate_idx} '_' num2str(kin_info.kin_files(l), '%02d') '_rat.mat']);
                %calculate pk acc, normalize and spline fit
                %that returns a struct named "rat"
                %most peaks occur between point 220 and 240
                data.x = cell2mat(cellfun(@(x) rat.(x)(:, 1), ratMks, 'UniformOutput', 0));
                data.y = cell2mat(cellfun(@(x) rat.(x)(:, 2), ratMks, 'UniformOutput', 0));
                data.z = cell2mat(cellfun(@(x) rat.(x)(:, 3), ratMks, 'UniformOutput', 0));
                checkrange = 210:255;
                plotrange = 210:255;
                
                figure(100); hold on; 
                [traceacc{l}, mnacc(l), pkvels(l), vfdata{l}] = accfilt2(data, cutoff, checkrange, plotrange);
                pkacc(l) = vfdata{l}.pks.aval;
                pkaccmn(l) = vfdata{l}.pks.amean;
                pkvel(l) = vfdata{l}.pks.vval; 
                close(100); 
                
            end
            %calculate correlation between the two curves
            norm_force = (force_mnmag - min(force_mnmag))/(max(force_mnmag)- min(force_mnmag)); 
            norm_acc = (pkacc - min(pkacc))/(max(pkacc)- min(pkacc)); 
            norm_mn_acc = (pkaccmn - min(pkaccmn))/(max(pkaccmn)- min(pkaccmn)); 
            norm_vel = (pkvel - min(pkvel))/(max(pkvel)- min(pkvel)); 
            %interpolate and normalize to percent of stimluation
            sampsize = 100; 
            f_interval = (length(norm_force)-1)/(sampsize-1); 
            a_interval = (length(norm_acc)-1)/(sampsize-1); 
%             samp_force = interp1(1:length(norm_force), norm_force, 1:f_interval:length(norm_force), 'spline');
%             samp_acc = interp1(1:length(norm_acc), norm_acc, 1:a_interval:length(norm_acc), 'spline'); 
%             samp_vel = interp1(1:length(norm_vel), norm_vel, 1:a_interval:length(norm_acc), 'spline'); 
%             
            %[curve, goodness, output] = fit([1:length(norm_force)]',norm_force','smoothingspline');
            p_force = polyfit(1:length(norm_force), norm_force , 7); 
            samp_force = polyval(p_force, 1:f_interval:length(norm_force)); 
            p_acc = polyfit(1:length(norm_acc), norm_acc , 7); 
            samp_acc = polyval(p_acc, 1:a_interval:length(norm_acc)); 
            p_vel = polyfit(1:length(norm_acc), norm_vel , 7); 
            samp_vel = polyval(p_vel, 1:a_interval:length(norm_acc)); 
         
            
            lin_samp_force = interp1(1:length(norm_force), norm_force, 1:f_interval:length(norm_force), 'linear');
            lin_samp_acc = interp1(1:length(norm_acc), norm_acc, 1:a_interval:length(norm_acc), 'linear'); 
            lin_samp_vel = interp1(1:length(norm_vel), norm_vel, 1:a_interval:length(norm_acc), 'linear'); 
            
            
            
            %plot
            figure(1); hold on;
            set(gcf, 'Position', [1100 550 550 400]); 
            h(1) = plot(samp_force, '-d', 'LineWidth', 3, 'MarkerSize', 5, 'color', 'k');
            plot(1:1/f_interval:sampsize, norm_force, 'o', 'LineWidth', 3, 'MarkerSize', 5, 'color', 'r');
            h(2) = plot(samp_acc,  '-d', 'LineWidth', 3, 'MarkerSize', 5, 'color', 'b');
            plot(1:1/a_interval:sampsize, norm_acc, 'o', 'LineWidth', 3, 'MarkerSize', 5, 'color', 'm');
            legend(h, 'Force', 'Acceleration', 'northwest'); 
            ylim([0 1]); 
            box off; 
            
            %if the pair of files matches date and number, categorize it as matching
            fieldnames = {'force_filedate', 'force_muscle', 'kin_filedate', 'kin_muscle',...
                'spline_acc_corr', 'spline_acc_mse', 'spline_vel_corr', 'spline_vel_mse', ...
                'lin_acc_corr', 'lin_acc_mse', 'lin_vel_corr', 'lin_vel_mse'}; 
            %should also determine spillover point via angles - TODO
            tempvar = {filedates{i}, muscles{i}{j}, filedates{kdate_idx}, ...
                    muscles{kdate_idx}{k}, corr2(samp_acc, samp_force), immse(samp_acc, samp_force), ...
                    corr2(samp_vel, samp_force), immse(samp_vel, samp_force), ...
                    corr2(lin_samp_acc, lin_samp_force), immse(lin_samp_acc, lin_samp_force), ...
                    corr2(lin_samp_vel, lin_samp_force), immse(lin_samp_vel, lin_samp_force)};
            
            if kdate_idx==i && j==k
                %TODO: double check this mapping
                temp_idx = length(matched) + 1; 
                for fnm=1:length(fieldnames)
                    matched{temp_idx}.(fieldnames{fnm}) = tempvar{fnm}; 
                end
                disp('matched'); 
                disp(matched{end}); 
            else
            %if the pair of files doesn't match, categorize it as mismatched
                temp_idx = length(mismatched) + 1; 
                for fnm=1:length(fieldnames)
                    mismatched{temp_idx}.(fieldnames{fnm}) = tempvar{fnm}; 
                end
                disp('mismatched'); 
                disp(mismatched{end}); 
            end
            %add correlation to the array
            %TODO: save plots
            %disp(['Force: ' filedates{i} muscles{i}{j}]);
            %disp(['Kinem: ' filedates{kdate_idx} muscles{kdate_idx}{k}]);
            disp('--------'); 
            if ~exist(['/Users/mariajantz/Documents/Work/figures/summary/correlations/' filedates{i} muscles{i}{j} 'force/'])
                mkdir(['/Users/mariajantz/Documents/Work/figures/summary/correlations/' filedates{i} muscles{i}{j} 'force/']);
            end
            saveas(figure(1), ['/Users/mariajantz/Documents/Work/figures/summary/correlations/' filedates{i} muscles{i}{j} 'force/' filedates{kdate_idx} muscles{kdate_idx}{k}], 'epsc');
            savefig(figure(1), ['/Users/mariajantz/Documents/Work/figures/summary/correlations/' filedates{i} muscles{i}{j} 'force/' filedates{kdate_idx} muscles{kdate_idx}{k}]); 
            close(figure(1)); 
        end
        end
    end
end

%save overall data
save('/Users/mariajantz/Documents/Work/data/rccorr.mat', 'matched', 'mismatched'); 

%then later on do stuff with it yo
