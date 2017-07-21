function [traceacc, mnacc, pkvel, fdata] = accfilt2(data, cutoff, checkrange, plotrange)
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
fdata.mag.vel = sqrt(fdata.x.du(:,11).^2 + fdata.y.du(:,11).^2 + fdata.z.du(:,11).^2);
fdata.mag.vel_filt = sqrt(fdata.x.du_filt(:,11).^2 + fdata.y.du_filt(:,11).^2 + fdata.z.du_filt(:,11).^2);
%magnitude of endpoint trace
fdata.mag.acc = sqrt(fdata.x.ddu(:,11).^2 + fdata.y.ddu(:,11).^2 + fdata.z.ddu(:,11).^2);
fdata.mag.acc_filt = sqrt(fdata.x.ddu_filt(:,11).^2 + fdata.y.ddu_filt(:,11).^2 + fdata.z.ddu_filt(:,11).^2);



%FINALLY, find the best section of the code to use as the point for
%comparison to force
%this gets pretty close to getting the first peak (as determined by the
%first significant spike in magnitude of velocity)
%[pks, locs] = findpeaks(fdata.mag.vel, 'MinPeakHeight', 0.2);
[pks, locs] = findpeaks(fdata.mag.vel(checkrange), 'MinPeakHeight', 0.2);
locs = locs+checkrange(1)-1;
p = 1;

%if that cutoff value was too high, find lower options and plot
figure(201); hold on;
if length(pks)==0
    findpeaks(fdata.mag.vel, 'MinPeakHeight', 0.05)
    [pks, locs] = findpeaks(fdata.mag.vel(checkrange), 'MinPeakHeight', 0.05);
    locs = locs+(checkrange(1)-1);
    plot(locs, pks, 'o', 'color', 'r', 'linewidth', 3)
else
    findpeaks(fdata.mag.vel, 'MinPeakHeight', 0.2)
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
    pkvel = fdata.mag.vel(locs(end));
    val = pkvel;
    p = length(locs);
else
    pkvel = pks(p);
    val = pks(p);
end

%TODO: now plot the acceleration over a segment, and the velocity over a
%segment
figure(70); hold on;
plot(plotrange, fdata.mag.vel(plotrange), 'linewidth', 2) %magnitude of vel
plot(plotrange, fdata.mag.acc(plotrange), 'linewidth', 2) %magnitude of accel
plot(plotrange(2):plotrange(end), diff(fdata.mag.vel(plotrange)), 'linewidth', 2) %accel including negatives
plot(plotrange, zeros(1, length(plotrange)), 'color', 'k') %x axis
ax = gca;
line([locs(p) locs(p)], ax.YLim, 'LineStyle','--', 'color', 'k')
legend({'Mag vel', 'Mag acc', 'Diff vel'}, 'Location', 'northwest');

%TODO: do this for filtered data?
interp_seg = .25; 

fdata.mag.vel_spline = interp1(1:size(fdata.mag.vel, 1), fdata.mag.vel, 1:.25:size(fdata.mag.vel, 1), 'spline'); 
fdata.mag.acc_spline = interp1(1:size(fdata.mag.acc, 1), fdata.mag.acc, 1:.25:size(fdata.mag.acc, 1),'spline');

%find peak velocity within close range of the peak found in non-interp 
vs_range = (locs(p)/interp_seg-3/interp_seg):(locs(p)/interp_seg+2/interp_seg); 
[fdata.pks.spl_vval, fdata.pks.spl_vloc] = max(fdata.mag.vel_spline(vs_range)); 
fdata.pks.spl_vloc = fdata.pks.spl_vloc + vs_range(1)-1; 
as_range = (fdata.pks.spl_vloc-4/interp_seg):(fdata.pks.spl_vloc+1/interp_seg); 
[fdata.pks.spl_aval, fdata.pks.spl_aloc] = max(fdata.mag.acc_spline(as_range)); 
fdata.pks.spl_aloc = fdata.pks.spl_aloc + as_range(1)-1; 


idx=3;
%TODO: I THINK THIS IS A PROBLEM
while val>0.08
    idx=idx+1;
    val = fdata.mag.vel(locs(p)-idx);
end

initvel = fdata.mag.vel(locs(p)-idx:locs(p));
mnacc = mean(diff(initvel));
% NOTE: compare this mean acceleration value to the version from the
% traces
traceacc = fdata.mag.acc(locs(p)-idx-1:locs(p)-1);


%fdata.locs.rng = (locs(p)-idx):locs(p);
%TODO: filtered version too
%TODO: spline interp filtered version
fdata.pks.vloc = locs(p); 
apk_arr = fdata.mag.acc((fdata.pks.vloc-5):(fdata.pks.vloc+1)); 
[fdata.pks.aval, fdata.pks.aloc] = max(apk_arr);
fdata.pks.aloc = fdata.pks.aloc + fdata.pks.vloc-6;
fdata.mag.acc((fdata.pks.aloc-1):(fdata.pks.aloc+1)) %print this temp so I see it's at peak
fdata.pks.amean = mean(fdata.mag.acc((fdata.pks.aloc):(fdata.pks.aloc+2)));
%TODO avg either side
%hmm. okay. Why does the other version track so much more closely?



%filter the angles the same way, if they are present in the array
