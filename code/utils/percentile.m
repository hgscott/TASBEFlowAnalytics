% PERCENTILE returns the data point at a certain percentile.
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function value = percentile(data,n)
sorted = sort(data(~isnan(data))); % sort low to high
if isempty(sorted), value = NaN; return; end; % no numbers in --> NaN out
index = ceil((n/100)*numel(sorted));
value = sorted(index);
