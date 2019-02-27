function [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename, headername, clip_events)
% [fcsdat, fcshdr, fcsdatscaled] = fca_readcsv(filename);
%
% Read CSV of flow cytometry data file and put the list mode  
% parameters to the fcsdat array with size of [NumOfPar TotalEvents]. 
% Some important header data are stored in the fcshdr structure:
% TotalEvents, NumOfPar, name

% If noarg was supplied
if nargin == 0
     [FileName, FilePath] = uigetfile('*.*','Select csv file');
     filename = [FilePath,FileName];
     if FileName == 0
          fcsdat = []; fcshdr = []; fcsdatscaled = [];
          return;
     end
else
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
end
if nargin<3, clip_events = 1e6; end

% If filename arg. only contain PATH, set the default dir to this
% before issuing the uigetfile command. This is an option for the "fca"
% tool
[FilePath, FileNameMain, fext] = fileparts(filename);
FilePath = [FilePath filesep];
FileName = [FileNameMain, fext];
if  isempty(FileNameMain)
    currend_dir = cd;
    cd(FilePath);
    [FileName, FilePath] = uigetfile('*.*','Select CSV file');
     filename = [FilePath,FileName];
     if FileName == 0
          fcsdat = []; fcshdr = [];
          return;
     end
     cd(currend_dir);
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

% Read in header info
fcshdr.fcstype = 'CSV1.0';
fcshdr.filename = FileName;
fcshdr.filepath = FilePath;
% NumOfPar is number of cols
fcshdr.NumOfPar = size(VarNames,2); % should this include image num/ object num cols

% % % Not sure about par, should be channel structs (create leaving everything
% % % but name blank)
% % for i=1:fcshdr.NumOfPar
% %     fcshdr.par(i).name = VarNames{i};
% %     fcshdr.par(i).rawname = fcshdr.par(i).name;
% % end
 
% Read in JSON header info to get fcshdr names
if nargin > 1
    fid = fopen(headername); 
    raw = fread(fid,inf); 
    string = char(raw'); 
    fclose(fid); 
    %header = jsondecode(string);
    header = loadjson(string);
    if header{1} ~= fcshdr.NumOfPar
        TASBESession.error('fca_readcsv', 'NumParameterMismatch', 'Number of cols in CSV does not agree with number from JSON header file.');
    else
        units = {};
        for i=1:fcshdr.NumOfPar
            fcshdr.par(i).name = header{i+1};
            fcshdr.par(i).rawname = fcshdr.par(i).name;
            index = i+1+fcshdr.NumOfPar;
            fcshdr.par(i).pname = header{index};
            fcshdr.par(i).unit = header{index+fcshdr.NumOfPar};
            units{end+1} = fcshdr.par(i).unit;
        end
    end
    
    % Double check units
    allowed_pattern = {'a\.u\.','ERF','Eum','M\w*'};
    num_au = 0;
    fcshdr.non_au = 1;
    for i = 1:numel(units)
        unit = units{i};
        valid_unit = 0;
        for j = 1:numel(allowed_pattern)
            matches = regexp(unit,allowed_pattern{j},'match');
            if(numel(matches)==1 && strcmp(unit,matches{1}))
                valid_unit = 1;
                if j == 1
                    num_au = num_au + 1;
                end
                break
            end
        end
        if valid_unit == 0
            TASBESession.error('fca_readcsv','UnknownUnits','Unit named %s is not a known permitted type',unit);
        end
    end
    % Make sure a.u. units consistent
    if num_au > 0 && num_au ~= numel(units)
        TASBESession.error('fca_readcsv','UnitMismatch','All units need to be a.u.');
    elseif num_au > 0
        fcshdr.non_au = 0;
    end
    
    % Read in filenames
    %filenames = {};
    index = 2 + 3*fcshdr.NumOfPar;
    num_filenames = header{index};
    file_match = 0;
    filename_to_compare = strrep(strrep(filename, '/', ''), '\', '');
    for i=1:num_filenames
        temp_filename = header{i+index};
        temp_filename = strrep(temp_filename, '\', '');
        temp_filename = strrep(temp_filename, '/', '');
        if strcmp(temp_filename, filename_to_compare)
            file_match = 1;
            break
        end
        %filenames{end+1} = temp_filename;
    end
    
    if file_match ~= 1
        TASBESession.warn('fca_readcsv','FilenameMismatch','CSV file might not be documented in inputted JSON header');
    end
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
    fcsdat = double(T.Variables);
end
% display(fcsdat);

% I don't believe we need fcsdatscaled because we don't have any log scales
fcsdatscaled = fcsdat;

end

