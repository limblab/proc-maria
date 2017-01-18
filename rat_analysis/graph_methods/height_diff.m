function heights = height_diff(rat, swing_times, elim_steps)
%use this to get the maximum height difference within each step

y_val = rat.toe(:, 2); 

steps = setdiff(1:length(swing_times), elim_steps) 

heights = zeros(1, length(steps)); 

for i=1:length(steps)
    %get that val, the next val, and get the range from the y_val set
    heights(i) = range(y_val(swing_times{steps(i)}(1):swing_times{steps(i)+1}(1))); 
end

end