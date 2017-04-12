function [cmd_cath, cmd_an] = sample_array(current_array, sending_freq, sampled_freq, stretch_factor)

% TODO: define these variables thoroughly. 

% downsample the total array to a smaller number of points
for i=1:size(current_array, 2)
    conv_fact = stretch_factor*sending_freq; %this will lead to a slight "stretching" effect of the step over time
    x = 1/sampled_freq:1/sampled_freq:length(current_array{i})/sampled_freq;
    xq = 1/conv_fact:1/conv_fact:length(current_array{i})/sampled_freq;
    ds_array{i} = interp1(x, current_array{i}, xq);
end

%make arrays to send
ds_mat = cell2mat(ds_array');

full_cmd = zeros(16, size(ds_mat, 2)); 
full_cmd(channels, :) = ds_mat;

cmd_cath = full_cmd*1000+32768; 
cmd_an = 32768-full_cmd*1000; 

