
function writePointCloudHeader(CM, filenames)
    % create JSON file of point cloud header (one for each batch)
    % header consists of the channel names
    path = TASBEConfig.get('flow.pointCloudPath');
    path = end_with_slash(path);
    if ~isdir(path)
        TASBESession.notify('TASBE:Utilities','MakeDirectory','Directory does not exist, attempting to create it: %s',path);
        mkdir(path);
    end
    channels = getChannels(CM);
    channel_names = {};
    print_names = {};
    units = {};
    for i=1:numel(channels)
        channel_names{end+1} = getName(channels{i});
        print_names{end+1} = getPrintName(channels{i});
        units{end+1} = getUnits(channels{i});
    end
    %display(channel_names);
    %display(print_names);
    %display(units);
    string = savejson('', [{numel(channels)} channel_names print_names units {numel(filenames)} filenames]);
    %string = jsonencode([{numel(channels)} channel_names print_names units {numel(filenames)} filenames]);
    filename = strcat(path, TASBEConfig.get('OutputSettings.StemName'), '.json');
    fid = fopen(filename, 'w');
    if fid == -1, error('Cannot create JSON file'); end
    fwrite(fid, string, 'char');
    fclose(fid);
    %save(filename, 'string');
end