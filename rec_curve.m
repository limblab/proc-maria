function rec_curve(start_amp, end_amp, increment, channel, stim_freq, pw, pause_time)

%initiate wireless stimulator object
if ~exist('ws', 'var')
    %ws = wireless_stim(com_port, 1); %the number has to do with verbosity of running feedback
    %ws.init(1, ws.comm_timeout_disable);
    
    ws_struct = struct(...
        'serial_string', com_port,...
        'dbg_lvl', 1, ...
        'comm_timeout_ms', 100, ... %-1 for no timeout
        'blocking', false, ... %change this
        'zb_ch_page', 2 ...%change this to ideal parameter
        );
    
    ws = wireless_stim(ws_struct);
    ws.init();
end

%set constant parameters for stimulator
command{1} = struct('Freq', stim_freq, ...        % Hz
    'CathDur', pw*1000, ...    % us
    'AnodDur', pw*1000 ...    % us
    );

%start loop of stimulation
for i=start_amp:increment:end_amp
    
    if i~=start_amp
        ws.set_Run(ws.run_stop, channel);
        pause(pause_time);
    end
    ws.set_Run(ws.run_cont, channel);
    
    command{1} = struct('CathAmp', i*1000+32768,... %in uA
        'AnodAmp', 32768-i*1000);
    ws.set_stim(command, channel); %send updated amplitude to stimulator
    
end


end

