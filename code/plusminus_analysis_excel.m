% Function that runs plusminus analysis given a template spreadsheet. An Excel
% object and optional Color Model are inputs
function plusminus_analysis_excel(extractor, CM)
    % Reset and update TASBEConfig and get exp, device, and inducer names
    extractor.TASBEConfig_updates();
    experimentName = extractor.getExcelValue('experimentName', 'char');
    device_name = extractor.getExcelValue('device_name', 'char', 1);
    TASBEConfig.set('OutputSettings.DeviceName',device_name);
    inducer_name = extractor.getExcelValue('inducer_name', 'char', 1);

    % Load the color model
    if nargin < 2
        try
            CM_file = extractor.getExcelValue('inputName_CM', 'char', 2); 
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
            CM = make_color_model_excel();
        end
    end

    % Set TASBEConfigs and create variables needed to run plusminus analysis
    try
        outputName = extractor.getExcelValue('outputName_PM', 'char');
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Output File Name for Plusminus Analysis in "Comparative Analysis" sheet');
        outputName = [experimentName '-CompAnalysis.mat'];
    end

    try 
        stemName = extractor.getExcelValue('OutputSettings.StemName', 'char', 2);
        TASBEConfig.set('OutputSettings.StemName', stemName);
    catch
        TASBESession.warn('make_color_model', 'MissingPreference', 'Missing Stem Name in "Comparative Analysis" sheet');
        TASBEConfig.set('OutputSettings.StemName', experimentName);
    end

    extractor.setTASBEConfig('plots.plotPath', 'char', 3);
    % Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
    try
        binseq_min = extractor.getExcelValue('binseq_min', 'numeric', 2);
        binseq_max = extractor.getExcelValue('binseq_max', 'numeric', 2);
        binseq_pdecade = extractor.getExcelValue('binseq_pdecade', 'numeric', 2);
        bins = BinSequence(binseq_min, (1/binseq_pdecade), binseq_max, 'log_bins');
    catch
        bins = BinSequence();
    end

    % Designate which channels have which roles
    ref_channels = {'constitutive', 'input', 'output'};
    outputs = {};
    print_names = {};
    sh_num1 = extractor.getSheetNum('first_flchrome_name');
    first_flchrome_row = extractor.getRowNum('first_flchrome_name');
    flchrome_name_col = extractor.getColNum('first_flchrome_name');
    flchrome_type_col = extractor.getColNum('first_flchrome_type');
    for i=first_flchrome_row:size(extractor.sheets{sh_num1},1)
        try
            print_name = extractor.getExcelValuePos(sh_num1, i, flchrome_name_col, 'char');
        catch
            break
        end
        print_names{end+1} = print_name;
        try
            channel_type = extractor.getExcelValuePos(sh_num1, i, flchrome_type_col, 'char');
        catch
            continue
        end
        for j=1:numel(ref_channels)
            if strcmpi(ref_channels{j}, channel_type)
                outputs{j} = channel_named(CM, print_name);
            end
        end
    end

    if numel(outputs) == 3
        AP = AnalysisParameters(bins,{'input',outputs{2}; 'output',outputs{3}; 'constitutive',outputs{1}});
    else
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing constitutive, input, output in "Calibration" sheet');
        AP = AnalysisParameters(bins,{});
    end

    % Ignore any bins with less than valid count as noise
    try
        minValidCount = extractor.getExcelValue('minValidCount', 'numeric', 2);
        AP=setMinValidCount(AP,minValidCount);
    catch
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Min Valid Count in "Comparative Analysis" sheet');
    end

    % Add autofluorescence back in after removing for compensation?
    try
        autofluorescence = extractor.getExcelValue('autofluorescence', 'numeric', 2);
        AP=setUseAutoFluorescence(AP,autofluorescence);
    catch
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Use Auto Fluorescence in "Comparative Analysis" sheet');
    end

    try
        minFracActive = extractor.getExcelValue('minFracActive', 'numeric', 2);
        AP=setMinFractionActive(AP,minFracActive);
    catch
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Min Fraction Active in "Comparative Analysis" sheet');
    end
    
    % TO DO: NEED TO MODIFY FOR PLUSMINUS
    % Obtain the necessary sample filenames and print names
    sample_names = {};
    file_names = {};
    sh_num2 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    col_names = {extractor.getExcelValue('primary_sampleColName_PM', 'char'), extractor.getExcelValue('secondary_sampleColName_PM', 'char')}; 
    col_nums = {};
    % Go through columns to find column number of primary and secondary col names
    for i=sample_num_col:size(extractor.sheets{sh_num2},2)
        try 
            ref_header = extractor.getExcelValuePos(sh_num2, first_sample_row-1, i, 'char');
        catch
            try
                ref_header = num2str(extractor.getExcelValuePos(sh_num2, first_sample_row-1, i, 'numeric'));
                if isempty(ref_header)
                    break
                end
            catch 
                break
            end
        end
        ind = find(ismember(col_names, ref_header), 1);
        if ~isempty(ind)
            col_nums{ind} = i;
        end
    end
    if numel(col_nums) ~= 2
        TASBESession.error('plusminus_analysis_excel', 'InvalidColumnName', 'Primary/secondary column names in "Comparative Analysis" does not match with any column name in "Samples".');
    end
    
    % Go though comparison groups and store values and column numbers in
    % cell array
    comp_groups = {};
    sh_num3 = extractor.getSheetNum('first_sampleColName_PM');
    first_group_row = extractor.getRowNum('first_sampleColName_PM');
    first_group_col = extractor.getColNum('first_sampleColName_PM');
    for i=first_group_row:size(extractor.sheets{sh_num3},1)
        try
            col_name = extractor.getExcelValuePos(sh_num3, i, first_group_col, 'char');
        catch
            try
                col_name = num2str(extractor.getExcelValuePos(sh_num3, i, first_group_col, 'numeric'));
                if isempty(col_name)
                    break
                end
            catch 
                break
            end
        end
        % Get column number of col_name
        for j=sample_num_col:size(extractor.sheets{sh_num2},2)
            try 
                ref_header = extractor.getExcelValuePos(sh_num2, first_sample_row-1, j, 'char');
            catch
                try
                    ref_header = num2str(extractor.getExcelValuePos(sh_num2, first_sample_row-1, j, 'numeric'));
                    if isempty(ref_header)
                        TASBESession.error('plusminus_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Comparative Analysis" does not match with any column name in "Samples".', col_name);
                        break
                    end
                catch 
                    TASBESession.error('plusminus_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Comparative Analysis" does not match with any column name in "Samples".', col_name);
                    break
                end
            end
            if strcmp(col_name, ref_header)
                comp_groups{end+1} = {j, extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('first_sampleVal_PM'))};
                break
            end 
        end
    end
    
    % Get list of distinct values from primary sample column name using
    % condition key col_nums{1}. Also get list of distinct values (in
    % order) from secondary sample column name
    condition_col = extractor.getColNum('first_condition_key');
    condition_sh = extractor.getSheetNum('first_condition_key');
    first_condition_row = extractor.getRowNum('first_condition_key');
    keys = {};
    for i=first_condition_row:size(extractor.sheets{condition_sh}, 1)
        try
            value = extractor.getExcelValuePos(condition_sh, i, condition_col, 'char');
            if ~isempty(strfind(value, 'Sample Column Name'))
                try
                    column_name = extractor.getExcelValuePos(condition_sh, i, condition_col+1, 'char');
                    ind = find(ismember(col_names, column_name), 1);
                    if ~isempty(ind)
                        % get keys
                        key = {};
                        for j=i+2:size(extractor.sheets{condition_sh}, 1)
                            try
                                key{end+1} = extractor.getExcelValuePos(condition_sh, j, condition_col, 'char');
                            catch
                                try
                                    key{end+1} = num2str(extractor.getExcelValuePos(condition_sh, j, condition_col, 'numeric'));
                                catch
                                    break
                                end
                            end
                        end
                        keys{end+1} = key;
                    end
                    extractor.checkConditions_helper(i, column_name);
                catch
                    try
                        column_name = num2str(extractor.getExcelValuePos(condition_sh, i, condition_col+1, 'numeric'));
                        extractor.checkConditions_helper(i, column_name);
                    catch
                        continue
                    end
                end
            end
        catch
            continue
        end
    end
                    
    % Find the different sets for each group 
    
    % Reorder the sample within the sets if applicable to match with the
    % order of the secondary sample column name (else just keep old order)
    
%     for i=first_sample_row:size(extractor.sheets{sh_num2},1)
%         try
%             num = extractor.getExcelValuePos(sh_num2, i, sample_num_col, 'numeric');
%             if isempty(num)
%                 break
%             end
%         catch
%             break
%         end
%         % check if sample should be included in batch analysis
%         try
%             extractor.getExcelValuePos(sh_num2, i, sample_exclude_col, 'char');
%         catch
%             sample_names{end+1} = extractor.getExcelValuePos(sh_num2, i, sample_name_col, 'char');
%             file = getFilename(extractor, i);
%             files = {};
%             for j=1:numel(file)
%                 files{end+1} = file{j};
%             end
%             file_names{end+1} = files;
%         end
%     end
% 
%     % Make a map of condition names to file sets
%     file_pairs = {};
%     file_pairs(:,1) = sample_names;
%     file_pairs(:,2) = file_names;
%     
%     % Make a map of the batches comparisons to test, add in a list of batch
%     % names (e.g., {'+', '-'}) to signify possible sets.
%     % This analysis supports two variables: a +/- variable and a "tuning" variable
%     stem1011 = '../../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';
%     batch_description = {...
%      {'Lows';'BaseDox';{'+', '-', 'control'};
%       % First set is the matching "plus" conditions
%       {0.1,  {[stem1011 'C3_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
%        0.2,  {[stem1011 'C4_P3.fcs']}};
%       {0.1,  {[stem1011 'B3_P3.fcs']};
%        0.2,  {[stem1011 'B4_P3.fcs']}};
%       {0.1,  {[stem1011 'B9_P3.fcs']}; 
%        0.2,  {[stem1011 'B10_P3.fcs']}}};
%      {'Highs';'BaseDox';{'+', '-'};
%       {10,   {[stem1011 'C3_P3.fcs']};
%        20,   {[stem1011 'C4_P3.fcs']}};
%       {10,   {[stem1011 'B9_P3.fcs']};
%        20,   {[stem1011 'B10_P3.fcs']}}};
%      };
% 
%     % Execute the actual analysis
%     results = process_plusminus_batch( CM, batch_description, AP);
% 
%     % Make additional output plots
%     for i=1:numel(results)
%         TASBEConfig.set('OutputSettings.StemName',batch_description{i}{1});
%         TASBEConfig.set('OutputSettings.DeviceName',device_name);
%         plot_plusminus_comparison(results{i}, batch_description{i}{3});
%     end
% 
%     save('-V7',outputName,'batch_description','AP','results');
end
