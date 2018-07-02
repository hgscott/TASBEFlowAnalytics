function [CM] = make_color_model_excel()
    % Reset TASBEConfig and create Excel object
    extractor = Excel;
    extractor.TASBEConfig_updates();
    
    % Set TASBEConfigs and create variables needed to generate the CM
    stem = extractor.getExcelValue('stem', 'char');
    experimentName = extractor.getExcelValue('experimentName', 'char');
    try
        outputName = extractor.getExcelValue('outputName_CM', 'char');
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Output File Name in "Cytometer" sheet');
        outputName = [experimentName '-ColorModel.mat'];
    end
    
    try
        transChannelMin = extractor.getExcelValue('transChannelMin', 'cell');
    catch
        TASBESession.warn('make_color_model_excel', 'MissingPreference', 'Missing Translation Channel Min in "Cytometer" sheet');
        transChannelMin = {};
    end
    
    extractor.setTASBEConfig('beads.rangeMax', 'numeric');
    extractor.setTASBEConfig('plots.plotPath', 'char', 1);
    extractor.setTASBEConfig('beads.beadModel', 'char');
    extractor.setTASBEConfig('beads.beadBatch', 'char');
    extractor.setTASBEConfig('beads.rangeMin', 'numeric');
    extractor.setTASBEConfig('beads.peakThreshold', 'numeric');
    extractor.setTASBEConfig('beads.beadChannel', 'char');
    extractor.setTASBEConfig('beads.secondaryBeadChannel', 'char');
   
    % Extract bead, blank, and all files
    ref_filenames = {'blank','beads','all'};
    output_filenames = {};
    sh_num1 = extractor.getSheetNum('first_sample_num');
    first_sample_row = extractor.getRowNum('first_sample_num');
    sample_num_col = extractor.getColNum('first_sample_num');
    sample_dox_col = extractor.getColNum('first_sample_dox');
    sample_filename_col = extractor.getColNum('first_sample_filename');
    for i=first_sample_row:size(extractor.sheets{sh_num1},1)
        try
            extractor.getExcelValuePos(sh_num1, i, sample_num_col, 'numeric');
        catch
            break
        end
        dose = extractor.getExcelValuePos(sh_num1, i, sample_dox_col, 'char');
        for j=1:numel(ref_filenames)
            if strcmpi(dose, ref_filenames{j})
                file = getFilename(i);
                output_filenames{j} = [stem file];
            end
        end
    end
    beads_file = output_filenames{2};
    blank_file = output_filenames{1};
    all_file = output_filenames{3};
    
    % Autodetect gating with an N-dimensional gaussian-mixture-model
    AGP = AutogateParameters();
    autogate = GMMGating(blank_file,AGP,TASBEConfig.get('plots.plotPath'));
    
    % Dealing with channels 
    print_names = {};
    channel_names = {};
    sample_ids = {};
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
    
    % Obtain channel filenames using sample_ids
    colorfiles = {};
    for i=first_sample_row:size(extractor.sheets{sh_num1},1)
        try
            extractor.getExcelValuePos(sh_num1, i, sample_num_col, 'numeric');
        catch
            break
        end
        dose = extractor.getExcelValuePos(sh_num1, i, sample_dox_col, 'char');
        for j=1:numel(sample_ids)
            if strcmpi(dose, sample_ids{j})
                file = getFilename(i);
                colorfiles{j} = [stem file];
            end
        end
    end
    
    % Included a check to make sure that the number of channels matches with
    % the number in the template
    if numel(channels) ~= extractor.getExcelValue('num_channels', 'numeric')
        TASBESession.warn('make_color_model', 'DimensionMismatch', 'Channel dimensions do not match with number of channels from template');
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
    save('-V7',outputName,'CM');
end




