classdef ForceCollect < handle
    %Maria Jantz, 2017
    properties
        calMat %calibration matrix; not sure where it's used but defs necessary
        ai %the analog input object used to collect data
        timer %track timing of each step
        channel_enable = [false(1,5) false(1,11) true(1,6)]; %the last 6 channels are forces and moments - in stimdaq this variable is referred to as EMG_enable
        sample_rate = 1000; %define the sample rate of collection in Hz - also defined as allvars.freq_daq in stimdaq file
        sample_duration = 3000; %default for single-pulse stim; need to update for stepping values defined as allvars.rec_duration in stimdaq file
        samples_per_trigger; %how many samples can be collected for each triggered collection
        %TODO - add sync signals aq
    end
    methods
        function ret = init(obj)
            %TODO load and save the calibration matrix
            %Load Calibration Matrix for Force Transducer (see stimdaq)
            parentFolder = strcat(fileparts(mfilename('fullpath')), '\control_code\calibration matrices\');
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
            obj.ai = analoginput('nidaq', 'Dev1');
            set(obj.ai,'InputType', 'SingleEnded');
            set(obj.ai.Channel,'InputRange', [-10 10],'SensorRange',[-10 10],'UnitsRange',[-10 10]);
            
            %add only enabled channels:
            %TODO: figure out/update the EMG_enable variable here!!
            
            addchannel(obj.ai,find(obj.channel_enable)-1);
            
            % Setup trigger source as falling edge of an external ditigal signal
            set(obj.ai,'TriggerType','Manual');
            
            obj.samples_per_trigger = floor(obj.sample_duration/1000*obj.sample_rate);
            % Setup sampling properties of ai object
            set(obj.ai,'SampleRate', obj.sample_rate);
            set(obj.ai,'SamplesPerTrigger', obj.samples_per_trigger);
            set(obj.ai,'LoggingMode', 'Memory');
            pause(0.1);
        end
        
        function data = run(obj)
            disp('Starting force collection');
            obj.timer = tic;
            %TODO: deal with the ao signal - that either triggers vicon or
            %the sync signal, not sure which
%             start([obj.ai ao]); pause(0.001);
%             trigger([obj.ai ao]); %fopen(s);
            start([obj.ai]); pause(0.001);
            trigger([obj.ai]); %fopen(s);
            %not sure if I should put part of this in the "stop" method??
            %possible plan: split here into start and stop methods; do not
            %have a wait object so I can go do other things while this data
            %is acquired in the background (control wait time from outside
            %of this) - BUT for early testing use this as one method
            wait(obj.ai,(obj.sample_duration*1.25)/1e3);
            data(:,:) = getdata(obj.ai);

            disp('Stopping force collection');
            toc(obj.timer);
            stop(obj.ai);
        end
        
        
        function ret = start(obj)
            disp('Starting force collection');
            obj.timer = tic;
            %TODO: acquire the signal from the vicon (dv_normal and
            %duration)
            
            %TODO: deal with the ao signal - that either triggers vicon or
            %the sync signal, not sure which
%             start([obj.ai ao]); pause(0.001);
%             trigger([obj.ai ao]); %fopen(s);
            start([obj.ai]); pause(0.001);
            trigger([obj.ai]); %fopen(s);
        end
        
        function data = stop(obj)
            %not sure if I should put part of this in the "stop" method??
            %possible plan: split here into start and stop methods; do not
            %have a wait object so I can go do other things while this data
            %is acquired in the background (control wait time from outside
            %of this) - BUT for early testing use this as one method
            
%             wait(obj.ai,(obj.sample_duration*1.25)/1e3);
            data(:,:) = getdata(obj.ai);

            disp('Stopping force collection');
            toc(obj.timer);
            stop(obj.ai);
        end
        
        function ret = set_samples(obj, samp_duration)
            disp('Setting sample rate and samples per trigger'); 
            obj.sample_duration = samp_duration; 
            obj.samples_per_trigger = floor(obj.sample_duration/1000*obj.sample_rate);
            set(obj.ai,'SamplesPerTrigger', obj.samples_per_trigger);
        end
    end
end