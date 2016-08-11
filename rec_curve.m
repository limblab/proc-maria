function rec_curve(start_amp, end_amp, increment, channel, stim_freq, pw, train_len, pause_time, com_port)

stim_array = []; 
p_zeros = zeros(1, round(pause_time*stim_freq)); 
for i=start_amp:increment:end_amp
    vals = i*ones(1, round(train_len*stim_freq/1000)); 
    stim_array = [stim_array p_zeros vals]; 
end

array_stim({stim_array}, 20, stim_freq, stim_freq, 1, pw, channel, 1, 0, 0, com_port);


end

