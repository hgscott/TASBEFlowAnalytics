% Excel class with objects representing the information for a given template
% spreadsheet
classdef TemplateExtraction
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
        function obj = TemplateExtraction(file, coords)
            obj.filepath = file;
            % Read in Excel for information, Experiment sheet
            [~,~,s1] = xlsread(file, 'Experiment');
            % Read in Excel for information, Samples sheet
            [~,~,s2] = xlsread(file, 'Samples');
            % Read in Excel for information, Calibration sheet
            [~,~,s3] = xlsread(file, 'Calibration');
            % Read in Excel for information, Comparative Analysis sheet
            [~,~,s4] = xlsread(file, 'Comparative Analysis');
            % Read in Excel for information, Transfer Curve Analysis sheet
            [~,~,s5] = xlsread(file, 'Transfer Curve Analysis');
            % Read in Excel for information, Additional Settings sheet
            [~,~,s6] = xlsread(file, 'Optional Settings');
            obj.sheets = {s1, s2, s3, s4, s5, s6};
            if nargin < 2
                obj.coordinates = {...
                    % Coords for variables in "Experiment"
                    {'experimentName'; {1, 5, 1}};
                    {'first_filename_template'; {1, 16, 5}};
                    {'first_condition_key'; {1, 16, 1}};
                    % Coords for variables in "Samples"
                    {'first_sample_num'; {2, 5, 1}};
                    {'first_sample_name'; {2, 5, 2}};
                    {'inputName_CM'; {{2, 30, 3}, {4, 13, 2}, {5, 13, 2}}};
                    {'OutputSettings.StemName'; {{2, 30, 4}, {4, 5, 13}, {5, 5, 13}}};
                    {'binseq_min'; {{2, 30, 9}, {4, 13, 6}, {5, 13, 6}}};
                    {'binseq_pdecade'; {{2, 30, 10}, {4, 13, 7}, {5, 13, 7}}};
                    {'binseq_max'; {{2, 30, 11}, {4, 13, 8}, {5, 13, 8}}};
                    {'minValidCount'; {{2, 30, 6}, {4, 13, 3}, {5, 13, 3}}};
                    {'autofluorescence'; {{2, 30, 7}, {4, 13, 4}, {5, 13, 4}}};
                    {'minFracActive'; {{2, 30, 8}, {4, 13, 5}, {5, 13, 5}}};
                    {'outputName_BA'; {2, 30, 5}};
                    % Coords for variables in "Calibration"
                    {'beads.beadModel'; {3, 5, 2}};
                    {'plots.plotPath'; {{3, 28, 2}, {2, 30, 2}, {4, 5, 16}, {5, 5, 16}}};
                    {'beads.beadBatch'; {3, 5, 1}};
                    {'beads.rangeMin'; {3, 5, 3}};
                    {'beads.rangeMax'; {3, 5, 4}};
                    {'beads.peakThreshold'; {3, 5, 5}};
                    {'beads.beadChannel'; {3, 5, 6}};
                    {'beads.secondaryBeadChannel'; {3, 28, 3}};
                    {'relevant_channels'; {3, 24, 2}};
                    {'transChannelMin'; {3, 24, 3}};
                    {'outputName_CM'; {3, 28, 4}};
                    {'first_flchrome_name'; {3, 13, 2}};
                    {'first_flchrome_channel'; {3, 13, 3}};
                    {'first_flchrome_type'; {3, 13, 4}}; % whether constitutive or input or output
                    {'first_flchrome_wavlen'; {3, 13, 5}};
                    {'first_flchrome_filter'; {3, 13, 6}};
                    {'first_flchrome_color'; {3, 13, 7}};
                    {'first_flchrome_id'; {3, 13, 8}};
                    {'num_channels'; {3, 24, 1}};
                    {'bead_name'; {3, 5, 7}};
                    {'blank_name'; {3, 9, 2}};
                    {'all_name'; {3, 24, 4}};
                    % Coords for variables in "Comparative Analysis"
                    {'device_name'; {{4, 5, 15}, {5, 5, 15}}};
                    {'outputName_PM'; {4, 5, 14}};
                    {'primary_sampleColName_PM'; {4, 5, 7}};
                    {'secondary_sampleColName_PM'; {4, 5, 10}};
                    {'first_sampleColName_PM'; {4, 5, 1}};
                    {'first_sampleVal_PM'; {4, 5, 4}};
                    % Coords for variables in "Transfer Curve Analysis"
                    {'outputName_TC'; {5, 5, 14}};
                    {'sampleColName_TC'; {5, 5, 7}};
                    {'first_sampleColName_TC'; {5, 5, 1}};
                    {'first_sampleVal_TC'; {5, 5, 4}};
                    % Coords for variables in "Optional Settings"
                    {'first_preference_name'; {6, 3, 1}};
                    {'first_preference_value'; {6, 3, 3}};
                    };
            else
                obj.coordinates = coords;
            end
            % Find the number of templates and update coordinates with info
            obj.coordinates = obj.findTemplates();
            % Find position of template # and exclude from batch analysis
            % in "Samples"
            obj.coordinates = obj.findSampleCols();
            % Find last sample row
            obj.coordinates = obj.findLastSampleRow();
            % Check on condition keys
            obj.checkConditions();
        end

        % Update any relevant TASBEConfig from the Additional Settings sheet in the
        % template spreadsheet
        function TASBEConfig_updates(obj)
            TASBEConfig.checkpoint('init');
            raw = obj.getSheetNum('first_preference_name');
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
            TASBESession.error('TemplateExtraction','CoordNotFound','Inputted name, %s, not valid. No match found in coordinates.', name);
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
            TASBESession.error('TemplateExtraction','CoordNotFound','Inputted name, %s, not valid. No match found in coordinates.', name);
        end
        
        % Returns a new obj.coordinates with updated coordinates. Takes the
        % name of the variable to add and its coords as inputs
        function new_coords = addExcelCoordinates(obj, names, coords)
            new_coords = obj.coordinates;
            for i=1:numel(names)
                new_coords{end+1} = {names{i}; coords{i}};
            end
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
            new_coords = obj.addExcelCoordinates({'filename_templates'}, {coords});
        end
        
        % Looks through the condition keys in "Experiment" and raises a
        % warning if a value in "Samples" has a value that is not in the key
        function checkConditions(obj)
            condition_col = obj.getColNum('first_condition_key');
            condition_sh = obj.getSheetNum('first_condition_key');
            first_condition_row = obj.getRowNum('first_condition_key');
            for i=first_condition_row:size(obj.sheets{condition_sh}, 1)
                try
                    value = obj.getExcelValuePos(condition_sh, i, condition_col, 'char');
                    if ~isempty(strfind(value, 'Sample Column Name'))
                        % Found a condition key, save its keys in an array
                        % and compare with column in "Samples"
                        try
                            column_name = obj.getExcelValuePos(condition_sh, i, condition_col+1, 'char');
                            obj.checkConditions_helper(i, column_name);
                            
                        catch
                            try
                                column_name = num2str(obj.getExcelValuePos(condition_sh, i, condition_col+1, 'numeric'));
                                obj.checkConditions_helper(i, column_name);
                            catch
                                continue
                            end
                        end
                    end
                catch
                    continue
                end
            end
        end
        
        % Helper function for checkConditions
        function checkConditions_helper(obj, i, column_name)
            condition_col = obj.getColNum('first_condition_key');
            condition_sh = obj.getSheetNum('first_condition_key');
            sh_num1 = obj.getSheetNum('first_sample_num');
            sample_start_col = obj.getColNum('first_sample_num');
            sample_start_row = obj.getRowNum('first_sample_num') - 1;
            keys = {};
            for j=i+2:size(obj.sheets{condition_sh}, 1)
                try
                    keys{end+1} = obj.getExcelValuePos(condition_sh, j, condition_col, 'char');
                catch
                    try
                        keys{end+1} = num2str(obj.getExcelValuePos(condition_sh, j, condition_col, 'numeric'));
                    catch
                        break
                    end
                end
            end
            % look at column in "Samples"
            for j=sample_start_col:size(obj.sheets{sh_num1},2)
                try 
                    ref_header = obj.getExcelValuePos(sh_num1, sample_start_row, j, 'char');
                catch
                    try
                        ref_header = num2str(obj.getExcelValuePos(sh_num1, sample_start_row, j, 'numeric'));
                    catch 
                        TASBESession.error('TemplateExtraction', 'InvalidHeaderName', 'The header, %s, does not match with any column titles in "Samples" sheet.', header);
                    end
                end
                % Find the matching section name in filename template
                % and column header in "Samples"
                if strcmp(column_name, ref_header)
                    % go through all the rows and make sure
                    % matches with one of the keys, raise
                    % warning if not
                    for k=sample_start_row+1:obj.getRowNum('last_sample_num')
                        try
                            value = obj.getExcelValuePos(sh_num1, k, j, 'char');
                            ind = find(ismember(keys, value), 1);
                            if isempty(ind)
                                TASBESession.warn('TemplateExtraction', 'InvalidValue', 'The value of %s at row %s col %s does not match with listed keys.', value, num2str(k), column_name);
                            end
                        catch
                            try
                                value = num2str(obj.getExcelValuePos(sh_num1, k, j, 'numeric'));
                                ind = find(ismember(keys, value), 1);
                                if isempty(ind)
                                    TASBESession.warn('TemplateExtraction', 'InvalidValue', 'The value of %s at row %s col %s does not match with listed keys.', value, num2str(k), column_name);
                                end
                            catch
                                continue
                            end
                        end

                    end
                    break
                end
            end
        end
        
        % Find coordinates of Template # and Exclude from Batch Analysis
        % columns in "Samples" and add to coordinates
        function new_coords = findSampleCols(obj)
            sh_num1 = obj.getSheetNum('first_sample_num');
            sample_start_col = obj.getColNum('first_sample_num');
            sample_start_row = obj.getRowNum('first_sample_num') - 1;
            names = {'Template #', 'Exlude from Batch Analysis'};
            coords = {};
            % look through columns in "Samples"
            for i=sample_start_col:size(obj.sheets{sh_num1},2)
                try 
                    ref_header = obj.getExcelValuePos(sh_num1, sample_start_row, i, 'char');
                catch
                    try
                        ref_header = num2str(obj.getExcelValuePos(sh_num1, sample_start_row, i, 'numeric'));
                    catch 
                        break
                    end
                end
                ind = find(ismember(names, ref_header), 1);
                if ~isempty(ind)
                    coords{ind} = {sh_num1, sample_start_row+1, i};
                end
            end
            if numel(coords) ~= 2
                TASBESession.error('TemplateExtraction', 'MissingHeader', 'Did not find template # or exclude from batch analysis columns in "Samples".');
            end
            new_coords = obj.addExcelCoordinates({'first_sample_template', 'first_sample_exclude'}, coords);
        end
        
        % Finds the last sample row
        function new_coords = findLastSampleRow(obj)
            sh_num1 = obj.getSheetNum('first_sample_num');
            sample_start_col = obj.getColNum('first_sample_num');
            sample_start_row = obj.getRowNum('first_sample_num');
            coords = {};
            row_num = 0;
            for i=sample_start_row:size(obj.sheets{sh_num1},1)
                try 
                    num = num2str(obj.getExcelValuePos(sh_num1, i, sample_start_col, 'numeric'));
                catch
                    % found last
                    row_num = i-1;
                    break
                end 
            end
            coords{end+1} = {sh_num1, row_num, sample_start_col};
            new_coords = obj.addExcelCoordinates({'last_sample_num'}, coords);
        end
        
        % Returns the value at an inputted position. Error checks make sure
        % that the value is of the correct type
        function value = getExcelValuePos(obj, sheet_num, row, col, type)
            sheet = obj.sheets{sheet_num};
            value = cell2mat(sheet(row,col));
            if isnan(value)
                TASBESession.error('TemplateExtraction','ValueNotFound','No value at position (%s, %s, %s).', num2str(sheet_num), num2str(row), num2str(col));
            end
            if exist('type', 'var')
                if strcmp(type, 'cell') 
                    bounds = strsplit(char(value), ',');
                    if isnan(str2double(bounds))
                        TASBESession.error('TemplateExtraction','IncorrectType','Value at (%s, %s, %s) does not make a numeric array. Make sure value is in the form of #,#,#.', num2str(sheet_num), num2str(row), num2str(col));
                    else
                        value = num2cell(str2double(bounds));
                    end
                end
                if ~isa(value, type)
                    TASBESession.error('TemplateExtraction','IncorrectType','Value at (%s, %s, %s) of type %s, does not match with required type, %s.', num2str(sheet_num), num2str(row), num2str(col), class(value), type);
                end
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
            if exist('type', 'var')
                value = obj.getExcelValuePos(pos{1}, pos{2}, pos{3}, type);
            else
                value = obj.getExcelValuePos(pos{1}, pos{2}, pos{3});
            end
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
                TASBESession.warn('TemplateExtraction','ValueNotFound','Name, %s, has no value at recorded position.', name);
                return
            end
            
            try
                TASBEConfig.isSet(name)
            catch
                TASBESession.error('TemplateExtraction', 'NotTASBEConfig', 'Could not get any preference for: %s', name);
            end
            
            TASBEConfig.set(name, value);
            
        end
    end
end
