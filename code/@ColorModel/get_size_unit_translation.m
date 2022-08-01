% get_size_unit_translation is a getter function for the ColorModel class.
% 
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function y=get_size_unit_translation(CM)
  y = CM.size_unit_translation; % conversion of um channel au to um
