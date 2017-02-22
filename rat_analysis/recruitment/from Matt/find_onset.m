NOPTS.nbase = 50;
NOPTS.samprate = 200;
NOPTS.NSD = 6;
for ii = 1:size(tracedx,1)
    [pv ind] = find_onset(tracedmag(ii,1:end),NOPTS);
    pk_vel(ii) = pv;
    pk_ind(ii,:) = ind;
    pause
end
 
 
 
function [first_mx, first_mxind] = find_onset(trace, OPTS)
base = trace(1:OPTS.nbase);
sd = std(base);
mn = mean(base);
trace = trace - mn;
[b,a] = butter(4,50/OPTS.samprate);
tracef10 = filter(b,a,trace);
base10 = tracef10(1:OPTS.nbase);
sd10 = std(base10);
mn10 = mean(base10);
tracef10 = tracef10 - mn10;
mx = max(tracef10);
mn = min(tracef10);
indup = find(tracef10 > OPTS.NSD*sd10);  % find all the peaks above
inddown = find(tracef10 < -OPTS.NSD*sd10);  % find all the peaks below
 
if isempty(inddown)
    inddown(1) = length(tracef10);
end
if isempty(indup)
    indup(1) = length(tracef10);
end
if indup(1) > inddown(1)  % the first pulse goes down
    ind = inddown;
else
    ind = indup;
end
ind2 = find(diff(ind) > 1);
if isempty(ind2)
    ind2 = length(ind);
end
fp_ind = ind(1:ind2(1));  % this is the index to start from, then go backwards
temp = xcov(trace,tracef10,'coeff');
[mx,mxind] = max(temp);
midpt = (length(temp)-1)/2;
del = mxind - midpt;
fp_ind = fp_ind + del;  % correct for the filter induced delay
[mx,mxind] = max(tracef10(fp_ind));
fp_ind = fp_ind(1:mxind);
first_mx = mx;
first_mxind = [fp_ind(1) fp_ind(end)];
plot(trace)
hold on
plot(fp_ind,OPTS.NSD*sd10,'r.')
hold off
% pause
 