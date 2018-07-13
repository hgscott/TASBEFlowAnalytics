function channel_roles = getChannelRoles(extractor)
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

    channel_roles = {};
    % channel_roles should be in the format {'input',outputs{2}; 'output',outputs{3}; 'constitutive',outputs{1}}
    % it is directly passed into the constuctor of AP
end