% Function that runs transfer curve analysis given a template spreadsheet. An Excel
% object and optional Color Model are inputs
function transfercurve_analysis_excel(extractor, CM)
    % Reset and update TASBEConfig and get exp, device, and inducer names
    extractor.TASBEConfig_updates();
    TASBEConfig.set('template.displayErrors', 1);
    experimentName = extractor.getExcelValue('experimentName', 'char');
    TASBEConfig.set('template.displayErrors', 0);
    
    % Determine the number of transfer curve analysis to run
    sh_num3 = extractor.getSheetNum('first_sampleColName_TC');
    sh_num2 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    col_names = {};
    col_nums = {};
    row_nums = {};
    num_runs = 0;
    for i=extractor.getRowNum('sampleColName_TC'):size(extractor.sheets{sh_num3},1)
        try
            value = extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('sampleColName_TC'), 'char');
            col_names{end+1} = value;
            row_nums{end+1} = i;
            num_runs = num_runs + 1;
        catch
            try
                value = num2str(extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('sampleColName_TC'), 'numeric'));
                if isempty(value)
                    break
                end
                col_names{end+1} = value;
                row_nums{end+1} = i;
                num_runs = num_runs + 1;
            catch 
                break
            end
        end
    end
    
    if num_runs > 4
        preference_row = num_runs + 5;
    else
        preference_row = 13;
    end

    % Load the color model
    if nargin < 2
        try
            coords = extractor.getExcelCoordinates('inputName_CM', 3);
            CM_file = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'char'); 
        catch
            try
                CM_file = extractor.getExcelValue('outputName_CM', 'char');
            catch
                CM_file = [experimentName '-ColorModel.mat'];
            end
        end

        try 
            load(CM_file);
        catch
            CM = make_color_model_excel(extractor);
        end
    end

    % Set TASBEConfigs and create variables needed to run transfer curve analysis
    % Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
    try
        coords = extractor.getExcelCoordinates('binseq_min', 3);
        binseq_min = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        coords = extractor.getExcelCoordinates('binseq_max', 3);
        binseq_max = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        coords = extractor.getExcelCoordinates('binseq_pdecade', 3);
        binseq_pdecade = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        bins = BinSequence(binseq_min, (1/binseq_pdecade), binseq_max, 'log_bins');
    catch
        bins = BinSequence();
    end

    % Designate which channels have which roles
    [channel_roles, ~] = getChannelRoles(CM, extractor);
    
    if isempty(channel_roles)
        TASBESession.warn('transfercurve_analysis_excel', 'MissingPreference', 'Missing constitutive, input, output in "Calibration" sheet');
        APs = {AnalysisParameters(bins,{})};
    else
        APs = {};
        for j=1:numel(channel_roles)
            APs{end+1} = AnalysisParameters(bins,channel_roles{j});
        end
    end
   
    % Obtain the necessary sample filenames and print names
    % Go through columns to find column number
    for i=1:numel(col_names)
        col_name = col_names{i};
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
            if strcmp(col_name, ref_header)
                col_nums{end+1} = j;
                break
            end 
        end
    end
    if numel(col_nums) ~= numel(col_names)
        TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Not all Sample Column Names in "Transfer Curve Analysis" are matched with column names in "Samples".');
    end
    % Go though comparison groups and store values and column numbers in
    % cell array
    comp_groups = {};
    first_group_col = extractor.getColNum('first_sampleColName_TC');
    outputNames = {};
    stemNames = {};
    plotPaths = {};
    device_names = {};
    inducer_names = {};
    
    for i=1:numel(row_nums)
        try
            col_name = extractor.getExcelValuePos(sh_num3, row_nums{i}, first_group_col, 'char');
            checkError = true;
            % Get column number of col_name
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
                if strcmp(col_name, ref_header)
                    checkError = false;
                    comp_groups{end+1} = {j, extractor.getExcelValuePos(sh_num3, row_nums{i}, extractor.getColNum('first_sampleVal_TC'))};
                    break
                end 
            end
            if checkError
                TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Transfer Curve Analysis" does not match with any column name in "Samples".', col_name);
            end
        catch
            try
                col_name = num2str(extractor.getExcelValuePos(sh_num3, row_nums{i}, first_group_col, 'numeric'));
                if isempty(col_name)
                    % Add empty col_name
                    comp_groups{end+1} = {};
                else
                    checkError = true;
                    % Get column number of col_name
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
                        if strcmp(col_name, ref_header)
                            checkError = false;
                            comp_groups{end+1} = {j, extractor.getExcelValuePos(sh_num3, row_nums{i}, extractor.getColNum('first_sampleVal_TC'))};
                            break
                        end 
                    end
                    if checkError
                        TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Transfer Curve Analysis" does not match with any column name in "Samples".', col_name);
                    end
                end
            catch 
                % Add empty col_name
                comp_groups{end+1} = {};
            end
        end
        % Get unique preferences 
        try
            outputNames{end+1} = extractor.getExcelValuePos(sh_num3, row_nums{i}, extractor.getColNum('outputName_TC'), 'char');
        catch
            TASBESession.warn('transfercurve_analysis_excel', 'MissingPreference', 'Missing Output File Name for Transfer Curve Analysis %s in "Transfer Curve Analysis" sheet', num2str(i));
            if i > 1
                outputNames{end+1} = [experimentName '-TransAnalysis' num2str(i) '.mat'];
            else
                outputNames{end+1} = [experimentName '-TransAnalysis.mat'];
            end
        end

        try 
            stemName_coord = extractor.getExcelCoordinates('OutputSettings.StemName');
            stemNames{end+1} = extractor.getExcelValuePos(sh_num3, row_nums{i}, stemName_coord{3}{3}, 'char');
        catch
            TASBESession.warn('transfercurve_analysis_excel', 'MissingPreference', 'Missing Stem Name for Transfer Curve Analysis %s in "Transfer Curve Analysis" sheet', num2str(i));
            if i > 1
                stemNames{end+1} = [experimentName num2str(i)];
            else
                stemNames{end+1} = experimentName;
            end
        end
        try
            plotPath_coord = extractor.getExcelCoordinates('plots.plotPath');
            plotPaths{end+1} = extractor.getExcelValuePos(sh_num3, row_nums{i}, plotPath_coord{4}{3}, 'char');
        catch
            TASBESession.warn('transfercurve_analysis_excel', 'MissingPreference', 'Missing plot path for Transfer Curve Analysis %s in "Transfer Curve Analysis" sheet', num2str(i));
            plotPaths{end+1} = extractor.getExcelValue('plots.plotPath', 'char', 4);
        end
        try
            device_name_coord = extractor.getExcelCoordinates('device_name');
            device_names{end+1} = extractor.getExcelValuePos(sh_num3, row_nums{i}, device_name_coord{2}{3}, 'char');
        catch
            TASBESession.warn('transfercurve_analysis_excel', 'MissingPreference', 'Missing device name for Transfer Curve Analysis %s in "Transfer Curve Analysis" sheet', num2str(i));
            device_names{end+1} = extractor.getExcelValue('device_name', 'char', 2);
        end
        inducer_names{end+1} = col_names{i};
    end
    
    for i=1:numel(col_names)
        sample_names = {};
        file_names = {};
        device_name = device_names{i};
        inducer_name = inducer_names{i};
        stemName = stemNames{i};
        TASBEConfig.set('OutputSettings.DeviceName', device_names{i});
        TASBEConfig.set('plots.plotPath', plotPaths{i});
        outputName = outputNames{i};
        % Go though sample rows of selected column and add to cell arrays
        for j=first_sample_row:extractor.getRowNum('last_sample_num')
            try
                value = extractor.getExcelValuePos(sh_num2, j, col_nums{i}, 'numeric');
                if isempty(comp_groups{i}) || extractor.getExcelValuePos(sh_num2, j, comp_groups{i}{1}) == comp_groups{i}{2}
                    sample_names{end+1} = value;
                    file = getFilename(extractor, j);
                    file_names{end+1} = file;
                end
            catch
                continue
            end
        end

        % Make a map of condition names to file sets
        level_file_pairs = {};
        level_file_pairs(:,1) = sample_names;
        level_file_pairs(:,2) = file_names;
        
        % Go through all possible APs
        for j=1:numel(APs)
            AP = APs{j};
            % Ignore any bins with less than valid count as noise
            try
                coords = extractor.getExcelCoordinates('minValidCount', 3);
                minValidCount = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
                AP=setMinValidCount(AP,minValidCount);
            catch
                TASBESession.warn('transfercurve_analysis_excel', 'ImportantMissingPreference', 'Missing Min Valid Count in "Transfer Curve Analysis" sheet');
            end

            % Add autofluorescence back in after removing for compensation?
            try
                coords = extractor.getExcelCoordinates('autofluorescence', 3);
                autofluorescence = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
                AP=setUseAutoFluorescence(AP,autofluorescence);
            catch
                TASBESession.warn('transfercurve_analysis_excel', 'ImportantMissingPreference', 'Missing Use Auto Fluorescence in "Transfer Curve Analysis" sheet');
            end

            try
                coords = extractor.getExcelCoordinates('minFracActive', 3);
                minFracActive = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
                AP=setMinFractionActive(AP,minFracActive);
            catch
                TASBESession.warn('transfercurve_analysis_excel', 'ImportantMissingPreference', 'Missing Min Fraction Active in "Transfer Curve Analysis" sheet');
            end
            
            if j > 1
                stemName = [stemName '-' num2str(j)];
                outputName_parts = strsplit(outputName, '.');
                outputName = [outputName_parts{1} '-' num2str(j) '.' outputName_parts{2}];
            end
            
            TASBEConfig.set('OutputSettings.StemName', stemName);
            experiment = Experiment(experimentName,{inducer_name}, level_file_pairs);
    
            % Execute the actual analysis
            fprintf('Starting analysis...\n');
            [results, sampleresults] = process_transfer_curve( CM, experiment, AP);

            % Plot how the constitutive fluorescence was distributed
            TASBEConfig.set('histogram.displayLegend',false);
            plot_bin_statistics(sampleresults, getInducerLevelsToFiles(experiment,1));

            % Plot the relation between inducer and input fluorescence
            TASBEConfig.set('OutputSettings.DeviceName',inducer_name);
            plot_inducer_characterization(results);

            % Plot the relation between input and output fluorescence
            TASBEConfig.set('OutputSettings.DeviceName',device_name);
            plot_IO_characterization(results);

            % Save the results of computation
            save('-V7',outputName,'experiment','AP','sampleresults','results');
        end
    end
end
