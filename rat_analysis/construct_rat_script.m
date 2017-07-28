
%define necessary import variables
filedate = '170715';
ratName = [filedate(1:2) '-' filedate(3:4) '-' filedate(5:6)];
filenum = 1:166; %can input an array if desired
sample_freq = 200; %give this value in Hz
savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed/'; 
import_vicon = true; 
split_steps = false; 


if import_vicon
for i=1:length(filenum)
    rat = import_vicon_rat(filedate, ratName, filenum(i));
    
    %save the rat right here
    disp(['saving trial ' num2str(filedate) '_' num2str(filenum(i), '%02d')]);
    save([savepath num2str(filedate) '_' num2str(filenum(i), '%02d') '_rat'], 'rat'); 
end
end

%swing times???
if split_steps
for i=1:length(filenum)
    load([savepath num2str(filedate) '_' num2str(filenum(i), '%02d') '_rat']); 
    
    %split swing times
    rat.swing_times = find_swing_times2(rat.toe, 1, 100); 
    
    %save the rat right here
    disp(['saving trial ' num2str(filedate) '_' num2str(filenum(i), '%02d')]);
    save([savepath num2str(filedate) '_' num2str(filenum(i), '%02d') '_rat'], 'rat'); 
end
end
