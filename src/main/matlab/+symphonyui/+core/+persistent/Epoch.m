classdef Epoch < symphonyui.core.persistent.TimelineEntity

    properties (SetAccess = private)
        protocolParameters
        epochBlock
    end

    methods

        function obj = Epoch(cobj)
            obj@symphonyui.core.persistent.TimelineEntity(cobj);
        end

        function p = get.protocolParameters(obj)
            p = obj.mapFromKeyValueEnumerable(obj.cobj.ProtocolParameters, @obj.valueFromPropertyValue);
        end

        function r = getResponses(obj)
            r = obj.cellArrayFromEnumerable(obj.cobj.Responses, @symphonyui.core.persistent.Response);
        end

        function m = getResponseMap(obj)
            m = containers.Map();
            r = obj.getResponses();
            for i = 1:numel(r)
                m(r{i}.device.name) = r{i};
            end
        end

        function s = getStimuli(obj)
            s = obj.cellArrayFromEnumerable(obj.cobj.Stimuli, @symphonyui.core.persistent.Stimulus);
        end

        function m = getStimulusMap(obj)
            m = containers.Map();
            s = obj.getStimuli();
            for i = 1:numel(s)
                m(s{i}.device.name) = s{i};
            end
        end

        function b = getBackgrounds(obj)
            b = obj.cellArrayFromEnumerable(obj.cobj.Backgrounds, @symphonyui.core.persistent.Background);
        end

        function b = get.epochBlock(obj)
            b = symphonyui.core.persistent.EpochBlock(obj.cobj.EpochBlock);
        end

        function t = getEntityType(obj) %#ok<MANU>
            t = symphonyui.core.persistent.EntityType.EPOCH;
        end

    end

end
