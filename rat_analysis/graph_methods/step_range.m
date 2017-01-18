function ret = step_range(rat, swing_times, elim_steps, axis)
%use this to get the maximum height difference within each step

y_val = rat.toe(:, axis); 

%don't do the very last step bc there's no following step to get the range
%of

if ~ismember(length(swing_times), elim_steps)
    elim_steps(end+1) = length(swing_times); 
end

steps = setdiff(1:length(swing_times), elim_steps); 

ret = zeros(1, length(steps)); 

for i=1:length(steps)
    %get that val, the next val, and get the range from the y_val set
    ret(i) = range(y_val(swing_times{steps(i)}(1):swing_times{steps(i)+1}(1))); 
end

end