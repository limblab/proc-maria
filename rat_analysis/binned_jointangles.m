cd(fileparts(mfilename('fullpath')));

clear all; 

bin_path = '../../../data/binned/'; %directory containing the binned data files
bin_file = 'A2_20160511'; %name of the file to check

load([bin_path bin_file '_binneddata.mat'])
% loads a struct called "binneddata" with the following fields:
% timeframe - ignored for these purposes
% neuronIDs - ignored for these purposes
% spikeratedata - ignored for these purposes
% cursorposbin - the positions of the markers
% trialtable - ignored for these purposes
% cursorposlabels - labels of the markers

% assign the marker labels and data for each marker to a struct
% that's easier to work with
for i=1:length(binneddata.cursorposlabels)/3
    lbl = cell2mat(binneddata.cursorposlabels{i*3}); 
    rat.(lbl(1:end-2)) = [binneddata.cursorposbin(:, i*3-2), binneddata.cursorposbin(:, i*3-1), binneddata.cursorposbin(:, i*3)];
end

%if the file is too long for processing to handle, split it into manageable
%chunks
splitsize = 3000;
fullsize = length(rat.knee); %do length of an arbitrary marker (they should all be the same length)
iter = ceil(fullsize/splitsize);

%process each chunk of data individually, and add that data to the
%angles variable of the rat struct
rat.angles.limb = []; 
rat.angles.hip = []; 
rat.angles.knee = []; 
rat.angles.ankle = []; 
rat.angles.foot = []; 

for i=1:iter
    stMk = (i-1)*splitsize+1; 
    lstMk = i*splitsize; 
    if lstMk>fullsize
        lstMk = fullsize; 
    end
    
    %if you want to change which points angles are defined across, this is where to do it
    rat.angles.limb = [rat.angles.limb; computeAngle(rat.hip_top(stMk:lstMk, :), rat.hip_center(stMk:lstMk, :), rat.foot(stMk:lstMk, :))]; 
    rat.angles.hip = [rat.angles.hip; computeAngle(rat.hip_top(stMk:lstMk, :), rat.hip_center(stMk:lstMk, :), rat.knee(stMk:lstMk, :))];
    rat.angles.knee = [rat.angles.knee; computeAngle(rat.hip_center(stMk:lstMk, :), rat.knee(stMk:lstMk, :), rat.heel(stMk:lstMk, :))];
    rat.angles.ankle = [rat.angles.ankle; computeAngle(rat.knee(stMk:lstMk, :), rat.heel(stMk:lstMk, :), rat.foot(stMk:lstMk, :))];
    rat.angles.foot = [rat.angles.foot; computeAngle(rat.heel(stMk:lstMk, :), rat.foot(stMk:lstMk, :), rat.toe(stMk:lstMk, :))]; 
    
end

%add the angles to binned data file
saving = true; 
if saving
    binneddata.angles = rat.angles; 
    save([bin_path bin_file '_bin_w_angles.mat'], 'binneddata'); 
end



    
