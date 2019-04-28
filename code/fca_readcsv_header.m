function [fcshdr, filenames] = fca_readcsv_header(headername)
% fcshdr = fca_readcsv(filename);
%
% Read JSON header file for a set of CSV data files, parsing into an 
% FCS header metadata structure.
% Also returns the set of filenames for which this header file applies

filecheck = dir(headername);
if size(filecheck,1) == 0
    TASBESession.warn('CSV:Read','NoHeaderFile',[headername,': The header file does not exist! Returning empty dataset.']); 
    fcshdr = [];
    return;
end

fcshdr = struct();

fcshdr.fcstype = 'CSV1.0';
 
% Read in JSON header info to get fcshdr names
fid = fopen(headername); 
raw = fread(fid,inf); 
string = char(raw'); 
fclose(fid); 
header = loadjson(string);
channels = header.channels;
fcshdr.NumOfPar = numel(channels);
filenames = header.filenames;
fcshdr.filename = filenames; % also just put the set in here, to be weeded later when used
fcshdr.filepath = header; % store the location of this header, to be used and replaced later

units = cell(fcshdr.NumOfPar,1);
% parse all channels into header parameter ("par") fields
for i=1:fcshdr.NumOfPar
    channel = channels{i};
    channel_fields = fieldnames(channel);
    % ensure all expected channel fields are populated, at least by defaults
    fcshdr.par(i) = fcs_channel();
    % make sure required fields are present in channel
    required_fields = {'name','unit','print_name'};
    for f=1:numel(required_fields)
        if isempty(find(cellfun(@(cf)(strcmp(required_fields{f},cf)),channel_fields), 1))
            TASBESession.error('fca_readcsv', 'MissingRequiredHeaderField', 'Channel %i in %s missing required field %s',i,headername,required_fields{f});
        end
    end
    % copy channel fields, making sure they match target
    target_fields = fieldnames(fcshdr.par(i));
    for f=1:numel(channel_fields)
        % ensure the field is known
        if ~isempty(find(cellfun(@(tf)(strcmp(channel_fields{f},tf)),target_fields), 1))
            fcshdr.par(i).(channel_fields{f}) = channel.(channel_fields{f});
        else
            TASBESession.warn('fca_readcsv', 'UnknownHeaderField', 'Channel %i in %s contains unrecognized field %s',i,headername,channel_fields{f});
        end
    end
    % TODO: consider just using the values in the hdr.par fields?
    units{i} = channel.unit;
end

% Double check units
allowed_pattern = {'a\.u\.','ERF','Eum','M\w*','Boolean'};
calibrated_unit_pattern = {'ERF','Eum','M\w*'};
non_calibrated = 0;
fcshdr.non_au = 1;
for i = 1:numel(units)
    unit = units{i};
    valid_unit = 0;
    for j = 1:numel(allowed_pattern)
        matches = regexp(unit,allowed_pattern{j},'match');
        if(numel(matches)==1 && strcmp(unit,matches{1}))
            valid_unit = 1;
            if isempty(find(cellfun(@(p)(~isempty(regexp(unit,p,'match'))),calibrated_unit_pattern), 1));
                non_calibrated = non_calibrated + 1;
            end
            break
        end
    end
    if valid_unit == 0
        TASBESession.error('fca_readcsv','UnknownUnits','Unit named %s is not a known permitted type',unit);
    end
end
% The file is a non-a.u. file if _any_ element is not a.u.
fcshdr.non_au = (non_calibrated < numel(units));

