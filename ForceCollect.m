classdef ForceCollect < handle
    properties
        calMat %calibration matrix; not sure where it's used but defs necessary
        ai %the analog input object used to collect data
        timer %track timing of each step
        channel_enable = [false(1,5) false(1,11) true(1,6)]; %the last 6 channels are forces and moments - in stimdaq this variable is referred to as EMG_enable
        sample_rate %define the sample rate of collection - default is TODO FIGURE THIS OUT FROM GUI
        samples_per_trigger %how many samples can be collected for each triggered collection - DEFAULT TODO FIGURE OUT FROM GUI
    end
    methods
        function ret = init(obj)
            %TODO load and save the calibration matrix
            %Load Calibration Matrix for Force Transducer (see stimdaq)
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
            
            %set up AI object (takes ~330ms)
            %TODO make ai object a universal part of this class
            daqreset;
            ai = analoginput('nidaq', 'Dev1');
            set(ai,'InputType', 'SingleEnded');
            set(ai.Channel,'InputRange', [-10 10],'SensorRange',[-10 10],'UnitsRange',[-10 10]);
            
            %add only enabled channels:
            %TODO: figure out/update the EMG_enable variable here!!
            
            addchannel(ai,find(obj.channel_enable)-1);
            
            % Setup trigger source as falling edge of an external ditigal signal
            set(ai,'TriggerType','Manual');
            
            % Setup sampling properties of ai object
            set(ai,'SampleRate', obj.sample_rate);
            set(ai,'SamplesPerTrigger', obj.samples_per_trigger);
            set(ai,'LoggingMode', 'Memory');
            pause(0.1);
        end
        
        function ret = start(obj)
            disp('Starting force collection');
            obj.timer = tic;
            start([ai ao]); pause(0.001);
            trigger([ai ao]); %fopen(s);
            %not sure if I should put part of this in the "stop" method??
            wait(ai,(sample_duration*1.25)/1e3);
            data(:,:,trig) = getdata(ai);
        end
        
        function ret = stop(obj)
            disp('Stopping force collection');
            toc(obj.timer);
            stop(ai);
        end
        
        function ret = set_samples(obj, samp_rate, samp_per_trigger)
            disp('Setting sample rate and samples per trigger'); 
            obj.sample_rate = samp_rate; 
            obj.samples_per_trigger = samp_per_trigger; 
            set(ai,'SampleRate', obj.sample_rate);
            set(ai,'SamplesPerTrigger', obj.samples_per_trigger);
        end
    end
end