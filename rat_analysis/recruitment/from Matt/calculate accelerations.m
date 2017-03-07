clear
run('C:\Users\mct519\Documents\My Files\Data Analyses\Neilsen\Maria experiments\OPTIONS_CONFIG.m');
rootstr = 'bfarun2_'
% rootstr = '161105'
cutoff = 50;

for ii = 1:10
    if ii < 10
        fname = [rootstr '0' num2str(ii) '.csv'];
    else
        fname = [rootstr num2str(ii) '.csv'];
    end
    data = read_vicon_file(fname,OPTS,OPTS);
    [b,a] = butter(4,cutoff/100);
    data2 = data;
    
    nsamp = size(data2.x,1);
    base = repmat(mean(data2.x(1:20,:)),nsamp,1);
    data2.x = filter(b,a,data2.x-base);
    base = repmat(mean(data2.y(1:20,:)),nsamp,1);
    data2.y = filter(b,a,data2.y-base);
    base = repmat(mean(data2.z(1:20,:)),nsamp,1);
    data2.z = filter(b,a,data2.z-base);
    
    data.dx = diff(data2.x);
    data.dy = diff(data2.y);
    data.dz = diff(data2.z);
    
%     data2 = data;
    nsamp = size(data.dx,1);
    base = repmat(mean(data.dx(1:20,:)),nsamp,1);
    data2.dx = filter(b,a,data.dx-base)+base;
    base = repmat(mean(data.dy(1:20,:)),nsamp,1);
    data2.dy = filter(b,a,data.dy-base)+base;
    base = repmat(mean(data.dz(1:20,:)),nsamp,1);
    data2.dz = filter(b,a,data.dz-base)+base;
    
    data.ddx = diff(data2.dx);
    data.ddy = diff(data2.dy);
    data.ddz = diff(data2.dz);

%     tracex(ii,1:nsamp-1) = sum(data.ddx,2);
%     tracey(ii,1:nsamp-1) = sum(data.ddy,2);
%     tracez(ii,1:nsamp-1) = sum(data.ddz,2);
    traceddx(ii,1:nsamp-1) = data.ddx(:,11);
    traceddy(ii,1:nsamp-1) = data.ddy(:,11);
    traceddz(ii,1:nsamp-1) = data.ddz(:,11);

    tracedx(ii,1:nsamp) = data.dx(:,11);
    tracedy(ii,1:nsamp) = data.dy(:,11);
    tracedz(ii,1:nsamp) = data.dz(:,11);

    tracex(ii,1:nsamp+1) = data.x(:,11);
    tracey(ii,1:nsamp+1) = data.y(:,11);
    tracez(ii,1:nsamp+1) = data.z(:,11);
    trace(ii,1:nsamp-1) = sqrt(data.ddx(:,11).^2 + data.ddy(:,11).^2 + data.ddz(:,11).^2); 
end

kintime = (1:(length(tracex)))/200*1000;
subplot(3,1,1)
nsamp = length(data.x);
plot(kintime(1:nsamp-1),data2.x(1:nsamp-1,end)')
subplot(3,1,2)
plot(kintime(1:nsamp-1),data2.dx(1:nsamp-1,end)')
subplot(3,1,3)
plot(kintime(1:nsamp-2),data.ddx(1:nsamp-2,end)')


%%
cutoff = 499.99;
load ST
[b,a] = butter(4,cutoff/1000);  
alldata = out_struct.data;
ntrials = length(alldata);
for ii = 1:ntrials
    temp = alldata{ii};
    fdata = temp(:,8:13)*out_struct.calmat;
    nsamp = size(fdata,1);
    base = repmat(mean(fdata(1:400,:)),nsamp,1);
    fdata = filtfilt(b,a,fdata-base);
    fmag = sqrt(fdata(:,1).^2 + fdata(:,2).^2 + fdata(:,3).^2);    
    ang = atan2(fdata(:,2),fdata(:,1));
    ang2 = atan2(fdata(:,3),fdata(:,1));
    allmag(ii,:) = fmag;
    allang(ii,:) = ang;
    allang2(ii,:) = ang2;
end

ind = find(out_struct.is_active);
currents = out_struct.base_amp(ind)*out_struct.modulation_channel_multipliers;

forcetime = (1:nsamp)/2000*1000;


