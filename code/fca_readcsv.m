function [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename, header, clip_events)
% [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename, header, clip_events);
%    Read the CSV pointed to by 'filename'
%    Interpreting channels according to the JSON header (which may be a filename or an already-parsed struct)
%    clip_events is optional; if set, drop any events above that count; default is 1e6
%
% Read CSV of flow cytometry data file and put the list mode  
% parameters to the fcsdat array with size of [NumOfPar TotalEvents]. 
% Some important header data are stored in the fcshdr structure:
% TotalEvents, NumOfPar, name

% default the clip events if necessary
if nargin<3, clip_events = 1e6; end

% Check that file is available
if isempty(filename)
    TASBESession.warn('CSV:Read','NoFile','No file provided! Returning empty dataset.'); 
    fcsdat = []; fcshdr = []; fcsdatscaled = [];
    return;
end
filecheck = dir(filename);
if size(filecheck,1) == 0
    TASBESession.warn('CSV:Read','NoFile',[filename,': The file does not exist! Returning empty dataset.']); 
    fcsdat = []; fcshdr = []; fcsdatscaled = [];
    return;
end

% Is header already a struct, or is it a filename to be read?
if isstruct(header) 
    fcshdr = header;
    hdrfilename = fcshdr.filepath;
else % assume it's a file name
    hdrfilename = header;
    filecheck = dir(header);
    if size(filecheck,1) == 0
        TASBESession.warn('CSV:Read','NoHeaderFile',[header,': The header file does not exist! Returning empty dataset.']); 
        fcsdat = []; fcshdr = []; fcsdatscaled = [];
        return;
    end
    % Read in header info
    fcshdr = fca_readcsv_header(header);
end
% check if header lists csv
if ~header_lists_csv(fcshdr,filename)
    TASBESession.warn('fca_readcsv','FilenameMismatch','CSV file %s is not listed in JSON header %s',filename,hdrfilename);
end


% If filename arg. only contain PATH, set the default dir to this
% before issuing the uigetfile command. This is an option for the "fca"
% tool
[FilePath, FileNameMain, fext] = fileparts(filename);
FilePath = [FilePath filesep];
FileName = [FileNameMain, fext];
if  isempty(FileNameMain)
    current_dir = cd;
    cd(FilePath);
    [FileName, FilePath] = uigetfile('*.*','Select CSV file');
     filename = [FilePath,FileName];
     if FileName == 0
          fcsdat = []; fcshdr = [];
          return;
     end
     cd(current_dir);
end

% add the name and path for this particular file to the filename
fcshdr.filename = FileName;
fcshdr.filepath = FilePath;

% Read in the data
if is_octave()
    T = csv2cell(filename);
    VarNames = T(1,:);
    % TotalEvents is number of rows
    fcshdr.TotalEvents = size(T(2:end,:),1);
else
    T = readtable(filename,'ReadVariableNames',false);
    VarNames = table2cell(T(1,:));
    T = readtable(filename,'ReadVariableNames',false,'HeaderLines',1);
    % TotalEvents is number of rows
    fcshdr.TotalEvents = height(T);
end

% Throw mismatch error if number of columns in CSV is less than number of
% channels in header
n_channels = size(VarNames,2);
if n_channels < fcshdr.NumOfPar
    TASBESession.error('fca_readcsv', 'NumParameterMismatch', 'Number of columns in CSV %s is less than the number of channels specified in JSON header file %s',filename,hdrfilename);
end

% Optionally truncate events to avoid memory problems with extremely large FCS files -JSB
if fcshdr.TotalEvents>clip_events
    TASBESession.warn('FCS:Read','TooManyEvents','FCS file has more than %i events; truncating to avoid memory problems',clip_events);
    fcshdr.TotalEvents = clip_events;
end

% Go through print names in header and see if they are in any of the CSV
% column headers
num_channel = fcshdr.NumOfPar;
num_matched = 0;
num_oldmatched = -1;
columns = cell(num_channel, 1);
unmatched_channels = num2cell(1:num_channel);
csv_headers = VarNames;

while (num_matched < num_channel) 
    % Search through channels
    for i=1:size(unmatched_channels,2)
        channel_index = unmatched_channels{i};
        if isempty(channel_index)
            continue
        end
        print_name = fcshdr.par(channel_index).print_name;
        name = fcshdr.par(channel_index).name;
        match = precise_match(csv_headers, print_name, name);
        if ~isempty(match)
            % Add to columns and remove from csv header and unmatched_channels
            columns{channel_index} = match;
            csv_headers{match} = '';
            unmatched_channels{i} = [];
            num_matched = num_matched + 1;
        end
    end
    % Throw an error if no new matches were obtained (hit dead end)
    if num_oldmatched ~= num_matched
        num_oldmatched = num_matched;
    else
        TASBESession.error('fca_readcsv', 'DuplicateChannel', 'Multiple channels can be subsets of the same csv header');
    end
end

% Reading the events by setting fcsdat
if is_octave()
    T2 = cell2mat(T(2:end,cell2mat(columns)));
    fcsdat = double(T2);
else
    fcsdat = double(table2array(T(1:end,cell2mat(columns))));
end

% I don't believe we need fcsdatscaled because we don't have any log scales
fcsdatscaled = fcsdat;

end

function match = precise_match(VarNames, print_name, name)
    index_print_name = ~cellfun('isempty',strfind(VarNames,print_name));
    index_name = ~cellfun('isempty',strfind(VarNames,name));
    if ~any([index_print_name index_name])
        % Throw error
        TASBESession.error('fca_readcsv', 'MissingChannel', 'Channel %s is missing from column header in csv file', print_name);
    % There is at least one match, check if either index_print_name or
    % index_name has exactly one match
    elseif sum(index_print_name) == 1
        match = find(index_print_name);
    elseif sum(index_name) == 1
        match = find(index_name);
    else
        % Look for precise matching in either index_print_name or
        % index_name
        eq_index_print_name = strcmp(VarNames,print_name);
        eq_index_name = strcmp(VarNames,name);
        if sum(eq_index_print_name) == 1
            match = find(eq_index_print_name);
        elseif sum(eq_index_name) == 1
            match = find(eq_index_name);
        % If no precise match found, then return no match
        elseif sum(eq_index_print_name) > 1 || sum(eq_index_name) > 1
            % Return no match if more than one precise match found
            match = [];
        else
            % Return no match if no precise match found
            match = [];
        end
    end
end

