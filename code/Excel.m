% Excel class with objects representing the information for a given template
% spreadsheet
classdef Excel
    properties
        % Coordinates is a cell array of different template variable names
        % and their coordinates in the form of {sheet number, row, col}. (A
        % few variables have multiple coordinates.) 
        coordinates;
        % Sheets is an array of raw data from four main sheets in template
        sheets;
        % Save the inputted filepath
        filepath;
    end
    methods
        % Constuctor with filepath of template and optional coordinates
        % property as inputs
        function obj = Excel(file, coords)
            obj.filepath = file;
            % Read in Excel for information, Experiment sheet
            [~,~,s1] = xlsread(file, 'Experiment');
            % Read in Excel for information, Samples sheet
            [~,~,s2] = xlsread(file, 'Samples');
            % Read in Excel for information, Calibration sheet
            [~,~,s3] = xlsread(file, 'Calibration');
            % Read in Excel for information, Additional Settings sheet
            [~,~,s4] = xlsread(file, 'Optional Settings');
            obj.sheets = {s1, s2, s3, s4};
            if nargin < 2
                obj.coordinates = {...
                    {'experimentName', {1, 5, 1}}
                    {'first_filename_template', {1, 16, 5}}
                    {'first_condition_key', {1, 16, 1}}
                    % TODO NEED TO UPDATE COORDS BELOW
                    {'first_sample_num', {2, 3, 1}}
                    {'first_sample_dox', {2, 3, 3}} % TODO: will need to generalize further
                    {'first_sample_template', {2, 3, 8}}
                    {'first_sample_name', {2, 3, 2}}
                    % {'first_sample_filename', {2, 3, 12}}
                    {'first_sample_exclude', {2, 3, 10}}
                    {'inputName_CM', {2, 28, 3}}
                    {'OutputSettings.StemName', {2, 28, 4}}
                    {'binseq_min', {2, 28, 9}}
                    {'binseq_pdecade', {2, 28, 10}}
                    {'binseq_max', {2, 28, 11}}
                    {'minValidCount', {2, 28, 6}}
                    {'autofluorescence', {2, 28, 7}}
                    {'minFracActive', {2, 28, 8}}
                    {'outputName_BA', {2, 28, 5}}
                    {'beads.beadModel', {3, 3, 2}}
                    {'plots.plotPath', {{3, 22, 1}, {2, 28, 2}}}
                    {'beads.beadBatch', {3, 3, 1}}
                    {'beads.rangeMin', {3, 3, 3}}
                    {'beads.rangeMax', {3, 3, 4}}
                    {'beads.peakThreshold', {3, 3, 5}}
                    {'beads.beadChannel', {3, 3, 6}}
                    {'beads.secondaryBeadChannel', {3, 22, 2}}
                    {'relevant_channels', {3, 19, 2}}
                    {'transChannelMin', {3, 19, 3}}
                    {'outputName_CM', {3, 22, 3}}
                    {'first_flchrome_name', {3, 9, 2}}
                    {'first_flchrome_channel', {3, 9, 3}}
                    {'first_flchrome_type', {3, 9, 4}} % whether constitutive or input or output
                    {'first_flchrome_wavlen', {3, 9, 5}}
                    {'first_flchrome_filter', {3, 9, 6}}
                    {'first_flchrome_color', {3, 9, 7}}
                    {'first_flchrome_id', {3, 9, 8}}
                    {'num_channels', {3, 19, 1}}
                    {'bead_name', {3, 3, 7}}
                    {'blank_name', {3, 6, 2}}
                    {'all_name', {3, 19, 4}}
                    {'first_preference_name', {4, 3, 1}}
                    {'first_preference_value', {4, 3, 3}}
                    };
            else
                obj.coordinates = coords;
            end
            % Find the number of templates and update coordinates with info
            obj.coordinates = obj.findTemplates();
        end

        % Update any relevant TASBEConfig from the Additional Settings sheet in the
        % template spreadsheet
        function TASBEConfig_updates(obj)
            TASBEConfig.checkpoint('init');
            raw = obj.sheets{4};
            name_col = obj.getColNum('first_preference_name');
            val_col = obj.getColNum('first_preference_value');
            for i=obj.getRowNum('first_preference_name'):size(raw,1)
                % Set the TASBEConfig if value column not empty for given
                % row
                if ~isnan(cell2mat(raw(i,val_col)))
                    if contains(char(cell2mat(raw(i,name_col))), 'Size')
                        bounds = strsplit(char(cell2mat(raw(i,val_col))), ',');
                        TASBEConfig.set(char(cell2mat(raw(i,name_col))), [str2double(bounds{1}), str2double(bounds{2})]);
                    else
                        TASBEConfig.set(char(cell2mat(raw(i,name_col))), cell2mat(raw(i,val_col)));
                    end
                end
            end
        end
        
        % Returns the ExcelCoordinates stored within obj.coordinates with
        % name of variable as input
        function position = getExcelCoordinates(obj, name)
            for i=1:numel(obj.coordinates)
                if strcmp(name, obj.coordinates{i}{1})
                    position = obj.coordinates{i}{2};
                    return
                end
            end
            TASBESession.error('Excel','CoordNotFound','Inputted name, %s, not valid. No match found in coordinates.', name);
        end
        
        % Returns the first coordinate value (sheet number) of a given variable
        function sheet_num = getSheetNum(obj, name)
            pos = obj.getExcelCoordinates(name);
            sheet_num = pos{1};
        end
        
        % Returns the second coordinate value (row number) of a given variable
        function row = getRowNum(obj, name)
            pos = obj.getExcelCoordinates(name);
            row = pos{2};
        end
        
        % Returns the third coordinate value (col number) of a given variable
        function col = getColNum(obj, name)
            pos = obj.getExcelCoordinates(name);
            col = pos{3};
        end
        
        % Returns a new Excel object with updated coordinates. Takes the
        % name of the variable to change and new coords as inputs
        function new_obj = setExcelCoordinates(obj, name, coords)
            new_coords = obj.coordinates;
            for i=1:numel(obj.coordinates)
                if strcmp(name, obj.coordinates{i}{1})
                    new_coords{i}{2} = coords;
                    new_obj = Excel(obj.filepath, new_coords);
                    return
                end
            end
            TASBESession.error('Excel','CoordNotFound','Inputted name, %s, not valid. No match found in coordinates.', name);
        end
        
        % Returns a new obj.coordinates with updated coordinates. Takes the
        % name of the variable to add and its coords as inputs
        function new_coords = addExcelCoordinates(obj, name, coords)
            new_coords = obj.coordinates;
            new_coords{end+1} = {name, coords};
        end
        
        % Finds the coordinates for all of the filename templates
        function new_coords = findTemplates(obj)
            template_col = obj.getColNum('first_filename_template');
            template_sh = obj.getSheetNum('first_filename_template');
            first_template_row = obj.getRowNum('first_filename_template');
            coords = {};
            for i=first_template_row:size(obj.sheets{template_sh}, 1)
                try
                    value = obj.getExcelValuePos(template_sh, i, template_col, 'char');
                    if ~isempty(strfind(value, 'Filename Template'))
                        coords{end+1} = {template_sh, i+1, template_col};
                    end
                catch
                    continue
                end
            end
            new_coords = obj.addExcelCoordinates('filename_templates', coords);
        end
        
        % Looks through the condition keys in "Experiment" and raises a
        % warning if a value in "Samples" has a value that is not in the key
        function checkConditions(obj)
            condition
        end
        
        % Returns the value at an inputted position. Error checks make sure
        % that the value is of the correct type
        function value = getExcelValuePos(obj, sheet_num, row, col, type)
            sheet = obj.sheets{sheet_num};
            value = cell2mat(sheet(row,col));
            if isnan(value)
                TASBESession.error('Excel','ValueNotFound','No value at position (%s, %s, %s).', num2str(sheet_num), num2str(row), num2str(col));
            end
            if strcmp(type, 'cell') 
                bounds = strsplit(char(value), ',');
                if isnan(str2double(bounds))
                    TASBESession.error('Excel','IncorrectType','Value at (%s, %s, %s) does not make a numeric array. Make sure value is in the form of 1,2,3.', num2str(sheet_num), num2str(row), num2str(col));
                else
                    value = num2cell(str2double(bounds));
                end
            end
            if ~isa(value, type)
                TASBESession.error('Excel','IncorrectType','Value at (%s, %s, %s) of type %s, does not match with required type, %s.', num2str(sheet_num), num2str(row), num2str(col), class(value), type);
            end
        end
        
        % Returns the value of an inputted variable name using
        % getExcelValuePos
        function value = getExcelValue(obj, name, type, index)
            pos = obj.getExcelCoordinates(name);
            % index is considered for variables with more than one
            % coordinates
            if exist('index', 'var')
                pos = pos{index};
            end
            value = obj.getExcelValuePos(pos{1}, pos{2}, pos{3}, type);
        end
        
        % Sets a TASBEConfig given a variable name. getExcelValue is used
        % extensively in this function. Warnings/ errors are placed to make
        % sure there is a value found and that the variable is a
        % TASBEConfig. 
        function setTASBEConfig(obj, name, type, index)
            try
                if exist('index', 'var')
                    value = obj.getExcelValue(name, type, index);
                else
                    value = obj.getExcelValue(name, type);
                end
                
            catch
                TASBESession.warn('Excel','ValueNotFound','Name, %s, has no value at recorded position.', name);
                return
            end
            
            try
                TASBEConfig.isSet(name)
            catch
                TASBESession.error('Excel', 'NotTASBEConfig', 'Could not get any preference for: %s', name);
            end
            
            TASBEConfig.set(name, value);
            
        end
    end
end
