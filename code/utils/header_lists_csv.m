function file_match = header_lists_csv(fcshdr,filename)
% file_match = header_lists_csv(header,filename)
%    Check if fcshdr struct contains an equivalent of the specified CSV filename 

% consider both absolute and relative in comparing with filenames
filenames = fcshdr.filename;
hdrfilename = fcshdr.filepath;
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
