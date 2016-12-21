% Reset to a known state and populate AI (takes ~330ms)
% Perhaps just use ai = daqfind and flushdata(ai,'all').
daqreset;

% set up the AO object (for triggering Vicon)
% added 2/10/15 by MCT for simultaneous Vicon data acquisition

%  ao = analogoutput('nidaq','Dev2');
ao = analogoutput('nidaq','Dev1');
addchannel(ao,[0 1]);
set(ao,'TriggerType','Manual');
startdata = [zeros(1,1) 5*ones(1,50) zeros(1,1); zeros(1,52)]'; % data for turning VICON acquisiton on
stopdata = [zeros(1,52); zeros(1,1) 5*ones(1,50) zeros(1,1); ]'; % data for turning VICON acquisiton off

putdata(ao,startdata);  % set it up for starting VICON data
start([ao]); pause(0.001);
trigger([ao]); %fopen(s);
disp('starting VICON')
pause(5); 

putdata(ao,stopdata);  % stop the Vicon data acquisition
start(ao);
trigger(ao);
disp('stopping VICON');

pause(2); 
stop(ao); 