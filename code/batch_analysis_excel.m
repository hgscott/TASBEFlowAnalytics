% Function that runs batch analysis given a template spreadsheet. An Excel
% object and optional Color Model are inputs
function batch_analysis_excel(extractor, CM)
    % Reset and update TASBEConfig and obtain experiment name
    extractor.TASBEConfig_updates();
    experimentName = extractor.getExcelValue('experimentName', 'char');
    
    preference_row = extractor.getRowNum('last_sample_num') + 5;

    % Load the color model
    if nargin < 2
        try
            coords = extractor.getExcelCoordinates('inputName_CM', 1);
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

    % Set TASBEConfigs and create variables needed to run batch analysis
    coords = extractor.getExcelCoordinates('plots.plotPath', 2);
    TASBEConfig.set('plots.plotPath', extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'char'));

    % Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
    try
        coords = extractor.getExcelCoordinates('binseq_min', 1);
        binseq_min = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        coords = extractor.getExcelCoordinates('binseq_max', 1);
        binseq_max = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        coords = extractor.getExcelCoordinates('binseq_pdecade', 1);
        binseq_pdecade = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
        bins = BinSequence(binseq_min, (1/binseq_pdecade), binseq_max, 'log_bins');
    catch
        bins = BinSequence();
    end

    % Designate which channels have which roles
    [channel_roles, print_names] = getChannelRoles(CM, extractor);
    
    if isempty(channel_roles)
        TASBESession.warn('batch_analysis_excel', 'MissingPreference', 'Missing constitutive, input, output in "Calibration" sheet');
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
    sh_num2 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    sample_name_col = extractor.getColNum('first_sample_name');
    sample_exclude_col = extractor.getColNum('first_sample_exclude');
    for i=first_sample_row:size(extractor.sheets{sh_num2},1)
        try
            num = extractor.getExcelValuePos(sh_num2, i, sample_num_col, 'numeric');
            if isempty(num)
                break
            end
        catch
            break
        end
        % check if sample should be included in batch analysis
        try
            extractor.getExcelValuePos(sh_num2, i, sample_exclude_col, 'char');
        catch
            sample_names{end+1} = extractor.getExcelValuePos(sh_num2, i, sample_name_col, 'char');
            file = getFilename(extractor, i);
            file_names{end+1} = file;
        end
    end

    % Make a map of condition names to file sets
    file_pairs = {};
    file_pairs(:,1) = sample_names;
    file_pairs(:,2) = file_names;
    
    for i=1:numel(APs)
        AP = APs{i};
        try
            coords = extractor.getExcelCoordinates('outputName_BA'); 
            outputName = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'char');  
        catch
            TASBESession.warn('batch_analysis_excel', 'MissingPreference', 'Missing Output File Name for Batch Analysis in "Samples" sheet');
            outputName = [experimentName '-BatchAnalysis.mat'];
        end

        try 
            coords = extractor.getExcelCoordinates('OutputSettings.StemName', 1);   
            stemName = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'char');
        catch
            TASBESession.warn('batch_analysis_excel', 'MissingPreference', 'Missing Stem Name in "Samples" sheet');
            stemName = experimentName;
        end
        
        if i > 1
            outputName_parts = strsplit(outputName, '.');
            outputName = [outputName_parts{1} num2str(i) '.' outputName_parts{2}];
            stemName = [stemName num2str(i)];
        end
        
        TASBEConfig.set('OutputSettings.StemName', stemName);
        
        % Ignore any bins with less than valid count as noise
        try
            coords = extractor.getExcelCoordinates('minValidCount', 1);
            minValidCount = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
            AP=setMinValidCount(AP,minValidCount);
        catch
            TASBESession.warn('batch_analysis_excel', 'ImportantMissingPreference', 'Missing Min Valid Count in "Samples" sheet');
        end

        % Add autofluorescence back in after removing for compensation?
        try
            coords = extractor.getExcelCoordinates('autofluorescence', 1);
            autofluorescence = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
            AP=setUseAutoFluorescence(AP,autofluorescence);
        catch
            TASBESession.warn('batch_analysis_excel', 'ImportantMissingPreference', 'Missing Use Auto Fluorescence in "Samples" sheet');
        end

        try
            coords = extractor.getExcelCoordinates('minFracActive', 1);
            minFracActive = extractor.getExcelValuePos(coords{1}, preference_row, coords{3}, 'numeric');
            AP=setMinFractionActive(AP,minFracActive);
        catch
            TASBESession.warn('batch_analysis_excel', 'ImportantMissingPreference', 'Missing Min Fraction Active in "Samples" sheet');
        end

        [results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,print_names,AP);

        % Make output plots
        plot_batch_histograms(results,sampleresults,CM);

        [statisticsFile, histogramFile] = serializeBatchOutput(file_pairs, CM, AP, sampleresults);

        save(outputName,'AP','bins','file_pairs','results','sampleresults');
    end
end
