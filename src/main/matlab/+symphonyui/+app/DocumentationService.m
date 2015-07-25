classdef DocumentationService < handle

    events (NotifyAccess = private)
        OpenedFile
        ClosedFile
        AddedDevice
        AddedSource
        BeganEpochGroup
        EndedEpochGroup
        BeganEpochBlock
        EndedEpochBlock
        DeletedEntity
    end
    
    properties (Access = private)
        sessionData
        persistorFactory
        sourceDescriptionRepository
    end

    methods
        
        function obj = DocumentationService(sessionData, persistorFactory, sourceDescriptionRepository)
            obj.sessionData = sessionData;
            obj.persistorFactory = persistorFactory;
            obj.sourceDescriptionRepository = sourceDescriptionRepository;
        end
        
        function tf = hasOpenFile(obj)
            tf = obj.hasSessionPersistor();
        end
        
        function newFile(obj, name, location)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.sessionData.persistor = obj.persistorFactory.new(name, location);
            notify(obj, 'OpenedFile');
        end
        
        function openFile(obj, path)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.sessionData.persistor = obj.persistorFactory.open(path);
            notify(obj, 'OpenedFile');
        end
        
        function closeFile(obj)
            obj.getSessionPersistor().close();
            obj.sessionData.persistor = [];
            notify(obj, 'ClosedFile');
        end
        
        function e = getCurrentExperiment(obj)
            e = obj.getSessionPersistor().experiment;
        end
        
        function d = addDevice(obj, name, manufacturer)
            d = obj.getSessionPersistor().addDevice(name, manufacturer);
            notify(obj, 'AddedDevice', symphonyui.app.util.AppEventData(d));
        end
        
        function d = getAvailableSourceDescriptions(obj)
            d = obj.sourceDescriptionRepository.getAll();
        end
        
        function s = addSource(obj, description, parent)
            if isempty(description)
                description = 'Source';
            end
            s = obj.getSessionPersistor().addSource(description, parent);
            notify(obj, 'AddedSource', symphonyui.app.util.AppEventData(s));
        end
        
        function tf = canBeginEpochGroup(obj)
            tf = obj.hasOpenFile() && ~isempty(obj.getCurrentExperiment().sources);
        end
        
        function g = beginEpochGroup(obj, label, source)
            g = obj.getSessionPersistor().beginEpochGroup(label, source);
            notify(obj, 'BeganEpochGroup', symphonyui.app.util.AppEventData(g));
        end
        
        function tf = canEndEpochGroup(obj)
            tf = obj.hasOpenFile() && ~isempty(obj.getCurrentEpochGroup());
        end
        
        function g = endEpochGroup(obj)
            g = obj.getSessionPersistor().endEpochGroup();
            notify(obj, 'EndedEpochGroup', symphonyui.app.util.AppEventData(g));
        end
        
        function g = getCurrentEpochGroup(obj)
            g = obj.getSessionPersistor().currentEpochGroup;
        end
        
        function deleteEntity(obj, entity)
            uuid = entity.uuid;
            obj.getSessionPersistor().deleteEntity(entity);
            notify(obj, 'DeletedEntity', symphonyui.app.util.AppEventData(uuid));
        end
        
        function sendToWorkspace(obj, entity) %#ok<INUSL>
            % TODO: use a unique name so it doesn't overwrite existing var
            assignin('base', 'entity', entity);
            evalin('base', 'disp([''entity = '' class(entity)])');
        end
        
    end
    
    methods (Access = private)
        
        function p = getSessionPersistor(obj)
            if ~obj.hasSessionPersistor()
                error('No session protocol');
            end
            p = obj.sessionData.persistor;
        end
        
        function tf = hasSessionPersistor(obj)
            tf = ~isempty(obj.sessionData.persistor) && ~obj.sessionData.persistor.isClosed;
        end
        
    end

end
