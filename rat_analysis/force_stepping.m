filedate = '20170418';
filenum = 5; 
foldername = '/Users/mariajantz/Documents/Work/data/stimulation_files/';
stim_file = [foldername filedate '/' filedate '_' num2str(filenum, '%03d')];
force_file = [foldername filedate '/' filedate '_' num2str(filenum, '%03d') '_force'];
cal = [foldername '../forces/' filedate(3:end) '_iso/GS_force' ];

load(cal)
load(force_file); 

%THINGS TO SHOW: 
% first, deal with the calibration matrix
fnames = {'Force_X', 'Force_Y', 'Force_Z'}; 
cal_force = force_data*out_struct.calmat; 
figure; 
plot(cal_force(:, 1:3)-cal_force(1, 1:3)+[3 2 1])
legend(fnames); 
set(gca, 'fontsize', 18); 
% each trace, spaced out, with scale

%show magnitude of combined traces
fmag = sqrt(cal_force(:,1).^2 + cal_force(:,2).^2);   
figure; 
plot(fmag)

%compare to the endpoint xyz motion
load('/Users/mariajantz/Documents/Work/data/kinematics/processed/170418_101_rat'); 
plot(rat.toe-rat.toe(1, :)+[3 2 1]*40, 'linewidth', 2); 
legend({'Endpoint_X', 'Endpoint_Y', 'Endpoint_Z'}); 
set(gca, 'fontsize', 18); 
