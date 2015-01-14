classdef ProtocolParametersView < SymphonyUI.View
    
    events
        SelectedPreset
        Apply
        Revert
    end
    
    properties (Access = private)
        parametersLayout
        presetsPopup
        applyButton
        revertButton
    end
    
    methods
        
        function obj = ProtocolParametersView(parent)
            obj = obj@SymphonyUI.View(parent);
        end
        
        function createUI(obj)
            import SymphonyUI.Utilities.*;
            
            set(obj.figureHandle, 'Name', 'Protocol Parameters');
            set(obj.figureHandle, 'Position', screenCenter(326, 326));
            
            mainLayout = uiextras.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 7);
            
            obj.parametersLayout = uiextras.VBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            
            % Apply/Revert controls.
            layout = uiextras.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            uiLabel(layout, 'Presets:');
            obj.presetsPopup = uiPopupMenu(layout, {'', 'Default', 'Preset1'});
            set(obj.presetsPopup, 'Callback', @(h,d)notify(obj, 'SelectedPreset'));
            uiextras.Empty('Parent', layout);
            obj.applyButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', 'Apply', ...
                'Callback', @(h,d)notify(obj, 'Apply'));
            obj.revertButton = uicontrol( ...
                'Parent', layout, ...
                'Style', 'pushbutton', ...
                'String', 'Revert', ...
                'Callback', @(h,d)notify(obj, 'Revert'));
            set(layout, 'Sizes', [42 75 -1 75 75]);
            
            set(mainLayout, 'Sizes', [-1 25]);
            
            % Set apply button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.applyButton);
            end
        end
        
        function addParameter(obj, name)
            import SymphonyUI.Utilities.*;
            
            layout = uiextras.HBox( ...
                'Parent', obj.parametersLayout);
            uiLabel(layout, name);
            uicontrol( ...
                'Parent', layout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            uiextras.Empty('Parent', layout);
            set(layout, 'Sizes', [-3 -5 -2]);
            
            sizes = get(obj.parametersLayout, 'Sizes');
            sizes(end) = 25;
            set(obj.parametersLayout, 'Sizes', sizes);
        end
        
        function clearParameters(obj)
            delete(get(obj.parametersLayout, 'Children'));
        end
        
        function p = getPreset(obj)
            p = SymphonyUI.Utilities.getSelectedUIValue(obj.presetsPopup);
        end
        
    end
    
end
