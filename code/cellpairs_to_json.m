% Copyright (C) 2011 - 2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE Flow Analytics distribution's top directory.
%
% This file is part of the TASBE Flow Analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the BBN Flow Cytometry
% package distribution's top directory.

% cellpairs is a cell array of {{name, value}, ...}
function string = cellpairs_to_json(cellpairs)
% must be an Nx2 array of cells
assert(size(cellpairs,1)==0 || size(cellpairs,2) == 2);

% for each pair, turn first into property name, second into value
string = sprintf('{\n');
for i=1:size(cellpairs,1)
    % If this isn't the first line, add a comma/newline
    if i>1, string = [string sprintf(',\n');]; end;
    
    % get the next pair to serialize
    name = cellpairs{i,1};
    value = cellpairs{i,2};
    
    % serialize based on type
    if isstruct(value),
        TASBESession.error('TASBE:JSON','Structure','Cellpair JSON serialization requires that structures be pre-flattened.');
    elseif islogical(value) %  boolean
        if value, valstr = 'true'; else valstr = 'false'; end;
    elseif isnumeric(value) % float
        % TODO: add support for multi-dimensional arrays
        if(numel(value)==1),
            valstr = num2json(value);
        else
            valstr = '';
            for j=1:numel(value), valstr = sprintf('%s%s, ',valstr,num2json(value(j))); end;
            valstr = ['[' valstr(1:(end-2)) ']'];
        end
    elseif ischar(value) % string
        valstr = ['"' value '"'];
    else
        error('Don''t know how to serialize value of %s to JSON',name);
    end
    string = [string sprintf('  "%s" : %s',name,valstr)];
end

string = [string sprintf('\n}')];

end

function string = num2json(value)
    if isnan(value), string = '"NaN"'; 
    elseif isinf(value) && value<0, string = '"-Inf"';
    elseif isinf(value), string = '"Inf"';
    else
        string = num2str(value);
    end
end
