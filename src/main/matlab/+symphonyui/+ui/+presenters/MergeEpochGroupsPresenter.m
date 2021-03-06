classdef MergeEpochGroupsPresenter < appbox.Presenter
    
    properties (Access = private)
        log
        enables
        documentationService
        initialGroup1
    end
    
    methods
        
        function obj = MergeEpochGroupsPresenter(documentationService, initialGroup1, view)
            if nargin < 2
                initialGroup1 = [];
            end
            if nargin < 3
                view = symphonyui.ui.views.MergeEpochGroupsView();
            end            
            obj = obj@appbox.Presenter(view);
            obj.view.setWindowStyle('modal');
            
            obj.log = log4m.LogManager.getLogger(class(obj));
            obj.enables = symphonyui.ui.util.trueStruct('selectGroup1', 'selectGroup2', 'merge', 'cancel');
            obj.documentationService = documentationService;
            obj.initialGroup1 = initialGroup1;
        end
        
    end
    
    methods (Access = protected)

        function willGo(obj)
            obj.populateGroup1List();
            obj.populateGroup2List();
        end
        
        function didGo(obj)
            obj.selectGroup1(obj.initialGroup1);
        end

        function bind(obj)
            bind@appbox.Presenter(obj);

            v = obj.view;
            obj.addListener(v, 'KeyPress', @obj.onViewKeyPress);
            obj.addListener(v, 'SelectedGroup1', @obj.onViewSelectedGroup1);
            obj.addListener(v, 'Merge', @obj.onViewSelectedMerge);
            obj.addListener(v, 'Cancel', @obj.onViewSelectedCancel);
        end

    end
    
    methods (Access = private)
        
        function populateGroup1List(obj)
            groups = obj.documentationService.getExperiment().getAllEpochGroups();
            
            names = cell(1, numel(groups));
            for i = 1:numel(groups)
                group = groups{i};
                names{i} = [group.label ' (' group.source.label ') [' datestr(group.startTime, 15) ']'];
            end
            
            if numel(groups) > 0
                obj.view.setGroup1List(names, groups);
            else
                obj.view.setGroup1List({'(None)'}, {[]});
            end
            
            obj.enables.selectGroup1 = ~isempty(groups);
            obj.view.enableSelectGroup1(obj.enables.selectGroup1);
        end
        
        function selectGroup1(obj, group)
            obj.view.setSelectedGroup1(group);
            obj.populateGroup2List();
            obj.updateStateOfControls();
        end
        
        function populateGroup2List(obj)
            group1 = obj.view.getSelectedGroup1();
            parent = group1.parent;
            if isempty(parent)
                g = obj.documentationService.getExperiment().getEpochGroups();
            else
                g = parent.getEpochGroups();
            end
            index = find(cellfun(@(g)g == group1, g), 1);
            groups = {};
            if index > 1
                groups{end + 1} = g{index - 1};
            end
            if index < numel(g)
                groups{end + 1} = g{index + 1};
            end
            
            names = cell(1, numel(groups));
            for i = 1:numel(groups)
                group = groups{i};
                names{i} = [group.label ' (' group.source.label ') [' datestr(group.startTime, 15) ']'];
            end
            
            if numel(groups) > 0
                obj.view.setGroup2List(names, groups);
            else
                obj.view.setGroup2List({'(None)'}, {[]});
            end
            
            obj.enables.selectGroup2 = ~isempty(groups);
            obj.view.enableSelectGroup2(obj.enables.selectGroup2);
        end
        
        function onViewKeyPress(obj, ~, event)
            switch event.data.Key
                case 'return'
                    if obj.view.getEnableMerge()
                        obj.onViewSelectedMerge();
                    end
                case 'escape'
                    obj.onViewSelectedCancel();
            end
        end

        function onViewSelectedGroup1(obj, ~, ~)
            obj.selectGroup1(obj.view.getSelectedGroup1());
        end
        
        function onViewSelectedMerge(obj, ~, ~)
            obj.view.update();
            
            group1 = obj.view.getSelectedGroup1();
            group2 = obj.view.getSelectedGroup2();
            try
                obj.disableControls();
                obj.view.startSpinner();
                obj.view.update();
                
                merged = obj.documentationService.mergeEpochGroups(group1, group2);
            catch x
                obj.log.debug(x.message, x);
                obj.view.showError(x.message);
                obj.view.stopSpinner();
                obj.updateStateOfControls();
                return;
            end
            
            obj.result = merged;
            obj.stop();
        end
        
        function onViewSelectedCancel(obj, ~, ~)
            obj.stop();
        end
        
        function disableControls(obj)
            obj.view.enableSelectGroup1(false);
            obj.view.enableSelectGroup2(false);
            obj.view.enableMerge(false);
            obj.view.enableCancel(false);
        end

        function updateStateOfControls(obj)
            group2List = obj.view.getGroup2List();
            hasGroup2 = ~isempty(group2List{1});
            
            obj.view.enableSelectGroup1(obj.enables.selectGroup1);
            obj.view.enableSelectGroup2(obj.enables.selectGroup2);
            obj.view.enableMerge(hasGroup2 && obj.enables.merge);
            obj.view.enableCancel(obj.enables.cancel);
        end
        
    end
    
end

