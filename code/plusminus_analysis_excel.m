% Function that runs plusminus analysis given a template spreadsheet. An Excel
% object and optional Color Model are inputs
function plusminus_analysis_excel(path, extractor, CM)
    % Reset and update TASBEConfig and get exp, device, and inducer names
    extractor.TASBEConfig_updates();
    TASBEConfig.set('template.displayErrors', 1);
    experimentName = extractor.getExcelValue('experimentName', 'char'); 
    preference_row = extractor.getExcelValue('last_row_PM', 'numeric') + 5;
    TASBEConfig.set('template.displayErrors', 0);

    % Load the color model
    if nargin < 3
        % Obtain the CM_name
        try
            coords = extractor.getExcelCoordinates('inputName_CM', 2);
            CM_name = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'char'); 
            [~,name,~] = fileparts(CM_name);
            CM_name = [name '.mat'];
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing CM Filename in "Comparative Analysis" sheet. Looking in "Calibration" sheet.');
            try
                CM_name = extractor.getExcelValue('outputName_CM', 'char');
                [~,name,~] = fileparts(CM_name);
                CM_name = [name '.mat'];
            catch
                TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing Output Filename in "Calibration" sheet. Defaulting to exp name.');
                CM_name = [experimentName '-ColorModel.mat'];
            end
        end
        
        % Obtain the CM_path
        try
            coords = extractor.getExcelCoordinates('inputPath_CM', 2);
            CM_path = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'char');
            javaFileObj = java.io.File(end_with_slash(CM_path));
            if javaFileObj.isAbsolute()
                CM_path = end_with_slash(CM_path);
            else
                CM_path = end_with_slash(fullfile(path, CM_path));
            end
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing CM Filepath in "Comparative Analysis" sheet. Looking in "Calibration" sheet.'); 
            try
                CM_path = extractor.getExcelValue('outputPath_CM', 'char');
                javaFileObj = java.io.File(end_with_slash(CM_path));
                if javaFileObj.isAbsolute()
                    CM_path = end_with_slash(CM_path);
                else
                    CM_path = end_with_slash(fullfile(path, CM_path));
                end
            catch
                TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing Output Filepath in "Calibration" sheet. Defaulting to template path.'); 
                CM_path = path;
            end
        end
        CM_file = [CM_path CM_name];

        try 
            load(CM_file);
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Could not load CM file, creating a new one.');
            CM = make_color_model_excel(extractor);
        end
    end

    % Set TASBEConfigs and create variables needed to run plusminus analysis
    % Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
    try
        coords = extractor.getExcelCoordinates('binseq_min', 2);
        binseq_min = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        coords = extractor.getExcelCoordinates('binseq_max', 2);
        binseq_max = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        coords = extractor.getExcelCoordinates('binseq_pdecade', 2);
        binseq_pdecade = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        bins = BinSequence(binseq_min, (1/binseq_pdecade), binseq_max, 'log_bins');
    catch
        bins = BinSequence();
    end

    % Designate which channels have which roles
    [channel_roles, ~] = getChannelRoles(CM, extractor);
    
    if isempty(channel_roles)
        TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing constitutive, input, output in "Calibration" sheet');
        APs = {AnalysisParameters(bins,{})};
    else
        APs = {};
        for j=1:numel(channel_roles)
            APs{end+1} = AnalysisParameters(bins,channel_roles{j});
        end
    end
    
    % Obtain the necessary sample filenames and print names
    sample_names = {};
    file_names = {};
    sh_num3 = extractor.getSheetNum('first_sampleColName_PM');
    sh_num2 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    col_names = {};
    row_nums = {};
    col_nums = {};
    TASBEConfig.set('template.displayErrors', 1);
    last_sampleColName_row = extractor.getExcelValue('last_row_PM', 'numeric');
    TASBEConfig.set('template.displayErrors', 0);
    % Determine the number of plusminus analysis to run
    for i=extractor.getRowNum('primary_sampleColName_PM'): last_sampleColName_row
        col_name = {};
        try
            value = extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('primary_sampleColName_PM'), 'char');
            col_name{end+1} = value;
            row_nums{end+1} = i;
        catch
            try
                value = num2str(extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('primary_sampleColName_PM'), 'numeric'));
                if ~isempty(value)
                    col_name{end+1} = value;
                    row_nums{end+1} = i;
                end
            catch 
                continue
            end
        end
        try
            col_name{end+1} = extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('secondary_sampleColName_PM'), 'char');
            col_names{end+1} = col_name;
        catch
            try
                value = num2str(extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('secondary_sampleColName_PM'), 'numeric'));
                if ~isempty(value)
                    col_name{end+1} = value;
                end
                col_names{end+1} = col_name;
            catch
                % no secondary column add col_name to col_names and
                % continue
                col_names{end+1} = col_name;
                continue
            end
        end
    end
    
    % Go through columns to find column numbers of primary and secondary col names
    for i=1:numel(col_names)
        col_name = col_names{i};
        col_num = {};
        for j=sample_num_col:size(extractor.sheets{sh_num2},2)
            try 
                ref_header = extractor.getExcelValuePos(sh_num2, first_sample_row-1, j, 'char');
            catch
                try
                    ref_header = num2str(extractor.getExcelValuePos(sh_num2, first_sample_row-1, j, 'numeric'));
                    if isempty(ref_header)
                        continue
                    end
                catch 
                    continue
                end
            end
            ind = find(ismember(col_name, ref_header), 1);
            if ~isempty(ind)
                col_num{ind} = j;
            end
        end
        if numel(col_num) ~= numel(col_name)
            TASBESession.error('plusminus_analysis_excel', 'InvalidColumnName', 'Primary/secondary column names in "Comparative Analysis" does not match with any column name in "Samples".');
        end
        col_nums{end+1} = col_num;
    end
    
    % Go though comparison groups and store values and column numbers in
    % cell array
    comp_groups = {};
    comp_group_names = {};
    first_group_row = extractor.getRowNum('first_sampleColName_PM');
    first_group_col = extractor.getColNum('first_sampleColName_PM');
    outputNames = {};
    outputPaths = {};
    stemNames = {};
    plotPaths = {};
    device_names = {};
    inducer_names = {};
    
    for i=1:numel(row_nums)
        if i == numel(row_nums)
            end_row = last_sampleColName_row;
        else
            end_row = row_nums{i+1}-1; 
        end
        comp_group = {};
        for j=row_nums{i}:end_row
            try
                col_name = extractor.getExcelValuePos(sh_num3, j, first_group_col, 'char');
            catch
                try
                    col_name = num2str(extractor.getExcelValuePos(sh_num3, i, first_group_col, 'numeric'));
                catch 
                    continue
                end
            end
            checkError = true;
            % Get column number of col_name
            for k=sample_num_col:size(extractor.sheets{sh_num2},2)
                try 
                    ref_header = extractor.getExcelValuePos(sh_num2, first_sample_row-1, k, 'char');
                catch
                    try
                        ref_header = num2str(extractor.getExcelValuePos(sh_num2, first_sample_row-1, k, 'numeric'));
                        if isempty(ref_header)
                            continue
                        end
                    catch 
                        continue
                    end
                end
                if strcmp(col_name, ref_header)
                    checkError = false;
                    comp_group{end+1} = {k, extractor.getExcelValuePos(sh_num3, j, extractor.getColNum('first_sampleVal_PM'))};
                    comp_group_names{end+1} = col_name;
                    break
                end 
            end
            if checkError
                TASBESession.error('plusminus_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Comparative Analysis" does not match with any column name in "Samples".', col_name);
            end
        end
        if isempty(comp_group)
            comp_group{end+1} = {};
        end
        comp_groups{end+1} = comp_group;
        % Get unique preferences
        % Obtain output name
        try 
            outputName = extractor.getExcelValuePos(sh_num3, row_nums{i}, extractor.getColNum('outputName_PM'), 'char');
            [~, name, ~] = fileparts(outputName);
            outputNames{end+1} = [name '.mat'];
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing Output File Name for Plusminus Analysis %s in "Comparative Analysis" sheet', num2str(i));
            if i > 1
                outputNames{end+1} = [experimentName '-CompAnalysis' num2str(i) '.mat'];
            else
                outputNames{end+1} = [experimentName '-CompAnalysis.mat'];
            end
        end
        
        % Obtain output path
        try
            outputPath = extractor.getExcelValuePos(sh_num3, row_nums{i}, extractor.getColNum('outputPath_PM'), 'char');
            javaFileObj = java.io.File(end_with_slash(outputPath));
            if javaFileObj.isAbsolute()
                outputPath = end_with_slash(outputPath);
            else
                outputPath = end_with_slash(fullfile(path, outputPath));
            end
            outputPaths{end+1} = outputPath;
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing Output File Path for Plusminus Analysis %s in "Comparative Analysis" sheet', num2str(i));
            outputPaths{end+1} = path;
        end

        try 
            stemName_coord = extractor.getExcelCoordinates('OutputSettings.StemName');
            stemNames{end+1} = extractor.getExcelValuePos(sh_num3, row_nums{i}, stemName_coord{2}{3}, 'char');
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing Stem Name for Plusminus Analysis %s in "Comparative Analysis" sheet', num2str(i));
            stemNames{end+1} = [experimentName num2str(i)];
        end
        
        try
            plotPath_coord = extractor.getExcelCoordinates('plots.plotPath');
            plot_path = extractor.getExcelValuePos(sh_num3, row_nums{i}, plotPath_coord{3}{3}, 'char');
            javaFileObj = java.io.File(end_with_slash(plot_path));
            if javaFileObj.isAbsolute()
                plot_path = end_with_slash(plot_path);
            else
                plot_path = end_with_slash(fullfile(path, plot_path));
            end
            plotPaths{end+1} = plot_path;
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing plot path for Plusminus Analysis %s in "Comparative Analysis" sheet', num2str(i));
            plot_path = end_with_slash(fullfile(path, 'plots/'));
            plotPaths{end+1} = plot_path;
        end
   
        try
            device_names{end+1} = comp_group_names{1};
        catch
            TASBESession.warn('plusminus_analysis_excel', 'MissingPreference', 'Missing device name for Plusminus Analysis %s in "Comparative Analysis" sheet. Defaulting to exp name.', num2str(i));
            device_names{end+1} = [experimentName num2str(i)];
        end
        
        inducer_names{end+1} = col_names{i}{1};
    end

    % Get list of distinct values from primary sample column names using
    % condition key col_nums{i}. Also get list of distinct values (in
    % order) from secondary sample column names
    condition_col = extractor.getColNum('first_condition_key');
    condition_sh = extractor.getSheetNum('first_condition_key');
    first_condition_row = extractor.getRowNum('first_condition_key');
    all_keys = {};
    for i=1:numel(col_names)
        col_name = col_names{i};
        keys = {};
        for j=first_condition_row:size(extractor.sheets{condition_sh}, 1)
            try
                value = extractor.getExcelValuePos(condition_sh, j, condition_col, 'char');
                if ~isempty(strfind(value, 'Sample Column Name'))
                    try
                        column_name = extractor.getExcelValuePos(condition_sh, j, condition_col+1, 'char');
                        ind = find(ismember(col_name, column_name), 1);
                        if ~isempty(ind)
                            % get keys
                            key = {};
                            for k=j+2:size(extractor.sheets{condition_sh}, 1)
                                try
                                    key{end+1} = extractor.getExcelValuePos(condition_sh, k, condition_col, 'char');
                                catch
                                    try
                                        key{end+1} = extractor.getExcelValuePos(condition_sh, k, condition_col, 'numeric');
                                    catch
                                        break
                                    end
                                end
                            end
                            keys{end+1} = key;
                        end
                    catch
                        try
                            column_name = num2str(extractor.getExcelValuePos(condition_sh, j, condition_col+1, 'numeric'));
                            ind = find(ismember(col_name, column_name), 1);
                            if ~isempty(ind)
                                % get keys
                                key = {};
                                for k=j+2:size(extractor.sheets{condition_sh}, 1)
                                    try
                                        key{end+1} = extractor.getExcelValuePos(condition_sh, k, condition_col, 'char');
                                    catch
                                        try
                                            key{end+1} = extractor.getExcelValuePos(condition_sh, k, condition_col, 'numeric');
                                        catch
                                            break
                                        end
                                    end
                                end
                                keys{end+1} = key;
                            end
                        catch
                            continue
                        end
                    end
                end
            catch
                continue
            end
        end
        all_keys{end+1} = keys;
    end
    
    for i=1:numel(col_names)
        device_name = device_names{i};
        TASBEConfig.set('OutputSettings.DeviceName', device_names{i});
        stemName = stemNames{i};
        TASBEConfig.set('OutputSettings.StemName', stemName);
        TASBEConfig.set('plots.plotPath', plotPaths{i});
        outputName = outputNames{i};
        outputPath = outputPaths{i};
        keys = all_keys{i};
        comp_group = comp_groups{i};
        col_num = col_nums{i};
        col_name = col_names{i};
        batch_description = {}; % contains all the sample row numbers for groups
        % Find the different sets for each group 
        for k=1:numel(comp_group)
            group = {};
            for j=first_sample_row:extractor.getRowNum('last_sample_num')
                try
                    if isempty(comp_group{k})
                        group{end+1} = j;
                    else
                        value = extractor.getExcelValuePos(sh_num2, j, comp_group{k}{1});
                        if isa(value, 'char') && strcmp(value, comp_group{k}{2})
                            group{end+1} = j;
                        elseif isa(value, 'numeric') && value == comp_group{k}{2}
                            group{end+1} = j;
                        end
                    end
                catch
                    continue
                end
            end
            if ~isempty(comp_group{k})
                if ~isa(comp_group{k}{2}, 'char')
                    batch_description{end+1} = {num2str(comp_group{k}{2}); col_name{1}; keys{1}; group};
                else
                    batch_description{end+1} = {comp_group{k}{2}; col_name{1}; keys{1}; group};
                end
            else
                batch_description{end+1} = {experimentName; col_name{1}; keys{1}; group};
            end
        end

        % Go through row numbers in groups and extract and organize by keys{1}
        for k=1:numel(batch_description)
            sets = {};
            for j=1:numel(batch_description{k}{4})
                try
                    value = extractor.getExcelValuePos(sh_num2, batch_description{k}{4}{j}, col_num{1});
                    ind = find(ismember(keys{1}, value), 1);
                    if ~isempty(ind)
                        try 
                            isempty(sets{ind})
                            sets{ind}{end+1} = batch_description{k}{4}{j};
                        catch
                            sets{ind} = {batch_description{k}{4}{j}};
                        end
                    end
                catch
                    continue
                end
            end
            for j=1:numel(sets)
                batch_description{k}{3+j} = sets{j};
            end
        end

        % Reorder the sample within the sets if applicable to match with the
        % order of the secondary sample column name (else just keep old order)
        if numel(col_name) > 1 && numel(keys) > 1
            for z=1:numel(batch_description)
                for j=4:numel(batch_description{z})
                    set = batch_description{z}{j};
                    ordered_set = {};
                    for k=1:numel(set)
                        % Get value at col_num{2} and compare with keys{2}
                        try
                            value = extractor.getExcelValuePos(sh_num2, set{k}, col_num{2});
                            ind = double.empty(0);
                            if isa(value, 'numeric')
                                for c=1:numel(keys{2})
                                    if keys{2}{c} == value
                                        ind = c;
                                        break
                                    end
                                end
                            else
                                ind = find(ismember(keys{2}, value), 1);
                            end
                            if ~isempty(ind)
                                ordered_set{ind,1} = value;
                                ordered_set{ind,2} = getFilename(extractor, set{k}, path);
                            end
                        catch
                            continue
                        end
                    end
                    batch_description{z}{j} = ordered_set;
                end
            end
        else
            % do the same but no reordering
            for z=1:numel(batch_description)
                for j=4:numel(batch_description{z})
                    set = batch_description{z}{j};
                    ordered_set = {};
                    for k=1:numel(set)
                        % Get value at col_num{2}}
                        if numel(col_name) > 1
                            try
                                value = extractor.getExcelValuePos(sh_num2, set{k}, col_num{2});
                                ordered_set{end+1,1} = value;
                                ordered_set{end,2} = getFilename(extractor, set{k}, path);
                            catch
                                continue
                            end
                        else
                            % TODO: FINALIZE WHAT THE DEFAULT SHOULD BE
                            try
                                value = extractor.getExcelValuePos(sh_num2, set{k}, col_num{1});
                                ordered_set{end+1,1} = k; % default to just index
                                ordered_set{end,2} = getFilename(extractor, set{k}, path);
                            catch
                                continue
                            end
                        end
                    end
                    batch_description{z}{j} = ordered_set;
                end
            end
        end
        
        assignin('base','batch_description',batch_description);
        
        % Go through all possible APs
        for j=1:numel(APs)
            AP = APs{j};
            % Ignore any bins with less than valid count as noise
            try
                coords = extractor.getExcelCoordinates('minValidCount', 2);
                minValidCount = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
                AP=setMinValidCount(AP,minValidCount);
            catch
                TASBESession.warn('plusminus_analysis_excel', 'ImportantMissingPreference', 'Missing Min Valid Count in "Comparative Analysis" sheet');
            end

            % Add autofluorescence back in after removing for compensation?
            try
                coords = extractor.getExcelCoordinates('autofluorescence', 2);
                autofluorescence = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
                AP=setUseAutoFluorescence(AP,autofluorescence);
            catch
                TASBESession.warn('plusminus_analysis_excel', 'ImportantMissingPreference', 'Missing Use Auto Fluorescence in "Comparative Analysis" sheet');
            end

            try
                coords = extractor.getExcelCoordinates('minFracActive', 2);
                minFracActive = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
                AP=setMinFractionActive(AP,minFracActive);
            catch
                TASBESession.warn('plusminus_analysis_excel', 'ImportantMissingPreference', 'Missing Min Fraction Active in "Comparative Analysis" sheet');
            end
            
            if j > 1
                outputName_parts = strsplit(outputName, '.');
                outputName = [outputName_parts{1} '-' num2str(j) '.' outputName_parts{2}];
                for z=1:numel(batch_description)
                    batch_description{z}{1} = [batch_description{z}{1} '-' num2str(j)];
                end
            end

            % Execute the actual analysis
            results = process_plusminus_batch(CM, batch_description, AP);

            % Make additional output plots
            for k=1:numel(results)
                TASBEConfig.set('OutputSettings.StemName', batch_description{k}{1});
                TASBEConfig.set('OutputSettings.DeviceName',device_name);
                plot_plusminus_comparison(results{k}, batch_description{k}{3});
            end
            save('-V7',[outputPath outputName],'batch_description','AP','results');
        end
    end
end
