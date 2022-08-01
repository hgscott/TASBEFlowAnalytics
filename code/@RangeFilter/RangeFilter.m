% Constructor of RangeFilter class
% Optional discarding of data outside of a certain range
% Specified as a sequence of 'ChannelA',[minA maxA],'ChannelB',[minB maxB]
% Optional argument 'Blankfile': A datafile for the  blank file be used for
% gating, allows for plotting of selected region of gated channels
% Also, argument 'Mode' can be 'And' (a value is excluded if any channel is outside), or 'Or' (a value is excluded if all are outside
% The default mode is 'And'
%
% Copyright (C) 2010-2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function RF = RangeFilter(varargin)
RF.mode = 'And';
RF.channels = {};
RF.ranges = [];

% Get the filter information from the remaining arguments
for i=1:2:numel(varargin)
    arg = varargin{i};
    value = varargin{i+1};
    if ~ischar(arg), TASBESession.error('TASBE:RangeFilter','BadRangeFilterArgument','Range filter argument %i was not a string',i); end;
    
    % Either a datafile, 'Mode' or a channel name
    if strcmp(arg,'Blankfile')
        file = value;
        file = ensureDataFile(file);
        [~, fcshdr, rawfcs] = fca_read(file);
    elseif strcmp(arg,'Mode')
        if ~(strcmp(value,'And') || strcmp(value,'Or')), TASBESession.error('TASBE:RangeFilter','BadRangeFilterMode','Unrecognized range filter mode: %s',value); end;
        RF.mode = value;
    else
        if numel(value)~=2, TASBESession.error('TASBE:RangeFilter','BadRange','Range is not a 2-element vector: %s',num2str(value)); end;
        RF.channels{end+1} = arg;
        RF.ranges(end+1,1:2) = value;
    end
end

RF = class(RF,'RangeFilter',Filter());

%% Obtain data and make plots
makePlots = TASBEConfig.get('gating.plot');

if makePlots
    % Check that a blankfile was passed in, if not throw warning and exit
    if exist('file', 'var') == 0
       TASBESession.warn('TASBE:RangeFilter','BadRangeFilterFile','No argument was specified as Blankfile, cannot make plot.');
       return
    end

    % Pull settings needed for collecting the channel data
    gate_fraction = TASBEConfig.get('gating.fraction');
    channel_names = TASBEConfig.get('gating.channelNames');
    
    n_channels = numel(channel_names);

    % gather channel data
    unfiltered_channel_data = cell(n_channels,1);
    unfiltered_channel_data_arith = unfiltered_channel_data;
    for i=1:n_channels 
        unfiltered_channel_data_arith{i} = get_fcs_color(rawfcs,fcshdr,channel_names{i});
        unfiltered_channel_data{i} = log10(unfiltered_channel_data_arith{i});
    end

    % filter channel data away from saturation points
    which = ones(numel(unfiltered_channel_data{1}),1);
    for i=1:n_channels
        valid = ~isinf(unfiltered_channel_data{i}) & ~isnan(unfiltered_channel_data{i}) & (unfiltered_channel_data_arith{i}>0);
        bound = [min(unfiltered_channel_data{i}(valid)) max(unfiltered_channel_data{i}(valid))];
        span = bound(2)-bound(1);
        range = [mean(bound)-span*gate_fraction/2 mean(bound)+span*gate_fraction/2];
        which = which & valid & unfiltered_channel_data{i}>range(1) & unfiltered_channel_data{i}<range(2);
    end
    channel_data = zeros(sum(which),n_channels);
    for i=1:n_channels 
        channel_data(:,i) = unfiltered_channel_data{i}(which);
    end

    % Pull settings needed for making plots
    visiblePlots = TASBEConfig.get('gating.visiblePlots');
    plotPath = TASBEConfig.get('gating.plotPath');
    plotSize = TASBEConfig.get('gating.plotSize');
    channel_names = TASBEConfig.get('gating.channelNames');
    largeOutliers = TASBEConfig.get('gating.largeOutliers');
    range = TASBEConfig.getexact('gating.range',[]);
    density = TASBEConfig.get('gating.density');

    % Make Plots
    if density >= 1, type = 'image'; else type = 'contour'; end
    
    for i=1:2:n_channels
        % handle odd number of channels by decrementing last:
        if i==n_channels, i=i-1; end

        % Show background
        h = figure('PaperPosition',[1 1 plotSize]);
        if(~visiblePlots), set(h,'visible','off'); end;
        smoothhist2D([channel_data(:,i) channel_data(:,i+1)],5,[500, 500],[],type,range,largeOutliers);
        xlabel([clean_for_latex(channel_names{i}) ' a.u.']); 
        ylabel([clean_for_latex(channel_names{i+1}) ' a.u.']);
        title('Range Filtering Gate');
        hold on;
        
        % Get the bottom left corner and the lengths
        filter_pos = [log10(RF.ranges(i, 1)) log10(RF.ranges(i+1, 1)) log10(RF.ranges(i, 2)/RF.ranges(i, 1)) log10(RF.ranges(i+1, 2)/RF.ranges(i+1, 1))];
        % Plot a rectangle
        rectangle('Position',filter_pos,'EdgeColor','r','LineWidth',2)

        % Save
        outputfig(h,clean_for_latex(sprintf('RangeFilter-%s-vs-%s',channel_names{i},channel_names{i+1})), plotPath);
    end
end
