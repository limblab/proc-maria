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
        
        %for every kinematic file that hasn't been paired already, check
        for kdate_idx = 1:length(filedates)
        for k = 1:length(muscles{kdate_idx}) %TODO: eliminate doubles (think of as diagonal matrix?)
            kin_info = corr_arr{kdate_idx}.(muscles{kdate_idx}{k});
           
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
                
                [traceacc{l}, mnacc(l), pkvels(l), vfdata{l}] = accfilt2(data, cutoff, checkrange, plotrange);
                pkacc(l) = vfdata{l}.pks.aval;
                pkaccmn(l) = vfdata{l}.pks.amean;
                
                
            end
            %calculate correlation between the two curves
            norm_force = (force_mnmag - min(force_mnmag))/(max(force_mnmag)- min(force_mnmag)); 
            norm_acc = (pkacc - min(pkacc))/(max(pkacc)- min(pkacc)); 
            %interpolate and normalize to percent of stimluation
            sampsize = 30; 
            f_interval = (length(norm_force)-1)/(sampsize-1); 
            a_interval = (length(norm_acc)-1)/(sampsize-1); 
            samp_force = interp1(1:length(norm_force), norm_force, 1:f_interval:length(norm_force), 'spline');
            samp_acc = interp1(1:length(norm_acc), norm_acc, 1:a_interval:length(norm_acc), 'spline'); 
            
            %spline interp option
            
            %plot
            figure(1); 
            set(gcf, 'Position', [1100 550 550 400]); 
            plot(samp_force, '-d', 'LineWidth', 3, 'MarkerSize', 5);
            hold on;
            plot(samp_acc,  '-d', 'LineWidth', 3, 'MarkerSize', 5);
            
            
            %if the pair of files matches date and number, categorize it as matching
            if kdate_idx==i && j==k
                matched{end+1} = {filedates{i}, muscles{i}{j}, filedates{kdate_idx}, muscles{kdate_idx}{k}, corr2(samp_acc, samp_force)};
                disp('matched'); 
                disp(matched{end}); 
            else
            %if the pair of files doesn't match, categorize it as mismatched
                mismatched{end+1} = {filedates{i}, muscles{i}{j}, filedates{kdate_idx}, muscles{kdate_idx}{k}, corr2(samp_acc, samp_force)};
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
            close(figure(1)); 
        end
        end
    end
end
%save data