classdef Excel
    properties
        coordinates = {...
                {'experimentName', {1, 4, 1}}
                {'stem', {1, 13, 10}}
                {'filename_templates', {{1, 13, 5}, {1, 22, 5}, {1, 31, 5}, {1, 40, 5}}}
                {'beads.beadModel', {2, 3, 2}}
                {'plots.plotPath', {{2, 22, 1}, {3, 28, 2}}}
                {'beads.beadBatch', {2, 3, 1}}
                {'beads.rangeMin', {2, 3, 3}}
                {'beads.rangeMax', {2, 3, 4}}
                {'beads.peakThreshold', {2, 3, 5}}
                {'beads.beadChannel', {2, 3, 6}}
                {'beads.secondaryBeadChannel', {2, 22, 2}}
                {'transChannelMin', {2, 19, 3}}
                {'outputName_CM', {2, 22, 3}}
                {'first_sample_num', {3, 3, 1}}
                {'first_sample_dox', {3, 3, 2}}
                {'first_sample_template', {3, 3, 8}}
                {'first_sample_name', {3, 3, 11}}
                {'first_sample_filename', {3, 3, 12}}
                {'first_sample_exclude', {3, 3, 15}}
                {'first_flchrome_name', {2, 9, 2}}
                {'first_flchrome_channel', {2, 9, 3}}
                {'first_flchrome_type', {2, 9, 4}} % whether constitutive or input or output
                {'first_flchrome_wavlen', {2, 9, 5}}
                {'first_flchrome_filter', {2, 9, 6}}
                {'first_flchrome_color', {2, 9, 7}}
                {'first_flchrome_id', {2, 9, 9}}
                {'num_channels', {2, 19, 1}}
                {'inputName_CM', {3, 28, 3}}
                {'OutputSettings.StemName', {3, 28, 4}}
                {'binseq_min', {3, 28, 9}}
                {'binseq_pdecade', {3, 28, 10}}
                {'binseq_max', {3, 28, 11}}
                {'minValidCount', {3, 28, 6}}
                {'autofluorescence', {3, 28, 7}}
                {'minFracActive', {3, 28, 8}}
                {'outputName_BA', {3, 28, 5}}
                {'first_preference_name', {4, 2, 1}}
                {'first_preference_value', {4, 2, 3}}
                };
        sheets;
    end
    methods
        % Constuctor
        function obj = Excel()
            % Read in Excel for information, Experiment sheet
            [~,~,s1] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Experiment', 'A1:J46');
            % Read in Excel for information, cytometer sheet
            [~,~,s2] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Cytometer', 'A1:J46');
            % Read in Excel for information, Samples sheet
            [~,~,s3] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Samples', 'A1:O46');
            % Read in Excel for information, Additional Settings sheet
            [~,~,s4] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Additional Settings', 'A1:D63');
            obj.sheets = {s1, s2, s3, s4};
        end
        
        % Update any relevant TASBEConfig from the Additional Settings sheet in the
        % batch_template spreadsheet
        function TASBEConfig_updates(obj)
            TASBEConfig.checkpoint('init');
            raw = obj.sheets{4};
            name_col = obj.getColNum('first_preference_name');
            val_col = obj.getColNum('first_preference_value');
            for i=obj.getRowNum('first_preference_name'):size(raw,1)
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

        function position = getExcelCoordinates(obj, name)
            for i=1:numel(obj.coordinates)
                if strcmp(name, obj.coordinates{i}{1})
                    position = obj.coordinates{i}{2};
                    return
                end
            end
            TASBESession.error('Excel','CoordNotFound','Inputted name, %s, not valid. No match found in coordinates.', name);
        end
        
        function sheet_num = getSheetNum(obj, name)
            pos = obj.getExcelCoordinates(name);
            sheet_num = pos{1};
        end
        
        function row = getRowNum(obj, name)
            pos = obj.getExcelCoordinates(name);
            row = pos{2};
        end
        
        function col = getColNum(obj, name)
            pos = obj.getExcelCoordinates(name);
            col = pos{3};
        end
        
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
        
        function value = getExcelValue(obj, name, type, index)
            pos = obj.getExcelCoordinates(name);
            if exist('index', 'var')
                pos = pos{index};
            end
            value = obj.getExcelValuePos(pos{1}, pos{2}, pos{3}, type);
        end
        
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
