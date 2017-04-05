try
    set(curr_action_text,'String',sprintf('Stimulating muscle(s): %s at %s mA', mat2str(cell2mat(strcat(EMG_labels(stim_amps>0)))),num2str(stim_amps(stim_amps>0))));
    stim_offset = 500;
    if stim_offset>1e-2
        trigger([ai ao]); %fopen(s);
        
        disp('starting VICON')
        %run stimulation here
        
        % fields: current_array, sending_freq, stim_freq, sampled_freq,
        % stretch_factor, pw, channels, repeats, muscle_names, pause_time,
        % ws_object
        array_stim2({stim_array}, 30, stim_freq, stim_freq, 1, stim_width, active_channels, 1, 0, 0, ws);
        
        pause(stim_offset/1e3);
        
    else
        trigger(ai); %fopen(s);
        %run this stimulation train as long as specified, then stop
        %TODO check that time2run/sample_duration is actually what I get from the
        %gui, and it's in ms
        disp('Running stimulation.')

        array_stim2({stim_array}, 30, stim_freq, stim_freq, 1, stim_width, active_channels, 1, 0, 0, ws);

        %strOUT2 = fns_stim_prog('r',active_channel_list-1);
        %fwrite(s,strOUT2);
        %fclose(s);
        
    end
    
    wait(ai,(sample_duration*1.25)/1e3);
    putdata(ao,stopdata);  % stop the Vicon data acquisition
    start(ao);
    trigger(ao);
    disp('stopping VICON');
    
    data(:,:,trig) = getdata(ai);
    
    % -------------------------------------------------------------
    % Plot raw forces, force endpoint vectors, AND point on recruitment curves
    plot_forces(data,sample_rate,trig,handles,EMG_labels,EMG_enable,calMat);
    % -------------------------------------------------------------
    
    % -------------------------------------------------------------
    % Plot stimulations
    plot_stimulations(data,sample_rate,trig,handles,EMG_labels,EMG_enable);
    % -------------------------------------------------------------
    
    if (abort.value)
        error 'Stimulation and data collection aborted.'
    end
catch lasterror
    %             fns('stop');
    %fopen(s); fwrite(s,'2'); fclose(s);
    stop(ai);
    %priorPorts = instrfind; % finds any existing Serial Ports in MATLAB
    %delete(priorPorts);
    rethrow(lasterror);
end