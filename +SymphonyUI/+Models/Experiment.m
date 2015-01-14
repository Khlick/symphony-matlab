classdef Experiment < handle
    
    events
        BeganEpochGroup
        EndedEpochGroup
    end
    
    properties
        path
        rig
        purpose
        source
        epochGroup
    end
    
    methods
        
        function obj = Experiment(path, rig, purpose, source)
            obj.path = path;
            obj.rig = rig;
            obj.purpose = purpose;
            obj.source = source;
        end
        
        function open(obj)
            
        end
        
        function close(obj)
            
        end
        
        function addNote(obj, note)
            disp(['Add Note: ' note]);
        end
        
        function beginEpochGroup(obj, label, source, keywords, attributes)
            disp(['Begin Epoch Group: ' label]);
            obj.epochGroup = SymphonyUI.Models.EpochGroup(label, source, keywords, attributes);
            notify(obj, 'BeganEpochGroup');
        end
        
        function endEpochGroup(obj)
            disp(['End Epoch Group: ' obj.epochGroup.label]);
            obj.epochGroup = obj.epochGroup.parent;
            notify(obj, 'EndedEpochGroup');
        end
        
    end
    
end
