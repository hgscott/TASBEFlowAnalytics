% BEADS_TO_ERF_MODEL: Computes a linear function for transforming FACS 
% measurements on the uM channel into uM equivalent diameter, using a 
% calibration run of the size bead model.
% 
% Takes the name of the FACS file of bead measurements, plus optionally the
% name of the channel to be used (if not FSC-A) and a flag for whether to
% record the calibration plot.
%
% Returns:
% * k_uM:  UM = 10.^polyval(ERF_channel_AU,uM_model)
% * first_peak: what is the first peak visible?
% * fit_error: residual from the linear fit
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function [UT, CM] = beads_to_uM_model(CM, beadfile)
uM_channel = CM.uM_channel;
if(isUnprocessed(uM_channel))
    TASBESession.error('TASBE:SizeBeads','uMUnprocessed','Size channel %s cannot be unprocessed',getName(uM_Channel));
end

makePlots = TASBEConfig.get('sizebeads.plot');
visiblePlots = TASBEConfig.get('sizebeads.visiblePlots');
plotPath = TASBEConfig.get('sizebeads.plotPath');
plotSize = TASBEConfig.get('sizebeads.plotSize');
beadModel = TASBEConfig.get('sizebeads.beadModel');
beadChannel = TASBEConfig.get('sizebeads.beadChannel');
beadBatch = TASBEConfig.get('sizebeads.beadBatch');

force_peak = TASBEConfig.getexact('sizebeads.forceFirstPeak',[]);
if ~isempty(force_peak)
    TASBESession.warn('TASBE:SizeBeads','ForcedPeak','Forcing interpretation of first detected size bead peak as peak number %i',force_peak);
end


peak_threshold = TASBEConfig.getexact('sizebeads.peakThreshold',[]);
bin_min = TASBEConfig.get('sizebeads.rangeMin');
bin_max = TASBEConfig.get('sizebeads.rangeMax');
bin_increment = TASBEConfig.get('sizebeads.binIncrement');


uMChannelName=getName(uM_channel);
i_uM = find(CM,uM_channel);

[PeakuMs,units,actualBatch] = get_bead_peaks(beadModel,beadChannel,beadBatch);
CM.sizeUnits = units;

% NOTE: Calculations are done against the QuantifiedPeaks not PeakuMs.
% The value of first_peak is the first valid peak in QuantifiedPeaks not
% PeakuMs.  At the end of function, the peakOffset is added to first_peak
% and is used in calculation of UnitTranslation.

% NOTE: Thus, if reported messages or labels on plots are supposed to be
% based on PeakuMs, then add peakOffset to first_peak and
% numQuantifiedPeaks in messages and labels. Do not add it to num_peaks.
totalNumPeaks = numel(PeakuMs);
numQuantifiedPeaks = sum(~isnan(PeakuMs));
quantifiedPeakERFs = PeakuMs((end-numQuantifiedPeaks+1):end);
peakOffset = totalNumPeaks - numQuantifiedPeaks;

TASBESession.succeed('TASBE:SizeBeads','ObtainBeadPeaks','Found specified size bead model and lot');


% identify peaks
bin_edges = 10.^(bin_min:bin_increment:bin_max);
n = (size(bin_edges,2)-1);
bin_centers = bin_edges(1:n)*10.^(bin_increment/2);

% no secondary channel segmentation here
segmentName = erfChannelName;

[~, fcshdr, fcsdat] = fca_readfcs(beadfile);
bead_data = get_fcs_color(fcsdat,fcshdr,erfChannelName);
segment_data = get_fcs_color(fcsdat,fcshdr,segmentName);

TASBESession.succeed('TASBE:SizeBeads','ObtainBeadData','Successfully read size bead data');

% The full range of bins (for plotting purposes) covers everything from 1 to the max value (rounded up)
range_max = max(bin_max,ceil(log10(max(bead_data(:)))));
range_bin_edges = 10.^(0:bin_increment:range_max);
range_n = (size(range_bin_edges,2)-1);
range_bin_centers = range_bin_edges(1:range_n)*10.^(bin_increment/2);

% All of this should be converted to use bin sequence classes
bin_counts = zeros(size(bin_centers));
for i=1:n
    which = segment_data(:)>bin_edges(i) & segment_data(:)<=bin_edges(i+1);
    bin_counts(i) = sum(which);
end
range_bin_counts = zeros(size(bin_centers));
for i=1:range_n
    which = segment_data(:)>range_bin_edges(i) & segment_data(:)<=range_bin_edges(i+1);
    range_bin_counts(i) = sum(which);
end

n_peaks = 0;
segment_peak_means = []; % segmentation channel (always uM channel)
peak_means = [];
peak_counts = [];
if (isempty(peak_threshold)),
    peak_threshold = 0.2 * max(bin_counts); % number of points to start a peak
elseif numel(peak_threshold)~=1
    TASBESession.error('TASBE:SizeBeads','ThresholdCountMismatch','Bead calibration requires 0 or 1 thresholds');
end

in_peak = 0;
for i=1:n
    if in_peak==0 % outside a peak: look for start
        if(bin_counts(i) >= peak_threshold(i_ERF))
            peak_min = bin_edges(i);
            in_peak=1;
        end
    else % inside a peak: look for end
        if(bin_counts(i) < peak_threshold(i_ERF))
            peak_max = bin_edges(i);
            in_peak=0;
            % compute peak statistics
            n_peaks = n_peaks+1;
            which = segment_data(:)>peak_min & segment_data(:)<=peak_max;
            segment_peak_means(n_peaks) = mean(segment_data(which)); % arithmetic q. beads are primarily measurement noise
            peak_means(n_peaks) = mean(bead_data(which));
            peak_counts(n_peaks) = sum(which);
        end
    end
end
peak_sets{i} = peak_means;

% look for the best linear fit of log10(peak_means) vs. log10(PeakuMs)
if(n_peaks>numQuantifiedPeaks)
    TASBESession.warn('TASBE:SizeBeads','PeakDetection','Size bead calibration found unexpectedly many bead peaks: truncating to use top peaks only');
    n_peaks = numQuantifiedPeaks;
    segment_peak_means = segment_peak_means((end-numQuantifiedPeaks+1):end);
    peak_means = peak_means((end-numQuantifiedPeaks+1):end);
    peak_counts = peak_counts((end-numQuantifiedPeaks+1):end);
else
    TASBESession.succeed('TASBE:SizeBeads','PeakDetection','Size bead calibration found %i bead peaks',n_peaks);
end

% Use log scale for fitting to avoid distortions from highest point
if(n_peaks>=1)
    i = numQuantifiedPeaks-n_peaks; % always assume using top peaks
    [uM_poly,S] = polyfit(log10(peak_means),log10(quantifiedPeakERFs((1:n_peaks)+i)),1);
    fit_error = S.normr;
    first_peak = i+1;
    if ~isempty(force_peak), first_peak = force_peak-peakOffset; end
    
    fprintf('Bead peaks identified as %i to %i of %i\n',first_peak+peakOffset,first_peak+n_peaks-1+peakOffset,numQuantifiedPeaks+peakOffset);
    % Final fit_error should be close to zero / 1-fold
    if(fit_error>1.05), 
        TASBESession.warn('TASBE:SizeBeads','PeakFitQuality','Bead calibration may be incorrect: fit more than 5 percent off: error = %.2d',fit_error); 
    else
        TASBESession.succeed('TASBE:SizeBeads','PeakFitQuality','Bead fit quality acceptable: error = %.2d',fit_error);
    end;
else % n_peaks = 0
    TASBESession.warn('TASBE:SizeBeads','PeakIdentification','Size bead calibration failed: found no bead peaks; using single dummy peak');
    TASBESession.skip('TASBE:SizeBeads','PeakFitQuality','Fit quality irrelevant for single peak');
    uM_poly = [NaN, NaN];
    fit_error = Inf;
    first_peak = NaN;
    CM.standardUnits = 'arbitrary units';
end;

% Plot fitted channel
if makePlots
    graph_max = max(range_bin_counts);
    h = figure('PaperPosition',[1 1 plotSize]);
    if(~visiblePlots), set(h,'visible','off'); end;
    semilogx(range_bin_centers,range_bin_counts,'b-'); hold on;
    % Show identified peaks
    for i=1:n_peaks
        semilogx([segment_peak_means(i) segment_peak_means(i)],[0 graph_max],'r-');
        text(segment_peak_means(i),graph_max,sprintf('%i',i+first_peak-1+peakOffset),'VerticalAlignment','top');
    end
    % show range where peaks were searched for
    plot(10.^[bin_min bin_min],[0 graph_max],'k:');
    text(10.^(bin_min),graph_max/2,'peak search min value','Rotation',90,'FontSize',7,'VerticalAlignment','top','FontAngle','italic');
    plot(10.^[bin_max bin_max],[0 graph_max],'k:');
    text(10.^(bin_max),graph_max/2,'peak search max value','Rotation',90,'FontSize',7,'VerticalAlignment','bottom','FontAngle','italic');
    plot(10.^[0 range_max],[peak_threshold(i_ERF) peak_threshold(i_ERF)],'k:');
    text(1,peak_threshold(i_ERF),'clutter threshold','FontSize',7,'HorizontalAlignment','left','VerticalAlignment','bottom','FontAngle','italic');
    title(sprintf('Peak identification for %s beads', clean_for_latex(beadModel)));
    xlim(10.^[0 range_max]);
    ylabel('Beads');
    xlabel([clean_for_latex(beadChannel) ' a.u.']); 
    outputfig(h,'bead-peak-identification',plotPath);
end


% Plot bead fit curve
if makePlots
    h = figure('PaperPosition',[1 1 plotSize]);
    if(~visiblePlots), set(h,'visible','off'); end;
    loglog(peak_means,quantifiedPeakERFs((1:n_peaks)+first_peak-1),'b*-'); hold on;
    %loglog([1 peak_means],[1 peak_means]*(10.^model(2)),'r+--');
    loglog([1 peak_means],[1 peak_means]*k_ERF,'go--');
    for i=1:n_peaks
        text(peak_means(i),quantifiedPeakERFs(i+first_peak-1)*1.3,sprintf('%i',i+first_peak-1+peakOffset));
    end
    xlabel(clean_for_latex([beadChannel ' a.u.'])); ylabel('Beads ERFs');
    title(sprintf('Peak identification for %s beads', beadModel));
    %legend('Location','NorthWest','Observed','Linear Fit','Constrained Fit');
    legend('Observed','Log-Linear Fit','Location','NorthWest');
    outputfig(h,'bead-fit-curve',plotPath);
end

UT = SizeUnitTranslation([beadModel ':' beadChannel ':' actualBatch],uM_poly, first_peak+peakOffset, fit_error, peak_sets);

end

