%inputs
channel_pairs = {[13 14]};
freq = 40; %40 Hz frequency
pw = .2; %200 us pulse width
sending_freq = 30; %30 Hz update freq

%build fake current array
dur = .5; %duration of .5 seconds
amp = 3; %assume amplitude of 3 mA during stim

%make array
arr = [zeros(1, 5) amp*ones(1, dur*freq) zeros(1, 5)];
current_arrays = {arr};

%set up channel array for manipulating them all at once
channels = cell2mat(channel_pairs);
com_port = 'COM5'; 

%check that there are no repeated channels and there's an even number
%just remove duplicates and then check that array matches the original
if length(intersect(channels, unique(channels)))~=length(channels) && mod(length(channels), 2)~=0
    disp('Error: Wrong number of channels.'); 
end

%now use these arrays to stimulate bipolar-ly

%initialize wireless stimulator object
if ~exist('ws', 'var')
    %ws = wireless_stim(com_port, 1); %the number has to do with verbosity of running feedback
    %ws.init(1, ws.comm_timeout_disable);
    
    ws_struct = struct(...
        'serial_string', com_port,...
        'dbg_lvl', 1, ...
        'comm_timeout_ms', 100, ... %-1 for no timeout
        'blocking', false, ... 
        'zb_ch_page', 5 ...
        );
    
    ws = wireless_stim(ws_struct);
    ws.init();
end


%set constant parameters for stimulator
%TODO: check that setting this doesn't send a pulse
command{1} = struct('Freq', freq, ...        % Hz
    'CathDur', pw*1000, ...    % us
    'AnodDur', pw*1000 ...    % us
    );

%set polarity for each channel
%PL - Polarity, 1=Cathodic first, 0=Anodic first
for i=1:length(channels)
    %set every other channel to be cathodic first
    ws.set_PL(mod(i, 2), channels(i)); 
    %set train delay to create staggered pulses
    ws.set_TD(50+500*ceil(i/2), channels(i));
    %set the constant stimulation parameters
    ws.set_stim(command, channels); 
end

%set stimulator to run continuously
%TODO: check that this doesn't send a pulse either
ws.set_Run(ws.run_cont, channels);

%%
%add a signal from the NIDAQ to determine on/off time of stimulation
% Reset to a known state and populate AI (takes ~330ms)
daqreset;

% set up the AO object (for triggering a signal that helps determine start
% time in Plexon)
ao = analogoutput('nidaq','Dev1');
addchannel(ao,[0 1]);
set(ao,'TriggerType','Manual');
% data to demo "on" signal in Plexon
ondata = [zeros(1,1) 5*ones(1,50) zeros(1,1); zeros(1,52)]'; 

putdata(ao,ondata);  % set up data to send to Plexon
start([ao]); pause(0.001);
trigger([ao]); %fopen(s);
disp('starting signal to Plexon')
pause(2); %can change this pause value 

%TODO: update all of these variables and check it
%do stimulation for each muscle, for each point in the array
for i=1:length(current_arrays{1})%for every data point
    a = tic;
    for j = 1:size(current_arrays, 2) %for every muscle
        command{1} = struct('CathAmp', current_arrays{j}(i)*1000+32768,... %in uA
            'AnodAmp', 32768-current_arrays{j}(i)*1000);
        ws.set_stim(command, channels(j)); %send updated amplitude to stimulator
    end
    %wait until it's time to do the next data point
    %TODO: test this. it's pretty janky.
    while toc(a)<(1/sending_freq)
        toc(a);
    end
    %timearray(i) = toc(a);
end

%stop all stimulation before ending program
ws.set_Run(ws.run_stop, channels);

putdata(ao,ondata);  % set up data to send to Plexon
start([ao]); pause(0.001);
trigger([ao]); %fopen(s);
disp('starting signal to Plexon')
pause(5); 

pause(2); 
stop(ao); 



