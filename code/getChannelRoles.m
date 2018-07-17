function [channel_roles, print_names] = getChannelRoles(CM, extractor)
    % Designate which channels have which roles
    ref_channels = {'constitutive', 'input', 'output'};
    num_channels = 0;
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
            % Ignore the fluorochromes with nothing in channel type column
            continue
        end
        ind = find(ismember(ref_channels, channel_type), 1);
        if ~isempty(ind)
            num_channels = num_channels + 1;
            try 
                isempty(outputs{ind})
                outputs{ind}{end+1} = channel_named(CM, print_name);
            catch
                outputs{ind} = {channel_named(CM, print_name)};
            end
            continue
        end
        TASBESession.warn('getChannelRoles', 'PotentialTypo', 'A channel type of %s does not match with the options constitutive, input, or output', channel_type);
    end
    
    % There should only one constitutive
    if ~isempty(outputs) && numel(outputs{1}) ~= 1
        TASBESession.warn('getChannelRoles', 'IncorrectNumber', 'Exactly one constitutive channel is allowed');
    end
    
    channel_roles = {};
    
    % There needs to be at least 2 colors
    if num_channels < 2
        TASBESession.warn('getChannelRoles', 'TooFew', 'There needs to be at least two designated channel types');
    % 2 color case, input and output are from the same channel
    elseif num_channels == 2
        if ~isempty(outputs{2})
            channel = outputs{2}{end};
        else
            channel = outputs{3}{end};
        end
        channel_roles = {{'input',channel; 'output',channel; 'constitutive',outputs{1}{end}}};
    % 3+ color case, pairwise matching of input & output
    else
        input = outputs{2};
        output = outputs{3};
        if isempty(input) || isempty(output)
            TASBESession.warn('getChannelRoles', 'MissingTypes', 'At least two channels should be marked as input and output');
        end
        % Double for loop to get all pairwise combinations between input
        % and ouput
        for j=1:numel(input)
            for k=1:numel(output)
                channel_roles{end+1} = {'input',input{j}; 'output',output{k}; 'constitutive',outputs{1}{end}};
            end
        end
    end 
end