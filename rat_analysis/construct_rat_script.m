
%define necessary import variables
filedate = '170406';
ratName = [filedate(1:2) '-' filedate(3:4) '-' filedate(5:6)];
filenum = 110:140; %can input an array if desired
sample_freq = 100; %give this value in Hz
savepath = '/Users/mariajantz/Documents/Work/data/kinematics/processed/'; 

for i=1:length(filenum)
    rat = import_vicon_rat(filedate, ratName, filenum(i));
    
    %save the rat right here
    disp(['saving trial ' num2str(filedate) '_' num2str(filenum(i), '%02d')]);
    save([savepath num2str(filedate) '_' num2str(filenum(i), '%02d') '_rat'], 'rat'); 
end

%swing times???
