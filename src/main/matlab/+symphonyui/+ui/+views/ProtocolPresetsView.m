classdef ProtocolPresetsView < appbox.View
    
    events
        ViewOnlyPreset
        RecordPreset
        ApplyPreset
        AddPreset
        RemovePreset
    end
    
    properties (Access = private)
        presetsTable
        viewOnlyButton
        recordButton
        applyButton
        addButton
        removeButton
    end
    
    methods
        
        function createUi(obj)
            import appbox.*;
            
            set(obj.figureHandle, ...
                'Name', 'Protocol Presets', ...
                'Position', screenCenter(230, 300));
            
            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Spacing', 1);
            
            obj.presetsTable = appbox.Table( ...
                'Parent', mainLayout, ...
                'ColumnName', {'Preset'}, ...
                'BorderType', 'none', ...
                'Editable', false);
            
            % Presets toolbar.
            presetsToolbarLayout = uix.HBox( ...
                'Parent', mainLayout);
            obj.viewOnlyButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/view_only.png'), ...
                'Callback', @(h,d)notify(obj, 'ViewOnlyPreset'));
            obj.recordButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/record.png'), ...
                'Callback', @(h,d)notify(obj, 'RecordPreset'));
            obj.applyButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/apply.png'), ...
                'Callback', @(h,d)notify(obj, 'ApplyPreset'));
            uix.Empty('Parent', presetsToolbarLayout);
            obj.addButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/add.png'), ...
                'Callback', @(h,d)notify(obj, 'AddPreset'));
            obj.removeButton = Button( ...
                'Parent', presetsToolbarLayout, ...
                'Icon', symphonyui.app.App.getResource('icons/remove.png'), ...
                'Callback', @(h,d)notify(obj, 'RemovePreset'));
            set(presetsToolbarLayout, 'Widths', [22 22 22 -1 22 22]);
            
            set(mainLayout, 'Heights', [-1 22]);
        end
        
        function show(obj)
            show@appbox.View(obj);
            set(obj.presetsTable, 'ColumnHeaderVisible', false);
            set(obj.presetsTable, 'RowHeight', 40);
        end
        
        function enableViewOnlyPreset(obj, tf)
            set(obj.viewOnlyButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableRecordPreset(obj, tf)
            set(obj.recordButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableApplyPreset(obj, tf)
            set(obj.applyButton, 'Enable', appbox.onOff(tf));
        end
        
        function addPreset(obj, preset)
            obj.presetsTable.addRow(preset);
        end
        
        function enableRemovePreset(obj, tf)
            set(obj.removeButton, 'Enable', appbox.onOff(tf));
        end
        
        function removePreset(obj, preset)
            presets = obj.presetsTable.getColumnData(1);
            index = find(cellfun(@(c)strcmp(c, preset), presets));
            obj.presetsTable.removeRow(index); %#ok<FNDSB>
        end
        
        function p = getSelectedPreset(obj)
            row = get(obj.presetsTable, 'SelectedRow');
            p = obj.presetsTable.getValueAt(row, 1);
        end
        
    end
    
end
