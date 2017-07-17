function [loc, traceacc, mnacc, pkvel, fdata] = accfilt2(data, cutoff, checkrange, plotrange)
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
fdata.fmag_vel = sqrt(fdata.x.du_filt(:,11).^2 + fdata.y.du_filt(:,11).^2 + fdata.z.du_filt(:,11).^2);
%magnitude of endpoint trace
fdata.mag_acc = sqrt(fdata.x.ddu(:,11).^2 + fdata.y.ddu(:,11).^2 + fdata.z.ddu(:,11).^2);
fdata.fmag_acc = sqrt(fdata.x.ddu_filt(:,11).^2 + fdata.y.ddu_filt(:,11).^2 + fdata.z.ddu_filt(:,11).^2);



%FINALLY, find the best section of the code to use as the point for
%comparison to force
%this gets pretty close to getting the first peak (as determined by the
%first significant spike in magnitude of velocity)
%[pks, locs] = findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.2);
[pks, locs] = findpeaks(fdata.mag_vel(checkrange), 'MinPeakHeight', 0.2);
locs = locs+checkrange(1)-1;
p = 1;

%if that cutoff value was too high, find lower options and plot
figure(201); hold on;
if length(pks)==0
    findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.05)
    [pks, locs] = findpeaks(fdata.mag_vel(checkrange), 'MinPeakHeight', 0.05);
    locs = locs+(checkrange(1)-1);
    plot(locs, pks, 'o', 'color', 'r', 'linewidth', 3)
else
    findpeaks(fdata.mag_vel, 'MinPeakHeight', 0.2)
    plot(locs, pks, 'o', 'color', 'r', 'linewidth', 3)
end
%if that cutoff is still too high, there was basically no movement -
%set to zero
if length(pks)==0
    pks = 0;
    locs = 28; %somewhat arbitrary point
    
    disp(pks(p));
    %then take whatever's at locs[1] and
    %find first data point where the velocity magnitude < .1 preceding
    %locs[1]
elseif pks(p)<0.4
    %show the peak locations of any high peaks
    %sort the array with the indices and display first 6 vals
    [sorted,sortingIndices] = sort(pks,'descend');
    if length(sorted)>5
        disp('Values of the highest indices');
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

%TODO: now plot the acceleration over a segment, and the velocity over a
%segment
figure(70); hold on;
plot(plotrange, fdata.mag_vel(plotrange), 'linewidth', 2) %magnitude of accel
plot(plotrange, fdata.mag_acc(plotrange), 'linewidth', 2) %magnitude of accel
plot(plotrange(2):plotrange(end), diff(fdata.mag_vel(plotrange)), 'linewidth', 2) %accel including negatives
plot(plotrange, zeros(1, length(plotrange)), 'color', 'k') %x axis
ax = gca;
line([locs(p) locs(p)], ax.YLim, 'LineStyle','--', 'color', 'k')
legend({'Mag vel', 'Mag acc', 'Diff vel'}, 'Location', 'northwest');


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
loc = (locs(p)-idx):locs(p);
%hmm. okay. Why does the other version track so much more closely?



%filter the angles the same way, if they are present in the array
