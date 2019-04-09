% AutoFluorescenceModel constructs an AutoFluorescenceModel object for its
% channel using statistics from the provided data.
%
% It is assumed that an array is used to associate this with channels
%  af_mean          % linear mean in arbitrary FACS units
%  af_std           % linear std.dev. in arbitrary FACS units
%  af_mean_ERF=NaN  % linear mean in ERF
%  af_std_ERF=NaN   % linear std.dev. in ERF
%  n                % number of points used in this computation
%  channel          % pointer to the channel for which this is a model
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function AFM = AutoFluorescenceModel(channel,data)
    if nargin == 0
        AFM.af_mean = 0;
        AFM.af_std = 0;
        AFM.n = 0;
        AFM.channel = [];
    elseif nargin >= 2
        % to exclude outliers, drop top and bottom fractions of data
        sorted = sort(data);
        dropFraction = TASBEConfig.get('autofluorescence.dropFraction');
        dropsize = ceil(numel(sorted)*dropFraction);
        trimmed = sorted(dropsize:(numel(sorted)-dropsize));
        AFM.af_mean = mean(trimmed);
        AFM.af_std = std(trimmed);
        AFM.n = numel(trimmed);
        AFM.channel = channel;
    else
        TASBESession.error('AutoFluorescence','MissingArgument','Autofluorescence Model constructor requires two arguments');
    end
    AFM.af_mean_ERF = [];
    AFM.af_std_ERF = [];
    AFM=class(AFM,'AutoFluorescenceModel');
       
