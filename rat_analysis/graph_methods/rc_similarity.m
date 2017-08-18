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

%calculate start:end range of each kinematics file
for i=1:length(filedates)
    for j=1:length(muscles{i})
        %load stim vals from force file
        %load a force file
        load([force_path filedates{i} '_iso/' muscles{i}{j} '_force.mat']);
        act_ch = out_struct.act_ch_list;
        stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
        corr_arr{i}.(muscles{i}{j}) = kin_startfile{i}(j):kin_startfile{i}(j)+length(stim_vals)-1;
    end
end

%for each date, load the relevant force folder
for i = 1:length(filedates)
    for j = 1:length(muscles{i})
        %load a force file
        load([force_path filedates{i} '_iso/' muscles{i}{j} '_force.mat']);
        %act_ch = out_struct.act_ch_list;
        %stim_vals = out_struct.modulation_channel_multipliers*out_struct.base_amp(act_ch);
        
        %pick a pair of files
        
        %calculate pk acc, normalize and spline fit
        %calculate force mean, normalize and spline fit
        
        %calculate correlation between the two curves
        
        %if the pair of files matches date and number, categorize it as matching
        %if the pair of files doesn't match, categorize it as unmatched
        
        %add correlation to the array
        %save plots
    end
end
%save data