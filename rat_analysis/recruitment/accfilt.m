function [traceacc, mnacc, pkvel] = accfilt(data, cutoff)
% input data with x, y, z fields
% input b, a
%make filter (but don't apply)
[b,a] = butter(4,cutoff/100);

%fill NaNs
ind = [1:length(data.x)].';
for n=1:size(data.x, 2)
    
    indi = ind(~isnan(data.x(:, n)));
    yi = data.x(~isnan(data.x(:, n)), n);
    
    if length(indi)>0 %if there are real data in the channel
        data.x(:, n) = interp1(indi,yi,ind,'linear');
        indi = ind(~isnan(data.y(:, n)));
        yi = data.y(~isnan(data.y(:, n)), n);
        data.y(:, n) = interp1(indi,yi,ind,'linear');
        indi = ind(~isnan(data.z(:, n)));
        yi = data.z(~isnan(data.z(:, n)), n);
        data.z(:, n) = interp1(indi,yi,ind,'linear');
    end
end

%get mean starting values
%apply filter
data2 = data;
nsamp = size(data2.x,1);
base = repmat(mean(data2.x(1:20,:)),nsamp,1);
data2.x = filter(b,a,data2.x-base);
base = repmat(mean(data2.y(1:20,:)),nsamp,1);
data2.y = filter(b,a,data2.y-base);
base = repmat(mean(data2.z(1:20,:)),nsamp,1);
data2.z = filter(b,a,data2.z-base);
%figure(2); plot(data2.x(:, 11));

%differentiate = dx
data.dx = diff(data2.x);
data.dy = diff(data2.y);
data.dz = diff(data2.z);
%figure(3); plot(data.dx(:, 11));

%repmat and filter
%differentiate = ddx
nsamp = size(data.dx,1);
base = repmat(mean(data.dx(1:20,:)),nsamp,1);
data2.dx = filter(b,a,data.dx-base)+base;
base = repmat(mean(data.dy(1:20,:)),nsamp,1);
data2.dy = filter(b,a,data.dy-base)+base;
base = repmat(mean(data.dz(1:20,:)),nsamp,1);
data2.dz = filter(b,a,data.dz-base)+base;
%figure(4); plot(data2.dx(:, 11));
%get magnitude of velocity of endpoint
data2.velmag = sqrt(data2.dx(:,11).^2 + data2.dy(:,11).^2 + data2.dz(:,11).^2);

data.ddx = diff(data2.dx);
data.ddy = diff(data2.dy);
data.ddz = diff(data2.dz);
%figure(5); plot(data.ddx(:, 11));
%get the trace thing, not sure what's going on here honestly
%disp('now do trace');

%trace the endpoint marker
traceddx = data.ddx(:,11);
traceddy = data.ddy(:,11);
traceddz = data.ddz(:,11);
%figure(6); plot(data.ddx(:, 11));

tracedx = data.dx(:,11);
tracedy = data.dy(:,11);
tracedz = data.dz(:,11);
%figure(7); plot(data.ddx(:, 11));

tracex = data.x(:,11);
tracey = data.y(:,11);
tracez = data.z(:,11);

trace = sqrt(data.ddx(:,11).^2 + data.ddy(:,11).^2 + data.ddz(:,11).^2);
%figure(8); plot(data.ddx(:, 11));

%FINALLY, find the best section of the code to use as the point for
%comparison to force
%this gets pretty close to getting the first peak (as determined by the
%first significant spike in magnitude of velocity)
[pks, locs] = findpeaks(data2.velmag, 'MinPeakHeight', 0.2);
p = 1;
%if that cutoff value was too high, find lower options
if length(pks)==0
    figure(201);
    findpeaks(data2.velmag, 'MinPeakHeight', 0.05)
    [pks, locs] = findpeaks(data2.velmag, 'MinPeakHeight', 0.05);
end
%if that cutoff is still too high, there was basically no movement -
%set to zero
if length(pks)==0
    pks = 0;
    locs = int8(length(data2.velmag)/2);
end
disp(pks(p));
%then take whatever's at locs[1] and
%find first data point where the velocity magnitude < .1 preceding
%locs[1]
if pks(p)<0.4
    figure(200);
    findpeaks(data2.velmag, 'MinPeakHeight', 0.2)
    %show the peak locations of any high peaks
    %sort the array with the indices and display first 6 vals
    [sorted,sortingIndices] = sort(pks,'descend');
    if length(sorted)>5
        a = [sorted(1:6), sortingIndices(1:6)]
    end
    p=input('Which peak should be used for calculation of initial acceleration? (For other index type 100) ');
    
end

if p==100
    locs(end+1) = input('What is the index of the peak? ');
    pkvel = data2.velmag(locs(end)); 
    val = pkvel; 
    p = length(locs); 
else
    pkvel = pks(p);
    val = pks(p);
end
idx=1;
while val>0.08
    idx=idx+1;
    val = data2.velmag(locs(p)-idx);
end

initvel = data2.velmag(locs(p)-idx:locs(p));
mnacc = mean(diff(initvel));
% NOTE: compare this mean acceleration value to the version from the
% traces
traceacc = trace(locs(p)-idx-1:locs(p)-1);
%hmm. okay. Why does the other version track so much more closely?


end