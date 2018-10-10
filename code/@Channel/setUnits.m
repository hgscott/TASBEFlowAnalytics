% setUnits is a getter function for the Channel class. (either pseudoERF or
% ERF)
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function C = setUnits(C,name)
    allowed = {'a.u.','ERF','EuM'};
    for i=1:numel(allowed),
        if(strcmp(name,allowed{i}))
            C.Units = name;
            return
        end
    end
    TASBESession.error('TASBE:Channel','UnknownUnits','Unit named %s is not a known permitted type',name);
