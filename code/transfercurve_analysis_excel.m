% Function that runs transfer curve analysis given a template spreadsheet. An Excel
% object and optional Color Model are inputs
function transfercurve_analysis_excel(extractor, CM)
    % Reset and update TASBEConfig and get exp, device, and inducer names
    extractor.TASBEConfig_updates();
    experimentName = extractor.getExcelValue('experimentName', 'char');
    device_name = extractor.getExcelValue('device_name', 'char', 2);
    TASBEConfig.set('OutputSettings.DeviceName',device_name);
    inducer_name = extractor.getExcelValue('inducer_name', 'char', 2);

    % Load the color model
    if nargin < 2
        try
            CM_file = extractor.getExcelValue('inputName_CM', 'char', 3); 
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

    % Set TASBEConfigs and create variables needed to run transfer curve analysis
    try
        outputName = extractor.getExcelValue('outputName_TC', 'char');
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Output File Name for Transfer Curve Analysis in "Transfer Curve Analysis" sheet');
        outputName = [experimentName '-TransAnalysis.mat'];
    end

    try 
        stemName = extractor.getExcelValue('OutputSettings.StemName', 'char', 3);
        TASBEConfig.set('OutputSettings.StemName', stemName);
    catch
        TASBESession.warn('make_color_model', 'MissingPreference', 'Missing Stem Name in "Transfer Curve Analysis" sheet');
        TASBEConfig.set('OutputSettings.StemName', experimentName);
    end

    extractor.setTASBEConfig('plots.plotPath', 'char', 4);
    % Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
    try
        binseq_min = extractor.getExcelValue('binseq_min', 'numeric', 3);
        binseq_max = extractor.getExcelValue('binseq_max', 'numeric', 3);
        binseq_pdecade = extractor.getExcelValue('binseq_pdecade', 'numeric', 3);
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
        minValidCount = extractor.getExcelValue('minValidCount', 'numeric', 3);
        AP=setMinValidCount(AP,minValidCount);
    catch
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Min Valid Count in "Transfer Curve Analysis" sheet');
    end

    % Add autofluorescence back in after removing for compensation?
    try
        autofluorescence = extractor.getExcelValue('autofluorescence', 'numeric', 3);
        AP=setUseAutoFluorescence(AP,autofluorescence);
    catch
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Use Auto Fluorescence in "Transfer Curve Analysis" sheet');
    end

    try
        minFracActive = extractor.getExcelValue('minFracActive', 'numeric', 3);
        AP=setMinFractionActive(AP,minFracActive);
    catch
        TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Min Fraction Active in "Transfer Curve Analysis" sheet');
    end
   
    % Obtain the necessary sample filenames and print names
    sample_names = {};
    file_names = {};
    sh_num2 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    col_name = extractor.getExcelValue('sampleColName_TC', 'char'); 
    col_num = 0;
    % Go through columns to find column number
    for i=sample_num_col:size(extractor.sheets{sh_num2},2)
        try 
            ref_header = extractor.getExcelValuePos(sh_num2, first_sample_row-1, i, 'char');
        catch
            try
                ref_header = num2str(extractor.getExcelValuePos(sh_num2, first_sample_row-1, i, 'numeric'));
                if isempty(ref_header)
                    TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, in "Transfer Curve Analysis" does not match with any column name in "Samples".', col_name);
                    break
                end
            catch 
                TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, in "Transfer Curve Analysis" does not match with any column name in "Samples".', col_name);
                break
            end
        end
        if strcmp(col_name, ref_header)
            col_num = i;
            break
        end 
    end
    % Go though comparison groups and store values and column numbers in
    % cell array
    comp_groups = {};
    sh_num3 = extractor.getSheetNum('first_sampleColName_TC');
    first_group_row = extractor.getRowNum('first_sampleColName_TC');
    first_group_col = extractor.getColNum('first_sampleColName_TC');
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
                        TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Transfer Curve Analysis" does not match with any column name in "Samples".', col_name);
                        break
                    end
                catch 
                    TASBESession.error('transfercurve_analysis_excel', 'InvalidColumnName', 'Sample column name, %s, under Comparison Groups in "Transfer Curve Analysis" does not match with any column name in "Samples".', col_name);
                    break
                end
            end
            if strcmp(col_name, ref_header)
                comp_groups{end+1} = {j, extractor.getExcelValuePos(sh_num3, i, extractor.getColNum('first_sampleVal_TC'))};
                break
            end 
        end
    end
    % Go though sample rows of selected column and add to cell arrays
    for i=first_sample_row:extractor.getRowNum('last_sample_num')
        try
            value = extractor.getExcelValuePos(sh_num2, i, col_num, 'numeric');
            if extractor.getExcelValuePos(sh_num2, i, comp_groups{1}{1}) == comp_groups{1}{2} % only works for the first comp group currently
                sample_names{end+1} = value;
                file = getFilename(extractor, i);
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
