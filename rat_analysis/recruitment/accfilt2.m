function [locs, traceacc, mnacc, pkvel] = accfilt2(data, cutoff)
% input data with x, y, z, angles fields
% input b, a

%filter each field in accfilt
nms = fieldnames(data); 
for n=1:length(nms)
    fdata.(nms{n}) = acc_filt_field(data.(nms{n}), cutoff);
end
%calculate velocity magnitude
%cripes this is going to be a bit of a mess
%figure out how to call it based on what's returned
fdata.mag_vel = sqrt(fdata.x.du(:,11).^2 + fdata.y.du(:,11).^2 + fdata.z.du(:,11).^2);
%magnitude of endpoint trace
fdata.mag_acc = sqrt(fdata.x.ddu(:,11).^2 + fdata.y.ddu(:,11).^2 + fdata.z.ddu(:,11).^2);

%%%%%%%%%%%UNTESTED - TODO

%FINALLY, find the best section of the code to use as the point for
%comparison to force
%this gets pretty close to getting the first peak (as determined by the
%first significant spike in magnitude of velocity)
[pks, locs] = findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.2);
p = 1;
%if that cutoff value was too high, find lower options
figure(201);
if length(pks)==0
    findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.05)
    [pks, locs] = findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.05);
else
    findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.2)
end
%if that cutoff is still too high, there was basically no movement -
%set to zero
if length(pks)==0
    pks = 0;
    locs = int8(length(fdata.mag_vel)/2);
end
disp(pks(p));
%then take whatever's at locs[1] and
%find first data point where the velocity magnitude < .1 preceding
%locs[1]
if pks(p)<0.4
    %show the peak locations of any high peaks
    %sort the array with the indices and display first 6 vals
    [sorted,sortingIndices] = sort(pks,'descend');
    if length(sorted)>5
        a = [sorted(1:6), round(sortingIndices(1:6), 0)]
    end
    p=input('Which peak should be used for calculation of initial acceleration? (For other index type 100): ');
    
end

if p==100
    locs(end+1) = input('What is the index of the peak? ');
    pkvel = fdata.mag_vel(locs(end)); 
    val = pkvel; 
    p = length(locs); 
else
    pkvel = pks(p);
    val = pks(p);
end
idx=3;
%TODO: I THINK THIS IS A PROBLEM
while val>0.08
    idx=idx+1;
    val = fdata.mag_vel(locs(p)-idx);
end

initvel = fdata.mag_vel(locs(p)-idx:locs(p));
mnacc = mean(diff(initvel));
% NOTE: compare this mean acceleration value to the version from the
% traces
traceacc = fdata.mag_acc(locs(p)-idx-1:locs(p)-1);
%hmm. okay. Why does the other version track so much more closely?


%filter the angles the same way, if they are present in the array
