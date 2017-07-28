cd 'C:\Users\mkj605\Documents\GitHub\stim_arrays';
slowdown_factor = 4; %two seems to be pretty much a normal length step. Kind of.
repeats = 11; %number of times to repeat the cycle
channels = [2 4 6 8 9 10 3 5 7 1];
amp_adjust = 1*ones(1, length(channels));
%amp_adjust([9]) = 1.8; %adjust the nth one in current array (1st is GS, 2nd is VL, etc)

disp('standard'); 
load('standard.mat'); 
call_emg_stim_importemgarray;
pause(60); 
disp('stance_twothirds'); 
load('stance_twothirds.mat'); 
call_emg_stim_importemgarray;
pause(60); 
disp('half stance'); 
load('halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
disp('stance_onethird'); 
load('stance_onethird.mat'); 
call_emg_stim_importemgarray;
pause(60); 

slowdown_factor = 8; %two seems to be pretty much a normal length step. Kind of.
disp('standard');
load('standard.mat'); 
call_emg_stim_importemgarray;
pause(60); 
disp('stance_twothirds');
load('stance_twothirds.mat'); 
call_emg_stim_importemgarray;
pause(60); 
disp('halfstance'); 
load('halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
disp('stance_onethird'); 
load('stance_onethird.mat'); 
call_emg_stim_importemgarray;
pause(60); 