% Function that uses a template spreadsheet to create and save a Color Model. 
% Inputs include an Excel object.  
function [CM] = make_color_model_excel(path, extractor)
    % Reset and update TASBEConfig 
    extractor.TASBEConfig_updates();
    
    % Set TASBEConfigs and create variables needed to generate the CM
    TASBEConfig.set('template.displayErrors', 1);
    experimentName = extractor.getExcelValue('experimentName', 'char');
    TASBEConfig.set('template.displayErrors', 0);
    try
        outputName = extractor.getExcelValue('outputName_CM', 'char');
        [~, name, ~] = fileparts(outputName);
        outputName = [name '.mat'];
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Output File Name in "Calibration" sheet');
        outputName = [experimentName '-ColorModel.mat'];
    end
    
    try
        outputPath = extractor.getExcelValue('outputPath_CM', 'char');
        javaFileObj = java.io.File(end_with_slash(outputPath));
        if javaFileObj.isAbsolute()
            outputPath = end_with_slash(outputPath);
        else
            outputPath = end_with_slash(fullfile(path, outputPath));
        end
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Output File Path in "Calibration" sheet');
        outputPath = path;
    end
    
    try
        transChannelMin = extractor.getExcelValue('transChannelMin', 'cell');
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Translation Channel Min in "Calibration" sheet');
        transChannelMin = {};
    end
    
    extractor.setTASBEConfig('beads.rangeMax', 'numeric');
    try
        plot_path = extractor.getExcelValue('plots.plotPath', 'char', 1);
        javaFileObj = java.io.File(end_with_slash(plot_path));
        if javaFileObj.isAbsolute()
            plot_path = end_with_slash(plot_path);
        else
            plot_path = end_with_slash(fullfile(path, plot_path));
        end
        TASBEConfig.set('plots.plotPath', plot_path);
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing plot path in "Calibration" sheet');
        plot_path = end_with_slash(fullfile(path, 'plots/'));
        TASBEConfig.set('plots.plotPath', plot_path);
    end
    extractor.setTASBEConfig('beads.beadModel', 'char');
    extractor.setTASBEConfig('beads.beadBatch', 'char');
    extractor.setTASBEConfig('beads.rangeMin', 'numeric');
    extractor.setTASBEConfig('beads.peakThreshold', 'numeric');
    extractor.setTASBEConfig('beads.beadChannel', 'char');
    extractor.setTASBEConfig('beads.secondaryBeadChannel', 'char');
   
    % Extract bead, blank, and all files
    % ref_filenames = {'blank','beads','all'};
    TASBEConfig.set('template.displayErrors', 1);
    ref_filenames = {extractor.getExcelValue('blank_name', 'char'), extractor.getExcelValue('all_name', 'char')};
    TASBEConfig.set('template.displayErrors', 0);
    output_filenames = {};
    sh_num1 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    sample_name_col = extractor.getColNum('first_sample_name');
    % Go through samples in "Samples" sheet and look for matches in name to
    % elements in ref_filenames
    for i=first_sample_row:size(extractor.sheets{sh_num1},1)
        try
            num = extractor.getExcelValuePos(sh_num1, i, sample_num_col, 'numeric');
            name = extractor.getExcelValuePos(sh_num1, i, sample_name_col, 'char');
            if isempty(num)
                break
            end
        catch
            break
        end
        for j=1:numel(ref_filenames)
            if strcmpi(name, ref_filenames{j})
                file = getFilename(extractor, i);
                output_filenames{j} = file{1};
            end
        end
    end
    bead_files = getBeadFile(extractor);
    beads_file = bead_files{1};
    blank_file = output_filenames{1};
    all_file = output_filenames{2};
    
    % Autodetect gating with an N-dimensional gaussian-mixture-model
    AGP = AutogateParameters();
    autogate = GMMGating(blank_file,AGP,TASBEConfig.get('plots.plotPath'));
    
    % Dealing with channels 
    print_names = {};
    channel_names = {};
    sample_ids = {};
    all_channels = false;
    % Determine relevant channels
    try 
        rel_channels = extractor.getExcelValue('relevant_channels', 'cell');
    catch
        % this means that all channels are relevant
        all_channels = true;
    end
    % Create one channel for each color
    channels = {}; 
    sh_num2 = extractor.getSheetNum('first_flchrome_name');
    first_flchrome_row = extractor.getRowNum('first_flchrome_name');
    flchrome_name_col = extractor.getColNum('first_flchrome_name');
    flchrome_channel_col = extractor.getColNum('first_flchrome_channel');
    flchrome_wavlen_col = extractor.getColNum('first_flchrome_wavlen');
    flchrome_filter_col = extractor.getColNum('first_flchrome_filter');
    flchrome_color_col = extractor.getColNum('first_flchrome_color');
    flchrome_id_col = extractor.getColNum('first_flchrome_id');
    for i=first_flchrome_row:size(extractor.sheets{sh_num2},1)
        try
            print_name = extractor.getExcelValuePos(sh_num2, i, flchrome_name_col, 'char');
        catch
            break
        end
        ind = i - (first_flchrome_row-1);
        if all_channels || ~isempty(find([rel_channels{:}] == ind, 1))
            % Extract the rest of the information for the channel
            channel_name = extractor.getExcelValuePos(sh_num2, i, flchrome_channel_col, 'char');
            excit_wavelen = extractor.getExcelValuePos(sh_num2, i, flchrome_wavlen_col, 'numeric');
            filter = strsplit(extractor.getExcelValuePos(sh_num2, i, flchrome_filter_col, 'char'), '/');
            color = extractor.getExcelValuePos(sh_num2, i, flchrome_color_col, 'char');
            print_names{ind} = print_name;
            channel_names{ind} = channel_name;
            channels{ind} = Channel(channel_name, excit_wavelen, str2double(filter{1}), str2double(filter{2}));
            channels{ind} = setPrintName(channels{ind}, print_name); % Name to print on charts
            channels{ind} = setLineSpec(channels{ind}, color); % Color for lines, when needed
            try
                id = extractor.getExcelValuePos(sh_num2, i, flchrome_id_col, 'char');
            catch
                id = print_name;
            end
            sample_ids{ind} = id;
        end
    end
    
    % Obtain channel filenames using sample_ids
    colorfiles = {};
    for i=first_sample_row:size(extractor.sheets{sh_num1},1)
        try
            num = extractor.getExcelValuePos(sh_num1, i, sample_num_col, 'numeric');
            name = extractor.getExcelValuePos(sh_num1, i, sample_name_col, 'char');
            if isempty(num)
                break
            end
        catch
            break
        end
        for j=1:numel(sample_ids)
            if strcmpi(name, sample_ids{j})
                file = getFilename(extractor, i);
                colorfiles{j} = file{1};
            end
        end
    end
    
    % Included a check to make sure that the number of channels matches with
    % the number in the template
    if numel(channels) ~= extractor.getExcelValue('num_channels', 'numeric')
        TASBESession.warn('make_color_model_excel', 'DimensionMismatch', 'Channel dimensions do not match with number of channels from template');
    end

    % Multi-color controls are used for converting other colors into FITC units
    colorpairfiles = {};
    % Entries are: channel1, channel2, constitutive channel, filename
    % This allows channel1 and channel2 to be converted into one another.
    % If you only have two colors, you can set consitutive-channel to equal channel1 or channel2
    n_channels = numel(channels);
    if n_channels == 2
        colorpairfiles{1} = {channels{1}, channels{2}, channels{2}, all_file};
    else
        for i=1:n_channels-1
            if i >= 2
                colorpairfiles{end+1} = {channels{1}, channels{i+1}, channels{i-1}, all_file};
            else
                colorpairfiles{end+1} = {channels{1}, channels{i+1}, channels{i+2}, all_file};
            end
        end
    end

    % Making the color model
    CM = ColorModel(beads_file, blank_file, channels, colorfiles, colorpairfiles);
    CM = set_ERF_channel_name(CM, channel_names{1});
    CM = add_prefilter(CM,autogate);
    
    if ~isempty(transChannelMin) 
        CM = set_translation_channel_min(CM,cell2mat(transChannelMin));
    end
    
    % Execute and save the model
    CM = resolve(CM);
    if ~isdir(outputPath)
        sanitized_path = strrep(outputPath, '/', '&#47;');
        sanitized_path = strrep(sanitized_path, '\', '&#92;');
        sanitized_path = strrep(sanitized_path, ':', '&#58;');
        TASBESession.notify('TASBE:OutputFig','MakeDirectory','Directory does not exist, attempting to create it: %s',sanitized_path);
        mkdir(outputPath);
    end
    save('-V7',[outputPath, outputName],'CM');
    % save('-V7',outputName,'CM');
    
    % Conduct bead comparisons if applicable
    % If size of beadfiles is greater than 1, then run bead comparisons
    if numel(bead_files) > 1
        try
            tolerance = extractor.getExcelValue('bead_tolerance', 'numeric');
        catch
            tolerance = 0.5;
            TASBESession.notify('make_color_model_excel', 'MissingPreference', 'Bead comparison tolerance defaulting to 0.5');
        end
        
        for i=2:numel(bead_files)
            [ok, ratios] = check_beads_identical(CM, bead_files{i}, tolerance);
            TASBESession.notify('make_color_model_excel', 'BeadCompRatio', 'Ratios between peaks: %.2f \n', ratios);
            % A warning is thrown if two beadfiles are not considered identical
            if ok
                TASBESession.succeed('make_color_model_excel', 'Identical', 'Bead files are sufficiently identical to each other');
            else
                TASBESession.warn('make_color_model_excel', 'NotIdentical', 'Bead files are not identical to each other!');
            end
        end
    end
end
