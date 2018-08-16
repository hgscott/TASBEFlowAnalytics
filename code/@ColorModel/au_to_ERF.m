% AU_TO_ERF translates arbitrary units of a particular channel in a ColorModel object to ERF
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function data = au_to_ERF(CM,channel,audata)
    % don't attempt to translate for unprocessed channels
    if(isUnprocessed(channel)), data = audata; return; end
    
    ERF_channel_AU_data = translate(CM.color_translation_model,audata,channel,CM.ERF_channel);
    % Translate ERF channel AU to ERFs
    k_ERF= getK_ERF(CM.unit_translation);
    data = ERF_channel_AU_data*k_ERF;
