classdef DataManagerPresenter < symphonyui.ui.Presenter
    
    properties (Access = private)
        documentationService
        uuidToNode
    end
    
    methods
        
        function obj = DataManagerPresenter(documentationService, app, view)
            if nargin < 3
                view = symphonyui.ui.views.DataManagerView();
            end
            obj = obj@symphonyui.ui.Presenter(app, view);
            obj.documentationService = documentationService;
            obj.uuidToNode = containers.Map();
        end

    end

    methods (Access = protected)

        function onGoing(obj)
            obj.populateEntityTree();
            
            experiment = obj.documentationService.getCurrentExperiment();
            obj.view.setSelectedNodes(obj.uuidToNode(experiment.uuid));
            obj.populateDetailsWithExperiments(experiment);
            
            obj.updateViewState();
        end
        
        function onBind(obj)
            v = obj.view;
            obj.addListener(v, 'AddSource', @obj.onViewSelectedAddSource);
            obj.addListener(v, 'BeginEpochGroup', @obj.onViewSelectedBeginEpochGroup);
            obj.addListener(v, 'EndEpochGroup', @obj.onViewSelectedEndEpochGroup);
            obj.addListener(v, 'SelectedNodes', @obj.onViewSelectedNodes);
            obj.addListener(v, 'AddProperty', @obj.onViewSelectedAddProperty);
            obj.addListener(v, 'RemoveProperty', @obj.onViewSelectedRemoveProperty);
            obj.addListener(v, 'AddKeyword', @obj.onViewSelectedAddKeyword);
            obj.addListener(v, 'RemoveKeyword', @obj.onViewSelectedRemoveKeyword);
            obj.addListener(v, 'AddNote', @obj.onViewSelectedAddNote);
            obj.addListener(v, 'SendToWorkspace', @obj.onViewSelectedSendToWorkspace);
            obj.addListener(v, 'DeleteEntity', @obj.onViewSelectedDeleteEntity);
            
            d = obj.documentationService;
            obj.addListener(d, 'AddedDevice', @obj.onServiceAddedDevice);
            obj.addListener(d, 'AddedSource', @obj.onServiceAddedSource);
            obj.addListener(d, 'BeganEpochGroup', @obj.onServiceBeganEpochGroup);
            obj.addListener(d, 'EndedEpochGroup', @obj.onServiceEndedEpochGroup);
            obj.addListener(d, 'DeletedEntity', @obj.onServiceDeletedEntity);
        end

    end

    methods (Access = private)
        
        function populateEntityTree(obj)
            experiment = obj.documentationService.getCurrentExperiment();
            
            obj.view.setExperimentNode(experiment.purpose, experiment);
            obj.uuidToNode(experiment.uuid) = obj.view.getExperimentNode();
            
            devices = experiment.devices;
            for i = 1:numel(devices)
                obj.addDeviceNode(devices{i});
            end
            obj.view.expandNode(obj.view.getDevicesFolderNode());
            
            sources = experiment.sources;
            for i = 1:numel(sources)
                obj.addSourceNode(sources{i});
            end
            obj.view.expandNode(obj.view.getSourcesFolderNode());
            
            groups = experiment.epochGroups;
            for i = 1:numel(groups)
                obj.addEpochGroupNode(groups{i});
            end
            obj.view.expandNode(obj.view.getEpochGroupsFolderNode());
        end
        
        function onServiceAddedDevice(obj, ~, event)
            device = event.data;
            node = obj.addDeviceNode(device);
            obj.view.setSelectedNodes(node);
            obj.populateDetailsWithDevices(device);
            obj.updateViewState();
        end
        
        function n = addDeviceNode(obj, device)
            n = obj.view.addDeviceNodeNode(obj.view.getDevicesFolderNode(), device.name, device);
            obj.uuidToNode(device.uuid) = n;
        end
        
        function populateDetailsWithDevices(obj, devices)
            if ~iscell(devices)
                devices = {devices};
            end
            deviceArray = [devices{:}];
            obj.view.setDeviceName(mergeFields({deviceArray.name}));
            obj.view.setDeviceManufacturer(mergeFields({deviceArray.manufacturer}));
            obj.view.setDataCardSelection(obj.view.DEVICE_DATA_CARD);
            
            obj.populateAllAnnotations(devices);
            obj.enableAllAnnotations(true);
        end
        
        function onViewSelectedAddSource(obj, ~, ~)
            presenter = symphonyui.ui.presenters.AddSourcePresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceAddedSource(obj, ~, event)
            source = event.data;
            node = obj.addSourceNode(source);
            obj.view.setSelectedNodes(node);
            obj.view.setSelectedTab(obj.view.PROPERTIES_TAB);
            obj.populateDetailsWithSources(source);
            obj.updateViewState();
        end
        
        function n = addSourceNode(obj, source)
            if isempty(source.parent)
                parent = obj.view.getSourcesFolderNode();
            else
                parent = obj.uuidToNode(source.parent.uuid);
            end
            
            n = obj.view.addSourceNode(parent, source.label, source);
            obj.uuidToNode(source.uuid) = n;
            
            children = source.sources;
            for i = 1:numel(children)
                obj.addSourceNode(children{i});
            end
        end
        
        function populateDetailsWithSources(obj, sources)
            if ~iscell(sources)
                sources = {sources};
            end
            sourceArray = [sources{:}];
            obj.view.setSourceLabel(mergeFields({sourceArray.label}));
            obj.view.setDataCardSelection(obj.view.SOURCE_DATA_CARD);
            
            obj.populateAllAnnotations(sources);
            obj.enableAllAnnotations(true);
        end
        
        function populateDetailsWithExperiments(obj, experiments)
            if ~iscell(experiments)
                experiments = {experiments};
            end
            experimentArray = [experiments{:}];
            obj.view.setExperimentPurpose(mergeFields({experimentArray.purpose}));
            obj.view.setExperimentStartTime(mergeTimes([experimentArray.startTime]));
            obj.view.setExperimentEndTime(mergeTimes([experimentArray.endTime]));
            obj.view.setDataCardSelection(obj.view.EXPERIMENT_DATA_CARD);
            
            obj.populateAllAnnotations(experiments);
            obj.enableAllAnnotations(true);
        end
        
        function onViewSelectedBeginEpochGroup(obj, ~, ~)
            presenter = symphonyui.ui.presenters.BeginEpochGroupPresenter(obj.documentationService, obj.app);
            presenter.goWaitStop();
        end
        
        function onServiceBeganEpochGroup(obj, ~, event)
            group = event.data;
            node = obj.addEpochGroupNode(group);
            obj.view.setSelectedNodes(node);
            obj.view.setEpochGroupNodeCurrent(node);
            obj.view.setSelectedTab(obj.view.PROPERTIES_TAB);
            obj.populateDetailsWithEpochGroups(group);
            obj.updateViewState();
        end
        
        function onViewSelectedEndEpochGroup(obj, ~, ~)
            try
                obj.documentationService.endEpochGroup();
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceEndedEpochGroup(obj, ~, event)
            group = event.data;
            node = obj.uuidToNode(group.uuid);
            obj.view.setSelectedNodes(node);
            obj.view.collapseNode(node);
            obj.view.setEpochGroupNodeNormal(node);
            obj.populateDetailsWithEpochGroups(group);
            obj.updateViewState();
        end
        
        function n = addEpochGroupNode(obj, group)
            if isempty(group.parent)
                parent = obj.view.getEpochGroupsFolderNode();
            else
                parent = obj.uuidToNode(group.parent.uuid);
            end
            
            n = obj.view.addEpochGroupNode(parent, [group.label ' (' group.source.label ')'], group);
            obj.uuidToNode(group.uuid) = n;
            
            children = group.epochGroups;
            for i = 1:numel(children)
                obj.addEpochGroupNode(children{i});
            end
        end
        
        function populateDetailsWithEpochGroups(obj, groups)
            if ~iscell(groups)
                groups = {groups};
            end
            groupArray = [groups{:}];
            sourceArray = [groupArray.source];
            obj.view.setEpochGroupLabel(mergeFields({groupArray.label}));
            obj.view.setEpochGroupStartTime(mergeTimes([groupArray.startTime]));
            obj.view.setEpochGroupEndTime(mergeTimes([groupArray.endTime]));
            obj.view.setEpochGroupSource(mergeFields({sourceArray.label}));
            obj.view.setDataCardSelection(obj.view.EPOCH_GROUP_DATA_CARD);
            
            obj.populateAllAnnotations(groups);
            obj.enableAllAnnotations(true);
        end
        
        function addEpochNode(obj, epoch)
            
        end
        
        function populateDetailsWithEntities(obj, entities)
            if ~iscell(entities)
                entities = {entities};
            end
            obj.view.setDataCardSelection(obj.view.EMPTY_DATA_CARD);
            
            obj.populateAllAnnotations(entities);
            obj.enableAllAnnotations(true);
        end
        
        function onViewSelectedNodes(obj, ~, ~)
            obj.populateDetails();
        end
        
        function populateDetails(obj)
            import symphonyui.ui.views.EntityNodeType;
            
            [entities, types] = obj.getSelectedEntities();
            
            if isempty(types) || any(types == EntityNodeType.NON_ENTITY)
                obj.view.setDataCardSelection(obj.view.EMPTY_DATA_CARD);
                obj.populateAllAnnotations({});
                obj.enableAllAnnotations(false);
                return;
            end
            
            if numel(types) > 1
                obj.populateDetailsWithEntities(entities);
            else
                switch types
                    case EntityNodeType.DEVICE
                        obj.populateDetailsWithDevices(entities);
                    case EntityNodeType.SOURCE
                        obj.populateDetailsWithSources(entities);
                    case EntityNodeType.EXPERIMENT
                        obj.populateDetailsWithExperiments(entities);
                    case EntityNodeType.EPOCH_GROUP
                        obj.populateDetailsWithEpochGroups(entities);
                    case EntityNodeType.EPOCH_BLOCK
                        obj.populateDetailsWithEpochBlocks(entities);
                    case EntityNodeType.EPOCH
                        obj.populateDetailsWithEpochs(entities);
                end
            end
        end
        
        function enableAllAnnotations(obj, tf)
            obj.view.enableProperties(tf);
            obj.view.enableKeywords(tf);
            obj.view.enableNotes(tf);
        end
        
        function populateAllAnnotations(obj, entities)
            obj.populateProperties(entities);
            obj.populateKeywords(entities);
            obj.populateNotes(entities);
        end
        
        function populateProperties(obj, entities)
            if isempty(entities)
                obj.view.setProperties({});
                return;
            end
            
            keys = entities{1}.propertiesMap.keys;
            for i = 2:numel(entities)
                keys = intersect(keys, entities{i}.propertiesMap.keys);
            end
            
            props = cell(1, numel(keys));
            for i = 1:numel(keys)
                k = keys{i};
                v = cell(1, numel(entities));
                for j = 1:numel(entities)
                    v{j} = entities{j}.propertiesMap(k);
                end
                props{i} = {k, mergeFields(v)};
            end
            
            obj.view.setProperties(props);
        end
        
        function onViewSelectedAddProperty(obj, ~, ~)
            entities = obj.getSelectedEntities();
            presenter = symphonyui.ui.presenters.AddPropertyPresenter(entities, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedProperty(obj, ~, event)
            p = event.data;
            values = obj.view.getProperties();
            index = cellfun(@(c)strcmp(c{1}, p.key), values);
            if any(index)
                values{index}{2} = p.value;
                obj.view.setProperties(values);
            else
                obj.view.addProperty(p.key, p.value);
            end
        end
        
        function onViewSelectedRemoveProperty(obj, ~, ~)
            key = obj.view.getSelectedProperty();
            if isempty(key)
                return;
            end
            entities = obj.getSelectedEntities();
            for i = 1:numel(entities)
                entities{i}.removeProperty(key);
            end
        end
        
        function onEntityRemovedProperty(obj, ~, event)
            obj.view.removeProperty(event.data);
        end
        
        function populateKeywords(obj, entities)
            if isempty(entities)
                obj.view.setKeywords({});
                return;
            end
            keywords = entities{1}.keywords;
            for i = 2:numel(entities)
                keywords = intersect(keywords, entities{i}.keywords);
            end
            obj.view.setKeywords(keywords);
        end
        
        function onViewSelectedAddKeyword(obj, ~, ~)
            entities = obj.getSelectedEntities();
            presenter = symphonyui.ui.presenters.AddKeywordPresenter(entities, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedKeyword(obj, ~, event)
            obj.view.addKeyword(event.data);
        end
        
        function onViewSelectedRemoveKeyword(obj, ~, ~)
            keyword = obj.view.getSelectedKeyword();
            if isempty(keyword)
                return;
            end
            entities = obj.getSelectedEntities();
            for i = 1:numel(entities)
                entities{i}.removeKeyword(keyword);
            end
        end
        
        function onEntityRemovedKeyword(obj, ~, event)
            obj.view.removeKeyword(event.data);
        end
        
        function populateNotes(obj, entities)
            if isempty(entities)
                obj.view.setNotes({});
                return;
            end
            
            notes = entities{1}.notes;
            if numel(entities) > 1
                % TODO: merge notes
                notes = {};
            end
            
            values = cell(1, numel(notes));
            for i = 1:numel(notes)
                values{i} = {datestr(notes{i}.time, 14), notes{i}.text};
            end
            obj.view.setNotes(values);
        end
        
        function onViewSelectedAddNote(obj, ~, ~)
            entities = obj.getSelectedEntities();
            presenter = symphonyui.ui.presenters.AddNotePresenter(entities, obj.app);
            presenter.goWaitStop();
        end
        
        function onEntityAddedNote(obj, ~, event)
            note = event.data;
            obj.view.addNote(datestr(note.time, 14), note.text);
        end
        
        function onViewSelectedSendToWorkspace(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            try
                obj.documentationService.sendToWorkspace(entities{1});
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onViewSelectedDeleteEntity(obj, ~, ~)
            entities = obj.getSelectedEntities();
            assert(numel(entities) == 1, 'Expected a single selected entity');
            try
                obj.documentationService.deleteEntity(entities{1});
            catch x
                obj.view.showError(x.message);
                return;
            end
        end
        
        function onServiceDeletedEntity(obj, ~, event)
            uuid = event.data;
            node = obj.uuidToNode(uuid);
            obj.view.setSelectedNodes(get(node, 'Parent'));
            obj.view.removeNode(node);
            obj.uuidToNode.remove(uuid);
            obj.populateDetails();
            obj.updateViewState();
        end
        
        function updateViewState(obj)
            obj.view.enableBeginEpochGroup(~isempty(obj.documentationService.getCurrentExperiment().sources));
            obj.view.enableEndEpochGroup(~isempty(obj.documentationService.getCurrentEpochGroup()));
        end
        
        function [e, t] = getSelectedEntities(obj)
            nodes = obj.view.getSelectedNodes();
            values = [nodes(:).Value];
            if isempty(values)
                e = [];
                t = [];
                return;
            end
            e = {values(:).entity};
            t = unique([values(:).type]);
        end
        
    end

end

function f = mergeFields(fields)
    f = strjoin(unique(fields), ', ');
end

function f = mergeTimes(times)
    fields = cell(1, numel(times));
    for i = 1:numel(times)
        fields{i} = strtrim(datestr(times(i), 14));
    end
    f = mergeFields(fields);
end