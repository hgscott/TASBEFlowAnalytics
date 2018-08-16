% getInducerLevelsToFiles is a getter function for the Experiment class.
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.


function n = getInducerLevelsToFiles(E,i)
   if (nargin==2)
    n = [E.InducerLevelsToFiles{:,i}];
   else
       n = E.InducerLevelsToFiles(:,end);
   end
