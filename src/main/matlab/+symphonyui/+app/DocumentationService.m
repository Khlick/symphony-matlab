classdef DocumentationService < handle

    events (NotifyAccess = private)
        CreatedFile
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
        session
        persistorFactory
        fileDescriptionRepository
        sourceDescriptionRepository
        epochGroupDescriptionRepository
    end

    methods
        
        function obj = DocumentationService(session, persistorFactory, fileDescriptionRepository, sourceDescriptionRepository, epochGroupDescriptionRespository)
            obj.session = session;
            obj.persistorFactory = persistorFactory;
            obj.fileDescriptionRepository = fileDescriptionRepository;
            obj.sourceDescriptionRepository = sourceDescriptionRepository;
            obj.epochGroupDescriptionRepository = epochGroupDescriptionRespository;
        end
        
        function d = getAvailableFileDescriptions(obj)
            d = obj.fileDescriptionRepository.getAll();
        end
        
        function newFile(obj, name, location, description)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.session.persistor = obj.persistorFactory.new(name, location, description);
            notify(obj, 'CreatedFile');
        end
        
        function openFile(obj, path)
            if obj.hasOpenFile()
                error('File already open');
            end
            obj.session.persistor = obj.persistorFactory.open(path);
            notify(obj, 'OpenedFile');
        end
        
        function closeFile(obj)
            obj.session.getPersistor().close();
            obj.session.persistor = [];
            notify(obj, 'ClosedFile');
        end
        
        function tf = hasOpenFile(obj)
            tf = obj.session.hasPersistor();
        end
        
        function e = getExperiment(obj)
            e = obj.session.getPersistor().experiment;
        end
        
        function d = addDevice(obj, name, manufacturer)
            d = obj.session.getPersistor().addDevice(name, manufacturer);
            notify(obj, 'AddedDevice', symphonyui.app.AppEventData(d));
        end
        
        function d = getAvailableSourceDescriptions(obj)
            d = obj.sourceDescriptionRepository.getAll();
        end
        
        function s = addSource(obj, parent, description)
            s = obj.session.getPersistor().addSource(parent, description);
            notify(obj, 'AddedSource', symphonyui.app.AppEventData(s));
        end
        
        function d = getAvailableEpochGroupDescriptions(obj)
            d = obj.epochGroupDescriptionRepository.getAll();
        end
        
        function g = beginEpochGroup(obj, source, description)
            g = obj.session.getPersistor().beginEpochGroup(source, description);
            notify(obj, 'BeganEpochGroup', symphonyui.app.AppEventData(g));
        end
        
        function g = endEpochGroup(obj)
            g = obj.session.getPersistor().endEpochGroup();
            notify(obj, 'EndedEpochGroup', symphonyui.app.AppEventData(g));
        end
        
        function g = getCurrentEpochGroup(obj)
            g = obj.session.getPersistor().currentEpochGroup;
        end
        
        function deleteEntity(obj, entity)
            uuid = entity.uuid;
            obj.session.getPersistor().deleteEntity(entity);
            notify(obj, 'DeletedEntity', symphonyui.app.AppEventData(uuid));
        end
        
        function sendToWorkspace(obj, entity) %#ok<INUSL>
            name = matlab.lang.makeValidName(entity.uuid);
            assignin('base', name, entity);
            evalin('base', ['disp(''' name ' = ' class(entity) ''')']);
        end
        
    end

end
