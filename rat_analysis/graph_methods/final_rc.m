function [pks, locs] = final_rc(joint, inv, fig_num, pkdist, pkmin, rmidx, addidx)
%pass a joint (like "rat.angles.knee")
%pass true/false whether to invert data

figure(fig_num); 

if inv
    joint = 1.01*max(joint)-joint;
end

%min peak height is larger than the baseline
mn_pk = joint(1)+pkmin; 

[pks, locs] = findpeaks(joint, 'MinPeakHeight', mn_pk, 'MinPeakDistance', pkdist);

if ~isempty(rmidx)
    %remove peaks at correct indices
    pks(rmidx) = []; 
    locs(rmidx) = []; 
    
    pks = [pks; addidx(:, 1)]; 
    locs = [locs; addidx(:, 2)]; 
    vals = [pks, locs]; 
    vals = sortrows(vals, 2); 
    pks = vals(:, 1); 
    locs = vals(:, 2); 
    %add peaks at correct indices
end

end
