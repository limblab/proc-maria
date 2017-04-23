function rat = import_vicon_rat(filedate, ratName, filenum)

%% Load file path

pathName = ['/Users/mariajantz/Documents/Work/data/kinematics/' filedate '_files/'];

filedate = '17-04-06'; 
if filenum >= 100 %renumbering for the way Vicon rolls over at 3 digits
    filedate = [filedate(1:end-1) num2str(str2num(filedate(end))+1)]; 
    filenum = filenum-100; 
end

path     = [pathName filedate num2str(filenum, '%02d') '.csv'];

%% Define markers to use and import

% define the markers to use
tdmName = '';
tdmMks  = {};
ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};

% import Vicon data
[~,rat,~] = ...
    importViconData(path,ratName,tdmName,ratMks,tdmMks);

% convert the data to the correct scale
for i=1:length(ratMks)
    rat.(ratMks{i}) = rat.(ratMks{i})/4.7243; %calibrate
end


%% Determine joint angles and add them to the rat structure
rat.angles.limb = computeAngle(rat.hip_top, rat.hip_middle, rat.foot_mid);
rat.angles.hip  = computeAngle(rat.hip_top, rat.hip_middle, rat.knee);
rat.angles.knee = computeAngle(rat.hip_middle, rat.knee, rat.heel);
rat.angles.ankle = computeAngle(rat.knee, rat.heel, rat.foot_mid);


end