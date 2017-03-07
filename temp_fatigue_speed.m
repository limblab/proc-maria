%locate rat file
filedate = '161006';
trnum = [21 3 4 5]; %full stance
%trnum = [7:10]; %2/3 stance
%trnum = [11:14]; %1/3 stance
path = ['/Users/mariajantz/Documents/Work/data/kinematics/processed/'];
load('161006_stats.mat');

ratMks  = {'spine_top','spine_bottom','hip_top', 'hip_middle', 'hip_bottom', ...
    'femur_mid', 'knee', 'tibia_mid', 'heel', 'foot_mid', 'toe', 'reference_a', 'reference_p'};

xrange = {};
yrange = {};
magrange = {};

for i=1:length(trnum)
    %import the processed rat
    load([path filedate '_' num2str(trnum(i), '%02d') '_rat.mat']);
    
    %import the swing time data from collate_stats
    sw_time_ind = cellfun(@(x) isempty(strfind(x, [filedate '_' num2str(trnum(i), '%02d')])), trialname, 'UniformOutput', false);
    idx(i) = find([sw_time_ind{:}] == 0);
    %now use that index to get the swing time data
    %for each swing time except the last one, get the maximum range of x
    %and y between that swing time and the beginning of the next one. Then
    %compare the magnitude of those ranges (that gives a measure of
    %fatigue). Then compare that to other trials in trnum.
    swing_set = swing_time_idx{idx(i)};
    for j=1:9
        xrange{i}(j) = range(rat.toe(swing_set{j}(1):swing_set{j+1}(1), 1));
        yrange{i}(j) = range(rat.toe(swing_set{j}(1):swing_set{j+1}(1), 2));
        magrange{i}(j) = sqrt(xrange{i}(j)^2 + yrange{i}(j)^2);
    end
    
end

figure; hold on;
colorred = [[128, 0, 0]; [230, 0, 0]; [255, 77, 77]; [255, 153, 153]]/255; 
colorblue = [[0, 0, 102]; [0, 0, 204]; [77, 77, 255]; [153, 153, 255]]/255; 
colorgreen = [[0, 77, 0]; [0, 128, 0]; [0, 204, 0]; [128, 255, 128]]/255;

h = []; 
for i=1:length(magrange)
    if i==2
        h(end+1) = plot(magrange{i}, 'LineWidth', 4, 'color', colorred(i, :));
    else
        plot(magrange{i}, 'LineWidth', 4, 'color', colorred(i, :));
    end
end

title('Fatigue, full stance');
ylabel('Magnitude of movement (mm)');
xlabel('Step');
set(gca, 'fontsize', 24);
set(gca,'TickDir','out')
xlim([1 9]); 
ylim([0 80]); 

%legend(h, {'full stance', '2/3 stance', '1/3 stance'});


