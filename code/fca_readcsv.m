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
    filenames = fcshdr.filename;
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
    [fcshdr,filenames] = fca_readcsv_header(header);
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

% consider both absolute and relative in comparing with filenames
HdrPath = fileparts(hdrfilename);
% Check if file is in the set covered by the header
file_match = 0;
filename_to_compare = strrep(filename, '\', '/');
for i=1:numel(filenames)
    temp_filename = filenames{i};
    temp_filename = strrep(temp_filename, '\', '/');
    if strcmp(temp_filename, filename_to_compare) || strcmp(strcat(HdrPath, '/', temp_filename),filename_to_compare)
        file_match = 1;
        break
    end
end
if file_match ~= 1
    TASBESession.warn('fca_readcsv','FilenameMismatch','CSV file %s is not listed in JSON header %s',filename,hdrfilename);
end


% Read in the data
if is_octave()
    T = csv2cell(filename);
    VarNames = T(1,:);
    % TotalEvents is number of rows
    fcshdr.TotalEvents = size(T(2:end,:),1);
else
    T = readtable(filename);
    VarNames = T.Properties.VariableNames;
    % TotalEvents is number of rows
    fcshdr.TotalEvents = height(T);
end
n_channels = size(VarNames,2);
if n_channels ~= fcshdr.NumOfPar
    TASBESession.error('fca_readcsv', 'NumParameterMismatch', 'Number of columns in CSV %s not equal to number of channels specified in JSON header file %s',filename,hdrfilename);
end

% Optionally truncate events to avoid memory problems with extremely large FCS files -JSB
if fcshdr.TotalEvents>clip_events
    TASBESession.warn('FCS:Read','TooManyEvents','FCS file has more than %i events; truncating to avoid memory problems',clip_events);
    fcshdr.TotalEvents = clip_events;
end

% Reading the events by setting fcsdat
if is_octave()
    T2 = cell2mat(T(2:end,:));
    fcsdat = double(T2);
else
    fcsdat = double(table2array(T));
end

% I don't believe we need fcsdatscaled because we don't have any log scales
fcsdatscaled = fcsdat;

end

