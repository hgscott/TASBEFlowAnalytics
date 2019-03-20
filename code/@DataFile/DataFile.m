% Constuctor for DataFile class with properties:
% type (0 is fcs, and 1 is csv)
% header
% file
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function DF = DataFile(type, file, header)
    if nargin < 2
        TASBESession.error('TASBE:DataFile','Underspecified','DataFile object can not be created without type and file');
    end
    
    DF.type = type;
    DF.file = file;
    DF.header = '';
    
    if (type == 1) && (nargin < 3)
        TASBESession.error('TASBE:DataFile','Underspecified','DataFile object with csv type needs a header');
    elseif type == 1
        DF.header = header;
    end
    
    % Check to make sure extension of file agrees with type
    [~, ~, fext] = fileparts(file);
    if isempty(fext)
        TASBESession.error('TASBE:DataFile','InvalidExtension','File is not of type csv or fcs');
    elseif (fext ~= '.csv') && (fext ~= '.fcs')
        TASBESession.error('TASBE:DataFile','InvalidExtension','File is not of type csv or fcs');
    elseif (fext == '.csv') && (type ~= 1)
        TASBESession.error('TASBE:DataFile','InvalidExtension','Type does not match with file extension');
    elseif (fext == '.fcs') && (type ~= 0)
        TASBESession.error('TASBE:DataFile','InvalidExtension','Type does not match with file extension');
    end
    
    DF=class(DF,'DataFile');
    
end