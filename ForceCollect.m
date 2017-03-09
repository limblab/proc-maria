classdef ForceCollect < handle
    properties
        %define and load a calibration matrix
        Value2 = 2;
        timer
        calMat
    end
    methods
        function ret = init(obj)
            %TODO load and save the calibration matrix
            %set up AI object (takes ~330ms)
            daqreset;
            ai = analoginput('nidaq', 'Dev1');
            set(ai,'InputType', 'SingleEnded');
            set(ai.Channel,'InputRange', [-10 10],'SensorRange',[-10 10],'UnitsRange',[-10 10]);
            
            %add only enabled channels:
            %TODO: update the EMG_enable variable here!!
            addchannel(ai,find(EMG_enable)-1);
        end
        
        function ret = start(obj)
            disp('Starting force collection');
            obj.timer = tic;
            ret = obj.Value1;
        end
        
        function ret = stop(obj)
            disp('Stopping force collection');
            toc(obj.timer);
            ret = obj.Value2;
        end
    end
end