%% define file name and loading parameters
filepath = '/Users/mariajantz/Documents/Work/code/proc-maria/plexon_import/files/';
filename = 'A5_20161027';

channel = 16; 

cd(filepath);

[adfreq, n, ts, fn, ad] = plx_ad_v(filename, channel);

plot(ad, '.-')





%% plotting once I have it in .mat format

load([filepath filename '.mat']);

hold off;
start = 1; 
stop = 90000; 
figure(1);
plot(emg_channel_data(1).v); hold on;
%plot(emg_channel_data(2).v+5)
a = axis; 
axis([start stop a(3) a(4)]);
% figure(2); 
% plot(emg_channel_data(12).v)
% a = axis; 
% axis([start stop a(3) a(4)]);