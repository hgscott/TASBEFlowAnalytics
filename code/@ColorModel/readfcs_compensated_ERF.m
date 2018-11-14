% READFCS_COMPENSATED_ERF reads in inputted FCS filename by calling the readfcs_compensated_au
% function and converts the outputted data to ERF units
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function data = readfcs_compensated_ERF(CM,filename,with_AF,floor)
    if(CM.initialized<1), TASBESession.error('TASBE:ReadFCS','Unresolved','Cannot read ERF: ColorModel not yet resolved'); end; % ensure initted
    
    % Read to arbitrary units
    audata = readfcs_compensated_au(CM,filename,with_AF,floor);
    
    % Translate each (processed) channel to ERF channel 
    ERF_channel_data = zeros(size(audata));
    for i=1:numel(CM.Channels)
        if(~isUnprocessed(CM.Channels{i}))
            ERF_channel_data(:,i) = translate(CM.color_translation_model,audata(:,i),CM.Channels{i},CM.ERF_channel);
        else
            ERF_channel_data(:,i) = audata(:,i);
        end
    end
    % Translate ERF AU to ERFs
    k_ERF= getK_ERF(CM.unit_translation);
    for i=1:numel(CM.Channels)
        if(~isUnprocessed(CM.Channels{i})) % only for processed channels
            data(:,i) = ERF_channel_data(:,i)*k_ERF;
        else
            data(:,i) = ERF_channel_data(:,i);
        end
    end
    % if possible, translate um channel AU to um
    if ~isempty(CM.size_unit_translation)
        i_um = find(CM, CM.um_channel);
        data(:,i_um) = uM_channel_AU_to_uM(CM.size_unit_translation,data(:,i_um));
    end
    
    % optional discarding of filtered data (e.g., poorly transfected cells)
    for i=1:numel(CM.postfilters)
        data = applyFilter(CM.postfilters{i},CM.Channels,data);
    end
    % make sure we didn't throw away huge amounts...
    if numel(data)<numel(audata)*0.1 % Threshold: at least 10% retained
        TASBESession.warn('TASBE:ReadFCS','TooMuchDataDiscarded','ERF (post)filters may be discarding too much data: only %d%% retained in %s',numel(data)/numel(audata)*100,filename);
    end
