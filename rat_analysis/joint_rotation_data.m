%calculate for figure 6
%get joint rotation data for each individual muscle for each day
%include all kinematic RC files, only second to last and final files

%find force file folders
force_path = '/Users/mariajantz/Documents/Work/data/forces/';

%find kinematics folder
kin_path = '/Users/mariajantz/Documents/Work/data/kinematics/processed/';
%name muscle each file is correlated with for each day

%%%%%
% define the day to look at for each muscle
%give starting numbers for each file
muscles = {'IP', 'GS', 'RF', 'VL', 'SM', 'BFa', 'ST', 'BFp', 'TA', 'LG'}; 
fdates = {'f170126', 'f170221', 'f170418'};
tr_cell = cell(length(muscles), length(fdates)); 
%usr input dates
for m = 1:length(muscles)
    for fd = 1:length(fdates)
        disp(muscles{m}); 
        disp(fdates{m}); 
        frange = input('file range; 0 for no files', 's');
        if frange ~= 0
            tr_cell{m, fd} = frange; 
        end
    end
end
%save those vals after running so I don't need to run it again. 

%IP.f170126.hip = 1; %give max hip angle change from rest position, same with others 


%%%%%

ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};
tdmName = ''; tdmMks = [];
ratAng = {'limb', 'hip', 'knee', 'ankle'};







