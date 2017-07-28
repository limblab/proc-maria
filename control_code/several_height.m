cd 'C:\Users\mkj605\Documents\GitHub\stim_arrays';
slowdown_factor = 4; %two seems to be pretty much a normal length step. Kind of.
repeats = 11; %number of times to repeat the cycle
channels = [2 4 6 8 9 10 3 5 7 1];
amp_adjust = 1*ones(1, length(channels));
%amp_adjust([9]) = 1.8; %adjust the nth one in current array (1st is GS, 2nd is VL, etc)
ch = [1 5 9 10]; %channel to adjust

load('standard.mat'); 
call_emg_stim_importemgarray;
pause(60); 

load('stance_twothirds.mat'); 
call_emg_stim_importemgarray;
pause(60); 

load('stance_twothirds.mat'); 
amp_adjust = .714*ones(1, length(channels));
call_emg_stim_importemgarray;
pause(60); 

disp('120%'); 
load('stance_twothirds.mat'); 
amp_adjust([ch]) = .714*1.2;
call_emg_stim_importemgarray;
pause(60); 

disp('140%'); 
load('stance_twothirds.mat'); 
amp_adjust([ch]) = .714*1.4;
call_emg_stim_importemgarray;
pause(60); 

disp('160%'); 
load('stance_twothirds.mat'); 
amp_adjust([ch]) = .714*1.6;
call_emg_stim_importemgarray;
pause(60); 

disp('180%'); 
load('stance_twothirds.mat'); 
amp_adjust([ch]) = .714*1.8;
call_emg_stim_importemgarray;
pause(60); 
