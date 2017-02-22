%joint space diagrams yikes okay here goes

%import kinematic data for the appropriate files
filedate = '170126';
ratName = '160126';
trnum = [12 26 39 53 75]; %I need a better way of organizing these files I think.
track_angle = {'hip', 'hip', 'knee', 'knee', 'knee'};
inv_bool = [1 1 0 1 1]; 

ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};
tdmName = ''; tdmMks = [];

for i=1:length(trnum)
    path = ['/Users/mariajantz/Documents/Work/data/kinematics/' filedate '_files/' ratName num2str(trnum(i), '%02d') '.csv'];
    [events,rat,treadmill] = importViconData(path,[filedate(1:2) '-' filedate(3:4) '-' filedate(5:6)],tdmName,ratMks,tdmMks);
    
    for j=1:length(ratMks)
        rat.(ratMks{j}) = rat.(ratMks{j})/4.7243; %calibrate
    end
    
    %get the joint angles for the set of data
    rat.angles.limb = computeAngle(rat.hip_top, rat.hip_middle, rat.foot_mid);
    rat.angles.hip  = computeAngle(rat.hip_top, rat.hip_middle, rat.knee);
    rat.angles.knee = computeAngle(rat.hip_middle, rat.knee, rat.heel);
    rat.angles.ankle = computeAngle(rat.knee, rat.heel, rat.foot_mid);
    
    %show peaks; if there are none, do the inverse of the data
    %pick the peak at which you'll pull the joint angles
    dist = 50;
    h = 1; 
    [pks, locs] = findpeaks(rat.angles.(track_angle{i}), 'MinPeakHeight', rat.angles.(track_angle{i})(1)+h, 'MinPeakDistance', dist);
    figure();
    findpeaks(rat.angles.(track_angle{i}), 'MinPeakHeight', rat.angles.(track_angle{i})(1)+h, 'MinPeakDistance', dist)
    if inv_bool(i)
        %invert data
        data_inv = 1.01*max(rat.angles.(track_angle{i})) - rat.angles.(track_angle{i});
        [pks, locs] = findpeaks(data_inv, 'MinPeakHeight', data_inv(1)+h, 'MinPeakDistance', dist);
        findpeaks(data_inv, 'MinPeakHeight', data_inv(1)+h, 'MinPeakDistance', dist)
    end
    
    %p = input('Which peak should be used to calculate joint space? ');
    p=1; 
    
    %get all of the joint angles at peak p
    %get the mean starting values of the joint angles
    l_angles(i) = mean(rat.angles.limb(1:50))-rat.angles.limb(locs(p));
    h_angles(i) = mean(rat.angles.hip(1:50))-rat.angles.hip(locs(p));
    k_angles(i) = mean(rat.angles.knee(1:50))-rat.angles.knee(locs(p));
    a_angles(i) = mean(rat.angles.ankle(1:50))-rat.angles.ankle(locs(p));
    
end

%now add a couple of TA and LG values!

box off; 
%plot the vectors
figure(1); 
plotv([h_angles; k_angles]);
xlabel('\Delta hip angle');
ylabel('\Delta knee angle');
figax = get(1, 'Children');
lines = get(figax, 'Children');
set(lines, 'LineWidth', 4); 
set(gca, 'fontsize', 24);
set(gca,'TickDir','out')

figure(2);
plotv([h_angles; a_angles])
xlabel('\Delta hip angle')
ylabel('\Delta ankle angle')
figax = get(2, 'Children');
lines = get(figax, 'Children');
set(lines, 'LineWidth', 4);
set(gca, 'fontsize', 24);
set(gca,'TickDir','out')

figure(3); 
plotv([k_angles; a_angles])
xlabel('\Delta knee angle')
ylabel('\Delta ankle angle')
figax = get(3, 'Children');
lines = get(figax, 'Children');
set(lines, 'LineWidth', 4);
set(gca, 'fontsize', 24);
set(gca,'TickDir','out')
