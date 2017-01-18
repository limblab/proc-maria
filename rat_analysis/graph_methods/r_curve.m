function [pks, locs] = r_curve(joint, inv, fig_num, pkdist, pkmin)
%pass a joint (like "rat.angles.knee")
%pass true/false whether to invert data

figure(fig_num); 

if inv
    joint = 1.01*max(joint)-joint;
end

%min peak height is larger than the baseline
mn_pk = joint(1)+pkmin; 
findpeaks(joint, 'MinPeakHeight', mn_pk, 'MinPeakDistance', pkdist)

[pks, locs] = findpeaks(joint, 'MinPeakHeight', mn_pk, 'MinPeakDistance', pkdist);

rm = input('Add/remove peaks? y/n ', 's'); 
if rm=='y'
    rmidx = input('Which peaks to remove? '); 
    %remove peaks at correct indices
    pks(rmidx) = []; 
    locs(rmidx) = []; 
    
    adidx = input('Locations to add? Enter as vertical array of [pk, loc] pairs '); 
    pks = [pks; adidx(:, 1)]; 
    locs = [locs; adidx(:, 2)]; 
    vals = [pks, locs]; 
    vals = sortrows(vals, 2); 
    pks = vals(:, 1); 
    locs = vals(:, 2); 
    %add peaks at correct indices
    
end

end