cd 'C:\Users\mkj605\Documents\GitHub\stim_arrays';
slowdown_factor = 8; %two seems to be pretty much a normal length step. Kind of.
repeats = 11; %number of times to repeat the cycle
channels = [2 4 6 8 9 10 3 5 7 1];
amp_adjust = 1*ones(1, length(channels));
%amp_adjust([9]) = 1.8; %adjust the nth one in current array (1st is GS, 2nd is VL, etc)

load('halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_150_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_200_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_250_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_300_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 

amp_adjust = .714*ones(1, length(channels));
ch = [2];
amp_adjust([ch]) = .714*1.4;
load('halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_150_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_200_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_250_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
load('half_vl_300_halfstance.mat'); 
call_emg_stim_importemgarray;
pause(60); 
