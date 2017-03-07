%% from stimdaq: Load Calibration Matrix for Force Transducer
parentFolder = strcat(fileparts(mfilename('fullpath')),'\calibration matrices\');
calMat = load(strcat(parentFolder, 'newCal'));
calMat = calMat';
% Make new folder to store calibration matrix (labeled with current date)
folderName = strcat(date,' isometric data');
if ~exist(strcat(parentFolder, folderName), 'dir')
    mkdir(parentFolder, folderName);
end
saveFilename_calmat = strcat(parentFolder,folderName,'\cal_mat_',date);
% Save calibration matrix
save(saveFilename_calmat,'calMat','-mat');


%% Setup the ai object

% Reset to a known state and populate AI (takes ~330ms)
% Perhaps just use ai = daqfind and flushdata(ai,'all').
daqreset;
%     ai = analoginput('nidaq', 'Dev2');
ai = analoginput('nidaq', 'Dev1');
set(ai,'InputType', 'SingleEnded');
set(ai.Channel,'InputRange', [-10 10],'SensorRange',[-10 10],'UnitsRange',[-10 10]);

%add only enabled channels:
addchannel(ai,find(EMG_enable)-1);

% Setup trigger source as falling edge of an external ditigal signal
set(ai,'TriggerType','Manual');

% Setup sampling properties of ai object
set(ai,'SampleRate', sample_rate);
set(ai,'SamplesPerTrigger', samples_per_trigger);
set(ai,'LoggingMode', 'Memory');
pause(0.1);


%% other stuff

start([ai ao]); pause(0.001);
trigger([ai ao]); %fopen(s);
wait(ai,(sample_duration*1.25)/1e3);
data(:,:,trig) = getdata(ai);

% -------------------------------------------------------------
% Plot raw forces, force endpoint vectors, AND point on recruitment curves
plot_forces(data,sample_rate,trig,handles,EMG_labels,EMG_enable,calMat);
% -------------------------------------------------------------


stop(ai);


