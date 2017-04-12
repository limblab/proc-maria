function test_ws(array_file, force, vicon)

%choose an array to load from file
%load the correct threshold and upper limits for each channel and print to check them
%apply amplitude adjustment
%choose repeats, stim and update frequencies
%determine timing (inc. length of stimulation - build in extra for vicon and force)
%save variables
%
%send info to a new function where: 
%initialize wireless stim object and update all values as appropriate
%if using force, initialize
%if using vicon, initialize analog out and activate
%if using force, turn on
%repeat array playback as many times as determined
%stop stimulator
%if using force, stop and save data
%if using vicon, stop


%% Load array from file and apply upper and lower limits
cd 'C:\Users\mkj605\Documents\GitHub\stim_arrays';
load(array_file); 

%TODO: should I reformat how this works? there has to be a best way to do
%this that makes more sense than how it is now. shoot. also what's going on
%with channel 10? is that actually an okay way to call it? I am going
%bonkers

legendinfo = {legendinfo{1:3} legendinfo{6:end}};
emg_array = {emg_array{1:3} emg_array{6:end}};
muscles = 1:length(emg_array); %can also pick and choose muscles to implement



%%


end