classdef NewFileView < appbox.View

    events
        BrowseLocation
        Ok
        Cancel
    end

    properties (Access = private)
        nameField
        locationField
        browseLocationButton
        descriptionPopupMenu
        spinner
        okButton
        cancelButton
    end

    methods

        function createUi(obj)
            import appbox.*;

            set(obj.figureHandle, ...
                'Name', 'New File', ...
            	'Position', screenCenter(500, 139), ...
                'Resize', 'off');

            mainLayout = uix.VBox( ...
                'Parent', obj.figureHandle, ...
                'Padding', 11, ...
                'Spacing', 11);

            fileLayout = uix.Grid( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            Label( ...
                'Parent', fileLayout, ...
                'String', 'Name:');
            Label( ...
                'Parent', fileLayout, ...
                'String', 'Location:');
            Label( ...
                'Parent', fileLayout, ...
                'String', 'Description:');
            obj.nameField = uicontrol( ...
                'Parent', fileLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.locationField = uicontrol( ...
                'Parent', fileLayout, ...
                'Style', 'edit', ...
                'HorizontalAlignment', 'left');
            obj.descriptionPopupMenu = MappedPopupMenu( ...
                'Parent', fileLayout, ...
                'String', {' '}, ...
                'HorizontalAlignment', 'left');
            uix.Empty('Parent', fileLayout);
            obj.browseLocationButton = uicontrol( ...
                'Parent', fileLayout, ...
                'Style', 'pushbutton', ...
                'String', '...', ...
                'Callback', @(h,d)notify(obj, 'BrowseLocation'));
            uix.Empty('Parent', fileLayout);
            set(fileLayout, ...
                'Widths', [65 -1 23], ...
                'Heights', [23 23 23]);
            
            % OK/Cancel controls.
            controlsLayout = uix.HBox( ...
                'Parent', mainLayout, ...
                'Spacing', 7);
            spinnerLayout = uix.VBox( ...
                'Parent', controlsLayout);
            uix.Empty('Parent', spinnerLayout);
            obj.spinner = com.mathworks.widgets.BusyAffordance();
            javacomponent(obj.spinner.getComponent(), [], spinnerLayout);
            set(spinnerLayout, 'Heights', [4 -1]);
            uix.Empty('Parent', controlsLayout);
            obj.okButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'OK', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Ok'));
            obj.cancelButton = uicontrol( ...
                'Parent', controlsLayout, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Interruptible', 'off', ...
                'Callback', @(h,d)notify(obj, 'Cancel'));
            set(controlsLayout, 'Widths', [16 -1 75 75]);

            set(mainLayout, 'Heights', [-1 23]);

            % Set OK button to appear as the default button.
            try %#ok<TRYNC>
                h = handle(obj.figureHandle);
                h.setDefaultButton(obj.okButton);
            end
        end

        function enableOk(obj, tf)
            set(obj.okButton, 'Enable', appbox.onOff(tf));
        end
        
        function tf = getEnableOk(obj)
            tf = appbox.onOff(get(obj.okButton, 'Enable'));
        end
        
        function enableCancel(obj, tf)
            set(obj.cancelButton, 'Enable', appbox.onOff(tf));
        end
        
        function enableName(obj, tf)
            set(obj.nameField, 'Enable', appbox.onOff(tf));
        end

        function n = getName(obj)
            n = get(obj.nameField, 'String');
        end

        function setName(obj, n)
            set(obj.nameField, 'String', n);
        end

        function requestNameFocus(obj)
            obj.update();
            uicontrol(obj.nameField);
        end
        
        function enableLocation(obj, tf)
            set(obj.locationField, 'Enable', appbox.onOff(tf));
        end

        function l = getLocation(obj)
            l = get(obj.locationField, 'String');
        end

        function setLocation(obj, l)
            set(obj.locationField, 'String', l);
        end
        
        function enableBrowseLocation(obj, tf)
            set(obj.browseLocationButton, 'Enable', appbox.onOff(tf));
        end

        function enableSelectDescription(obj, tf)
            set(obj.descriptionPopupMenu, 'Enable', appbox.onOff(tf));
        end

        function t = getSelectedDescription(obj)
            t = get(obj.descriptionPopupMenu, 'Value');
        end

        function setSelectedDescription(obj, t)
            set(obj.descriptionPopupMenu, 'Value', t);
        end

        function l = getDescriptionList(obj)
            l = get(obj.descriptionPopupMenu, 'Values');
        end

        function setDescriptionList(obj, names, values)
            set(obj.descriptionPopupMenu, 'String', names);
            set(obj.descriptionPopupMenu, 'Values', values);
        end
        
        function startSpinner(obj)
            obj.spinner.start();
        end
        
        function stopSpinner(obj)
            obj.spinner.stop();
        end

    end

end
