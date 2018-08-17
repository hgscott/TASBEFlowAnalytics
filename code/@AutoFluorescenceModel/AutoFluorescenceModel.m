% AutoFluorescenceModel constructs an AutoFluorescenceModel object
%
% It is assumed that an array is used to associate this with channels
%  af_mean          % linear mean in arbitrary FACS units
%  af_std           % linear std.dev. in arbitrary FACS units
%  af_mean_ERF=NaN % linear mean in ERF
%  af_std_ERF=NaN  % linear std.dev. in ERF
%  n                % number of points used in this computation
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function AFM = AutoFluorescenceModel(data)
    if nargin == 0
        AFM.af_mean = 0;
        AFM.af_std = 0;
        AFM.n = 0;
    elseif nargin == 1
        % to exclude outliers, drop top and bottom 2.5% of data
        sorted = sort(data);
        dropsize = ceil(numel(sorted)*0.025);
        trimmed = sorted(dropsize:(numel(sorted)-dropsize));
        AFM.af_mean = mean(trimmed);
        AFM.af_std = std(trimmed);
        AFM.n = numel(trimmed);
    end
    AFM.af_mean_ERF = [];
    AFM.af_std_ERF = [];
    AFM=class(AFM,'AutoFluorescenceModel');
       
