function [data] = acc_filt_field(field, cutoff)
% input data with x, y, z fields
% input b, a
%make filter (but don't apply)
[b,a] = butter(4,cutoff/100);
data.u = field;

%fill NaNs
ind = [1:length(data.u)].';
for n=1:size(data.u, 2)
    
    indi = ind(~isnan(data.u(:, n)));
    yi = data.u(~isnan(data.u(:, n)), n);
    
    if length(indi)>0 %if there are real data in the channel
        data.u(:, n) = interp1(indi,yi,ind,'linear');
    end
end

%get mean starting values
%apply filter
nsamp = size(data.u, 1);
base = repmat(mean(data.u(1:20, :)), nsamp, 1);
data.ufilt = filter(b, a, data.u-base)+base; %sets the first values to zero
%figure(2); plot(data2.x(:, 11));

%differentiate = dx
data.du = diff(data.ufilt);

%repmat and filter
%differentiate = ddx
nsamp = size(data.du,1);
base = repmat(mean(data.du(1:20,:)),nsamp,1);
data.du_filt = filter(b,a,data.du-base)+base;
%figure(4); plot(data2.dx(:, 11));

data.ddu = diff(data.du_filt);
nsamp = size(data.ddu,1);
base = repmat(mean(data.ddu(1:20,:)),nsamp,1);
data.ddu_filt = filter(b,a,data.ddu-base)+base;

%trace the endpoint marker, if calculating xyz, ignore if calculating angles
if size(data.ddu, 2)>10
    data.tr_acc = data.ddu(:,11);
    data.tr_vel = data.du(:,11);
    data.tr_pos = data.u(:,11);
end
%figure(6); plot(data.ddx(:, 11));

end