% MAKE_LINEAR COMPENSATION_MODEL: create a color compensation model from 
%   FCS data under the assumption that interference is all linear bleed
%   plus autofluorescence (an assumption that typically holds well):
%      passive = b*driven + autofluorescence
%   returns b and the error in the estimate (expressed as a multiple,
%   since estimation is done on the log scale)
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function [b,b_err] = make_linear_compensation_model(CM, filename, driven, passive)
flowMin = TASBEConfig.get('flow.rangeMin');
flowMax = TASBEConfig.get('flow.rangeMax');
minDrivenThreshold = TASBEConfig.get('compensation.minimumDrivenLevel');
maxDrivenThreshold = TASBEConfig.get('compensation.maximumDrivenLevel');
minimumBinCount = TASBEConfig.get('compensation.minimumBinCount');

% Get read FCS file and select channels of interest
[rawfcs fcshdr] = read_filtered_au(CM,filename);

rawdata = select_channels(CM.Channels,rawfcs,fcshdr);
% Remove autofluorescence from selected channels (ignoring others that may be unprocessed)
no_AF_data = zeros(size(rawdata));
no_AF_data(:,driven) = rawdata(:,driven)-getMean(CM.autofluorescence_model{driven});
no_AF_data(:,passive) = rawdata(:,passive)-getMean(CM.autofluorescence_model{passive});
% make sure nothing's below 1, for compensation and geometric statistics
% (compensation can be badly thrown off by negative values)
no_AF_data(no_AF_data<1) = 1;

% set max from data if max is higher than data
if maxDrivenThreshold>max(max(no_AF_data)), maxDrivenThreshold = ceil(max(max(no_AF_data))); end;

bins = BinSequence(log10(minDrivenThreshold),0.2,log10(maxDrivenThreshold),'log_bins');
[counts means stds] = subpopulation_statistics(bins,no_AF_data,driven,'geometric');

min_significant = find(means(:,passive)>(2*getStd(CM.autofluorescence_model{passive})) & counts(:)>=minimumBinCount,1);

if size(min_significant,1) > 0
    binEdges = get_bin_edges(bins);
    lower_threshold = binEdges(min_significant); % lower edge of first significant bin
    lower_threshold = max(lower_threshold,minDrivenThreshold);
    upper_threshold = min(max(no_AF_data(:,driven))*0.9,maxDrivenThreshold); % back off a little from max
    which = find(no_AF_data(:,driven)>=lower_threshold & no_AF_data(:,driven)<=upper_threshold);
    if(numel(which)),
        b = geomean(no_AF_data(which,passive)./no_AF_data(which,driven));
        b_err = geostd(no_AF_data(which,passive)./no_AF_data(which,driven));
    else
        b = 0; % no significant bleed-over
        b_err = 1; % no significant error
    end
else
    lower_threshold = 1e6;
    b = 0; % no significant bleed-over
    b_err = 1; % no significant error
end
if b>0.1
    TASBESession.warn('TASBE:CompensationModel','HighSpectralBleed','Spectral bleed from %s to %s more than 10%%: %0.3f',getPrintName(CM.Channels{driven}),getPrintName(CM.Channels{passive}),b);
end

% Optional plot
if TASBEConfig.get('compensation.plot')
    figsize = TASBEConfig.get('compensation.plotSize');
    h = figure('PaperPosition',[1 1 figsize]);
    set(h,'visible','off');
    pos = no_AF_data(:,driven)>1 & no_AF_data(:,passive)>1;
    smoothhist2D(log10([no_AF_data(pos,driven) no_AF_data(pos,passive)]),10,[200, 200],[], [],[flowMin flowMin; flowMax flowMax]); hold on;
    which = means(:,driven)>=lower_threshold;
    plot(log10(means(which,driven)),log10(means(which,passive)),'k*-');
    plot(log10(means(which,driven)),log10(means(which,passive).*stds(which,passive)),'k:');
    plot(log10(means(which,driven)),log10(means(which,passive)./stds(which,passive)),'k:');
    plot([0 6],log10(b)+[0 6],'r-');
    cleanedChannelsDriven = clean_for_latex(getPrintName(CM.Channels{driven}));
    cleanedChannelsPassive = clean_for_latex(getPrintName(CM.Channels{passive}));
    xlabel(sprintf('%s (%s a.u.)',cleanedChannelsDriven,clean_for_latex(getName(CM.Channels{driven}))));
    ylabel(sprintf('%s (%s a.u.)',cleanedChannelsPassive,clean_for_latex(getName(CM.Channels{passive}))));
    title('Color Compensation Model');
    path = TASBEConfig.get('compensation.plotPath');
    outputfig(h, sprintf('color-compensation-%s-for-%s',cleanedChannelsPassive,cleanedChannelsDriven), path);
end
