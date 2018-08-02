% Copyright (C) 2011 - 2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE Flow Analytics distribution's top directory.
%
% This file is part of the TASBE Flow Analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the BBN Flow Cytometry
% package distribution's top directory.

classdef TASBEConfig
    methods(Static,Hidden)
        function state = init()
            s = struct();
            doc = struct();
            doc.about = 'Configuration variables for TASBE Flow Analytics';
            defaults = containers.Map();
            
            % Testing variables
            s.testing = struct(); doc.testing = struct();
            doc.testing.about = 'Settings to disable features for testing purposes';
            doc.testing.fakeFigureSaves = 'For testing purposes, do not actually save figures, only pretend to.';
            s.testing.fakeFigureSaves = 0;
            
            % Matlab GMdistribution
            
            % Generic flow data analysis
            s.flow = struct(); doc.flow = struct();
            doc.flow.about = 'General settings for flow cytometry data analysis';
            doc.flow.rangeMin = 'bin minimum (log10 scale)';
            s.flow.rangeMin = 0;                           
            doc.flow.rangeMax = 'bin maximum (log10 scale)';
            s.flow.rangeMax = 7;
            doc.flow.outputPointCloud = 'if true, output point-cloud for each calibrated read';
            s.flow.outputPointCloud = false;
            doc.flow.pointCloudPath = 'location for point-cloud outputs';
            s.flow.pointCloudPath = 'CSV/';
            doc.flow.dataCSVPath = 'location for data summary CSVs';
            s.flow.dataCSVPath = 'CSV/';
            doc.flow.outputHistogramFile = 'if true, output histogram file for batch analysis';
            s.flow.outputHistogramFile = true;
            doc.flow.outputStatisticsFile = 'if true, output statistics file for batch analysis';
            s.flow.outputStatisticsFile = true;
            % TASBE Setting migration
            doc.flow.channel_template_file = 'TASBE setting migration';
            s.flow.channel_template_file = '';     

            % generic plots
            s.plots = struct(); doc.plots = struct();
            doc.plots.about = 'General settings for plotting figures';
            doc.plots.plotPath = 'Default location for plots';
            s.plots.plotPath = 'plots/';
            doc.plots.visiblePlots = 'If true, plots are visible; otherwise, they are hidden for later saving';
            s.plots.visiblePlots = false;
            doc.plots.graphPlotSize = 'Default size (in inches) [X Y] for data graph figures';
            s.plots.graphPlotSize = [6 4];
            doc.plots.heatmapPlotSize = 'Default size (in inches) [X Y] for scatter/heatmap figures';
            s.plots.heatmapPlotSize = [5 5];
            doc.plots.largeOutliers = 'If true, outliers in heatmap figures are large, for output in small figures';
            s.plots.largeOutliers = false;
            doc.plots.heatmapPlotType = 'Set to ''image'', ''contour'', or ''surf'' to determine type of heatmap images';
            s.plots.heatmapPlotType = 'image';
            
            % calibration plots, i.e., those supporting the transformation of raw data into processed data, like autofluorescence, compensation, units
            s.calibration = struct(); doc.calibration = struct();
            doc.calibration.about = 'General settings for calibration figures';
            doc.calibration.overrideUnits = 'When set, force a.u. to ERF scaling value to this value';
            s.calibration.overrideUnits = [];
            doc.calibration.overrideAutofluorescence = 'When set, force autofluorescence to use this as mean AF';
            s.calibration.overrideAutofluorescence = [];
            doc.calibration.overrideCompensation = 'When set, use this matrix instead of computing a linear compensation model';
            s.calibration.overrideCompensation = [];
            doc.calibration.overrideTranslation = 'When set, use this matrix instead of computing a color translation model';
            s.calibration.overrideTranslation = [];
            doc.calibration.plot = 'When true, make diagnostic plots while computing color models';
            s.calibration.plot = true;
            doc.calibration.visiblePlots = 'If true, calibration plots are visible; otherwise, they are hidden for later saving';
            s.calibration.visiblePlots = [];
            defaults('calibration.visiblePlots') = 'plots.visiblePlots';
            doc.calibration.plotPath = 'Default location for calibration plots';
            s.calibration.plotPath = []; 
            defaults('calibration.plotPath') = 'plots.plotPath';
            doc.calibration.graphPlotSize = 'Default size (in inches) [X Y] for calibration data graph figures';
            s.calibration.graphPlotSize = [];
            defaults('calibration.graphPlotSize') = 'plots.graphPlotSize';
            doc.calibration.heatmapPlotSize = 'Default size (in inches) [X Y] for calibration scatter/heatmap figures';
            s.calibration.heatmapPlotSize = [];
            defaults('calibration.heatmapPlotSize') = 'plots.heatmapPlotSize';
            
            % Gating
%             s.gating = struct();
%             s.gating.fractionFromExtrema = 0.95;    % Fraction of range considered not-saturated and thus included in gating
%             s.gating.saturationWarning = 0.3;       % Warn about saturation distorting gates if fraction non-extrema less than this level
%             s.gating.numComponents = 2;             % number of gaussian components searched for
%             s.gating.rankedComponents = 1;          % Array of which components will be selected, in order of tightness
%             s.gating.deviations = 2.0;              % number of standard deviations out the gaussian that will be allowed
%             s.gating.tightening = [];               % If set, amount that selected components are further tightened (range: [0,1])
%             s.gating.plot = [];                     % Should a gating plot be created?
%             s.gating.showNonselected = true;        % Should plot show only the selected component(s), or all of them?
%             defaults('gating.plot') = 'calibration.plot';
%             s.gating.visiblePlots = [];             % should gating plot be visible, or just created?
%             defaults('gating.visiblePlots') = 'calibration.visiblePlots';
%             s.gating.plotPath = [];                 % where should gating plot go?
%             defaults('gating.plotPath') = 'calibration.plotPath';
%             s.gating.plotSize = [];                 % What size (in inches) should gating plot be?
%             defaults('gating.plotSize') = 'calibration.heatmapPlotSize';
            
            % Autofluorescence removal
%             s.autofluorescence = struct();
%             s.autofluorescence.dropFractions = 0.025;   % What fraction of the extrema should be dropped before computing autofluorescence?
%             s.autofluorescence.plot = [];               % Should an autofluorescence plot be created?
%             defaults('autofluorescence.plot') = 'calibration.plot';
%             s.autofluorescence.visiblePlots = [];       % should autofluorescence plot be visible, or just created?
%             defaults('autofluorescence.visiblePlots') = 'calibration.visiblePlots';
%             s.autofluorescence.plotPath = [];           % where should autofluorescence plot go?
%             defaults('autofluorescence.plotPath') = 'calibration.plotPath';
%             s.autofluorescence.plotSize = [];           % What size (in inches) should autofluorescence plot be?
%             defaults('autofluorescence.plotSize') = 'calibration.graphPlotSize';
            
            % Spectral bleed compensation
            s.compensation = struct();doc.compensation = struct();
            doc.compensation.about = 'General settings for spectral bleed compensation plots';
            doc.compensation.minimumDrivenLevel = 'Uniformly ignores all less than this level of a.u.';
            s.compensation.minimumDrivenLevel = 1e2;    % uniformly ignore all less than this level of a.u. 
            doc.compensation.maximumDrivenLevel = 'Uniformly ignores all greater than this level of a.u.';
            s.compensation.maximumDrivenLevel = Inf;     % uniformly ignore all greater than this level of a.u. 
            doc.compensation.minimumBinCount = 'Ignores bins with less than this many elements';
            s.compensation.minimumBinCount = 10;        % ignore bins with less than this many elements
            doc.compensation.highBleedWarning = 'Warns about high bleed at this level';
            s.compensation.highBleedWarning = 0.1;      % Warn about high bleed at this level
            doc.compensation.plot = 'Determines whether compensation plots should be created?';
            s.compensation.plot = [];                   % Should compensation plots be created?
            defaults('compensation.plot') = 'calibration.plot';
            doc.compensation.visiblePlots = 'If true, compensation plots are visible; otherwise, they are hidden for later saving';
            s.compensation.visiblePlots = [];           % should compensation plot be visible, or just created?
            defaults('compensation.visiblePlots') = 'calibration.visiblePlots';
            doc.compensation.plotPath = 'Default location for compensation plots';
            s.compensation.plotPath = [];               % where should compensation plot go?
            defaults('compensation.plotPath') = 'calibration.plotPath';
            doc.compensation.plotSize = 'Default size (in inches) [X Y] for compensation figures';
            s.compensation.plotSize = [];               % What size (in inches) should compensation figure be?
            defaults('compensation.plotSize') = 'calibration.heatmapPlotSize';
            
            % Beads
            s.beads = struct(); doc.beads = struct();
            doc.beads.about = 'Settings controlling the interpretation of color calibration beads';
            doc.beads.catalogFileName = 'Location of bead catalog file';
            s.beads.catalogFileName = [fileparts(mfilename('fullpath')) '/../BeadCatalog.xlsx'];
            doc.beads.secondaryBeadChannel = 'For better distingishing low-a.u. ERF peaks: when set, segment ERF-channel peaks using the secondary channel instead of the ERF channel';
            s.beads.secondaryBeadChannel = [];
            doc.beads.peakThreshold = 'Manual minimum threshold for bead peaks; set automatically if empty';
            s.beads.peakThreshold = [];
            doc.beads.rangeMin = 'Minimum value considered for bead peaks (log scale: 10^rangeMin)';
            s.beads.rangeMin = 2;
            doc.beads.rangeMax = 'Maximum value considered for bead peaks (log scale: 10^rangeMax)';
            s.beads.rangeMax = 7;
            doc.beads.binIncrement = 'Resolution of histogram bins used for finding bead peaks';
            s.beads.binIncrement = 0.02;
            doc.beads.beadModel = 'Model of beads that are being used. Should match an option in BeadCatalog.xlsx';
            s.beads.beadModel = 'SpheroTech RCP-30-5A';
            doc.beads.beadChannel = 'Laser/filter channel being used, defaults to FITC (MEFL). Should match an option in BeadCatalog.xlsx';
            s.beads.beadChannel = 'FITC';
            doc.beads.beadBatch = 'Batch of beads that are being used. If set, should match an option in BeadCatalog.xlsx';
            s.beads.beadBatch = [];
            doc.beads.forceFirstPeak = 'If set to N, lowest observed bead peak is forced to be interpreted as Nth peak';
            s.beads.forceFirstPeak = [];
            doc.beads.plot = 'When true, make diagnostic plots while computing bead unit calibration';
            s.beads.plot = [];
            defaults('beads.plot') = 'calibration.plot';
            doc.beads.visiblePlots = 'If true, bead unit calibration plots are visible; otherwise, they are hidden for later saving';
            s.beads.visiblePlots = [];
            defaults('beads.visiblePlots') = 'calibration.visiblePlots';
            doc.beads.plotPath = 'Location for bead unit calibration plots';
            s.beads.plotPath = [];
            defaults('beads.plotPath') = 'calibration.plotPath';
            doc.beads.plotSize = 'Size (in inches) [X Y] for bead unit calibration figures';
            s.beads.plotSize = [5 3.66];
            defaults('beads.plotSize') = 'calibration.graphPlotSize';
            doc.beads.validateAllChannels = 'If true, check all channels for likely bead problems; otherwise, check only ERF channel';
            s.beads.validateAllChannels = false;
            
            % OutputSettings migration
            doc.OutputSettings = struct();
            doc.OutputSettings.about = 'Settings controlling batch plotting';
            s.OutputSettings = struct();
            doc.OutputSettings.StemName = '';
            s.OutputSettings.StemName='';
            doc.OutputSettings.DeviceName = '';
            s.OutputSettings.DeviceName='';
            doc.OutputSettings.Description = '';
            s.OutputSettings.Description='';
            
            doc.OutputSettings.FixedInducerAxis = 'Set to fix limit [min max] of inducer count plot axis';
            s.OutputSettings.FixedInducerAxis = [];      % fixed -> [min max]
            doc.OutputSettings.FixedHistogramAxis = 'Set to fix limit [min max] of histogram count plot axis';
            s.OutputSettings.FixedHistogramAxis = [];
            doc.OutputSettings.FixedBinningAxis = 'Set to fix limit [min max] of binning variable plot axis';
            s.OutputSettings.FixedBinningAxis = [];
            doc.OutputSettings.FixedInputAxis = 'Set to fix limit [min max] of input plot axis';
            s.OutputSettings.FixedInputAxis =   [];
            doc.OutputSettings.FixedNormalizedInputAxis = 'Set to fix limit [min max] of normalized input plot axis';
            s.OutputSettings.FixedNormalizedInputAxis =   [];
            doc.OutputSettings.FixedOutputAxis = 'Set to fix limit [min max] of output plot axis';
            s.OutputSettings.FixedOutputAxis =  [];
            doc.OutputSettings.FixedNormalizedOutputAxis = 'Set to fix limit [min max] of normalized output plot axis';
            s.OutputSettings.FixedNormalizedOutputAxis =  [];
            doc.OutputSettings.FixedRatioAxis = 'Set to fix limit [min max] of ratio plot axis';
            s.OutputSettings.FixedRatioAxis =   [];
            doc.OutputSettings.FixedSNRAxis = 'Set to fix limit [min max] of signal-to-noise ratio plot axis';
            s.OutputSettings.FixedSNRAxis =   [];
            doc.OutputSettings.FixedDeltaSNRAxis = 'Set to fix limit [min max] of delta signal-to-noise ratio plot axis';
            s.OutputSettings.FixedDeltaSNRAxis =   [];
            doc.OutputSettings.ColorPlots = 'If true, color plots created';
            s.OutputSettings.ColorPlots = true;
            doc.OutputSettings.PlotPopulation = 'If true, population plots created';
            s.OutputSettings.PlotPopulation = true;
            doc.OutputSettings.PlotNormalized = 'If true, normalized plots created';
            s.OutputSettings.PlotNormalized = true;
            doc.OutputSettings.PlotNonnormalized = 'If true, nonnormalized plots created';
            s.OutputSettings.PlotNonnormalized = true;
            doc.OutputSettings.PlotEveryN = 'If true, plots every N';
            s.OutputSettings.PlotEveryN = 1;
            doc.OutputSettings.PlotTickMarks = 'If true, displays tick marks';
            s.OutputSettings.PlotTickMarks = false;
            doc.OutputSettings.FigureSize = 'Size (in inches) [X Y] for figures';
            s.OutputSettings.FigureSize = [];
            doc.OutputSettings.csvfile = 'May be either a fid (file identifier) or a string';
            s.OutputSettings.csvfile = []; 
            
            % Plusminus preferences
            s.plusminus = struct(); 
            doc.plusminus = struct();
            doc.plusminus.about = 'Settings controlling plusminus plotting preferences';
            doc.plusminus.plotError = 'If true, plots error envelopes in plusminus comparison graphs';
            s.plusminus.plotError = false;
            
            % Histogram preferences
            s.histogram = struct(); 
            doc.histogram = struct();
            doc.histogram.about = 'Settings controlling histogram plotting preferences';
            doc.histogram.displayLegend = 'If true, displays legend in bin statistics graphs';
            s.histogram.displayLegend = true;
            
            % Excel wrapper preferences
            s.template = struct();
            doc.template = struct();
            doc.template.about = 'Settings controlling excel wrapper preferences';
            doc.template.displayErrors = 'If true, will display ALL of the TASBE warnings and errors from TemplateExtraction';
            s.template.displayErrors = false;
            
            % Color translation
%             s.colortranslation = struct();
%             s.colortranslation.rangeMin = 3;                % bin minimum (log10 scale), universal minimum trim
%             s.colortranslation.rangeMax = 5.5;              % bin maximum (log10 scale)
%             s.colortranslation.binIncrement = 0.1;          % resolution of binning
%             s.colortranslation.minSamples = 100;            % How many samples are needed for a bin's data to be used?
%             s.colortranslation.trimMinimum = {};            % If set, trims individual channels via {{Channel,log10(min)} ...}
%             s.colortranslation.plot = [];                   % Should an autofluorescence plot be created?
%             defaults('colortranslation.plot') = 'calibration.plot';
%             s.colortranslation.visiblePlots = [];           % should autofluorescence plot be visible, or just created?
%             defaults('colortranslation.visiblePlots') = 'calibration.visiblePlots';
%             s.colortranslation.plotPath = [];               % where should autofluorescence plot go?
%             defaults('colortranslation.plotPath') = 'calibration.plotPath';
%             s.colortranslation.plotSize = [];               % What size (in inches) should autofluorescence plot be?
%             defaults('colortranslation.plotSize') = 'calibration.heatmapPlotSize';

            % Last of all, bundle it in a cell array to return
            state = {s defaults doc};
        end
        
        function [out, default, doc] = setget(key,value,force)
            persistent state_stack; % contents: {{checkpoint {settings defaults documentation}}, ...}
            % if empty or reset, initialize
            is_reset = (nargin>0 && strcmp(key,'.reset'));
            if isempty(state_stack) || is_reset
                state_stack = {{'init' TASBEConfig.init()}}; 
                if is_reset, return; end;
            end;
            
            % unpack the current state stack
            settings = state_stack{end}{2}{1};
            defaults = state_stack{end}{2}{2};
            documentation = state_stack{end}{2}{3};
            
            % If there is no arguments, just return the current state for inspection
            if nargin==0, out = settings; default = defaults; doc = documentation; return; end
            % If the key is special, interpret it:
            % if the key is for checkpointing, then push/pop appropriately
            if strcmp(key,'.checkpoint'),
                % truncate to last named checkpoint, if any
                for i=1:numel(state_stack),
                    if(strcmp(state_stack{i}{1},value))
                        state_stack = {state_stack{1:(i-1)}}; % truncate
                        break;
                    end
                end
                % push a copy of the last onto the stack
                if ~isempty(state_stack)
                    state_stack{end+1} = {value state_stack{end}{2}};
                else
                    state_stack = {{'init' TASBEConfig.init()}}; 
                end
                out = state_stack{end}{2}{1};
                return
            end
            if strcmp(key,'.checkpoint_list'),
                out = cell(numel(state_stack),1);
                for i=1:numel(state_stack)
                    out{end-i+1} = state_stack{i}{1};
                end
                return
            end
            
            % Otherwise, go 
            if nargin<3, force = false; end
            
            keyseq = regexp(key, '\.', 'split');
            
            % nested access
            nest = cell(size(keyseq)); docNest = nest; 
            nest{1} = settings; docNest{1} = documentation;
            for i=1:(numel(keyseq)-1)
                if ~ismember(keyseq{i},fieldnames(nest{i})) || ~isstruct(nest{i}.(keyseq{i}))
                    nest{i}.(keyseq{i}) = struct();
                end
                if ~ismember(keyseq{i},fieldnames(docNest{i})) || ~isstruct(docNest{i}.(keyseq{i}))
                    docNest{i}.(keyseq{i}) = struct();
                end
                nest{i+1} = nest{i}.(keyseq{i});
                docNest{i+1} = docNest{i}.(keyseq{i});
            end
            
            if ~isempty(value) || force
                nest{end}.(keyseq{end}) = value;
                % propagate up the chain
                for i=1:(numel(keyseq)-1)
                    nest{end-i}.(keyseq{end-i}) = nest{end-i+1};
                end
                settings = nest{1};
                state_stack{end}{2}{1} = settings; % remember it for next time
            end
            
            % Finally, set outputs
            if ismember(keyseq{end},fieldnames(nest{end}))
                out = nest{end}.(keyseq{end});
            else
                out = [];
            end
            if ismember(keyseq{end},fieldnames(docNest{end}))
                doc = docNest{end}.(keyseq{end});
            else
                doc = 'No documentation available';
            end
            
            if(defaults.isKey(key)), default = defaults(key); else default = 'no default'; end;
        end
    end
    
    methods(Static)
        % Set a value for this key
        function out = set(key,value)
            out = TASBEConfig.setget(key,value);
        end
        
        % Get a value for this key, not following its default chain. If not value is set, try to use the 2nd argument
        function out = getexact(key,default)
            % try a get
            out = TASBEConfig.setget(key,[]);
            if isempty(out)
                % if empty, try to set to default
                if nargin>=2
                    out = TASBEConfig.setget(key,default);
                else
                    error('TASBEConfig', 'NoDefault', 'Requested non-existing setting without default: %s',key);
                end
            end
        end
        
        % Get the first defined value in a sequence of possibilities
        function out = getseq(varargin)
            for i=1:numel(varargin)
                try
                    out = TASBEConfig.get(varargin{i});
                    return
                catch e % ignore error and continue
                end
            end
            error('TASBEConfig', 'NoPreference', 'Couldn''t get any preference in sequence: %s',[varargin{:}]);
        end
        
        % Get a value for this key, possibly via default
        function out = get(key)
            persistent defaults
            if isempty(defaults), [~, defaults] = TASBEConfig.list(); end;
            
            current = key;
            while current
                try
                    out = TASBEConfig.getexact(current);
                    return
                catch e % on miss, try to follow preference path
                    try
                        current = defaults(current);
                    catch e
                        error('TASBEConfig', 'NoPreference', 'Couldn''t get any preference for: %s',key);
                    end
                end
            end
        end
        
        % Check if there is a value set for this key or one of its defaults
        function TF = isSet(key)
            try
                TASBEConfig.get(key);
                TF = true;
            catch % error means not set
                TF = false;
            end
        end
        
        % Remove any value set for key
        function clear(key)
            TASBEConfig.setget(key,[],true);
        end
        
        % Reset the entire TASBEConfig state
        function reset()
            TASBEConfig.setget('.reset');
        end
        
        % Return a list of all of the checkpoint names
        function [top, chain] = checkpoints() 
            chain = TASBEConfig.setget('.checkpoint_list');
            top = chain{1};
        end
        
        % 
        function old = checkpoint(name) 
            old = TASBEConfig.setget('.checkpoint',name);
        end
        
        % Get help on a particular key
        function text = help(key)
            if nargin==0
                [val,def,doc] = TASBEConfig.list();
                key = '';
            else
                [val,def,doc] = TASBEConfig.setget(key,[]);
            end
            
            if(isstruct(val))
                fieldnameset = fieldnames(val);
                keydoc = '';
                maxname = max(cellfun(@numel,fieldnameset));
                for i = 1:numel(fieldnameset),
                    keydoc = [keydoc sprintf('\n  %s',fieldnameset{i})];
                    if(isstruct(val.(fieldnameset{i}))), 
                        keydoc = [keydoc sprintf('\t\t[family]')]; 
                    else
                        try 
                            about = doc.(fieldnameset{i}); 
                            spacer = repmat(' ',1, 4 + maxname - numel(fieldnameset{i}));
                            keydoc = [keydoc sprintf('%s%s',spacer,about)];
                        catch e, 
                            % leave it as was, without documentation
                        end;
                    end;
                end
                try about = doc.about; catch e, about = 'No documentation available'; end;
                text = sprintf('Configuration family: %s\n%s\nKeys: %s',key,about,keydoc);
            else
                text = sprintf('Configuration: %s\n%s\nDefaults to: %s\nCurrent value: %s\n',key,doc,def,val);
            end
        end
        
        % Get a list of all keys
        function [settings, defaults, documentation] = list()
            [settings, defaults, documentation] = TASBEConfig.setget();
        end
        
        % Transform all non-default settings into a JSON object
        function string = to_json()
            string = savejson('',TASBEConfig.list());
        end
        
        function load_from_json(string)
            json_object = loadjson(string);
            TASBEConfig.set_config_from_object('', json_object);
        end
        
        function set_config_from_object(prefix, struct)
            fields = fieldnames(struct);
            for i=1:numel(fields);
                value = struct.(fields{i});
                if(isstruct(value)), % set with substructure
                    TASBEConfig.set_config_from_object([prefix fields{i} '.'], value);
                else % set this value
                    TASBEConfig.set([prefix fields{i}], value);
                end
            end
        end
    end
end
