% Copyright (C) 2011 - 2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE Flow Analytics distribution's top directory.
%
% This file is part of the TASBE Flow Analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the BBN Flow Cytometry
% package distribution's top directory.

classdef TASBEConfig
    methods(Static,Hidden)
        function [s, defaults, doc] = init()
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
            s.compensation = struct();
            s.compensation.minimumDrivenLevel = 1e2;    % uniformly ignore all less than this level of a.u. 
            s.compensation.maximumDrivenLevel = Inf;     % uniformly ignore all greater than this level of a.u. 
            s.compensation.minimumBinCount = 10;        % ignore bins with less than this many elements
            s.compensation.highBleedWarning = 0.1;      % Warn about high bleed at this level
            s.compensation.plot = [];                   % Should compensation plots be created?
            defaults('compensation.plot') = 'calibration.plot';
            s.compensation.visiblePlots = [];           % should compensation plot be visible, or just created?
            defaults('compensation.visiblePlots') = 'calibration.visiblePlots';
            s.compensation.plotPath = [];               % where should compensation plot go?
            defaults('compensation.plotPath') = 'calibration.plotPath';
            s.compensation.plotSize = [];               % What size (in inches) should compensation figure be?
            defaults('compensation.plotSize') = 'calibration.heatmapPlotSize';
            
            % Beads
            s.beads = struct(); doc.beads = struct();
            doc.beads.about = 'Settings controlling the interpretation of color calibration beads';
            doc.beads.catalogFileName = 'Location of bead catalog file';
            s.beads.catalogFileName = [fileparts(mfilename('fullpath')) '/../BeadCatalog.xlsx'];
            doc.beads.secondaryBeadChannel = 'For better distingishing low-a.u. ERF peaks: when set, segment ERF-channel peaks using the secondary channel instead of the ERF channel';
            s.beads.secondaryBeadChannel = [];
% TODO: these (and other consolidations) from ColorModel need to wait for config checkpointing            
%            doc.beads.peakThreshold = 'Manual minimum threshold for peaks; set automatically if empty';
%            s.beads.peakThreshold = [];
%             s.beads.rangeMin = 2;                           % bin minimum (log10 scale)
%             s.beads.rangeMax = 7;                           % bin maximum (log10 scale)
%             s.beads.binIncrement = 0.02;                    % resolution of binning
            doc.beads.forceFirstPeak = 'If set to N, lowest observed bead peak is forced to be interpreted as Nth peak';
            s.beads.forceFirstPeak = [];
            doc.beads.plot = 'When true, make diagnostic plots while computing bead unit calibration';
            s.beads.plot = [];
            defaults('beads.plot') = 'calibration.plot';
            doc.beads.visiblePlots = 'If true, bead unit calibration plots are visible; otherwise, they are hidden for later saving';
            s.beads.visiblePlots = [];
            defaults('beads.visiblePlots') = 'calibration.visiblePlots';
            doc.calibration.plotPath = 'Location for bead unit calibration plots';
            s.beads.plotPath = [];
            defaults('beads.plotPath') = 'calibration.plotPath';
            doc.beads.graphPlotSize = 'Size (in inches) [X Y] for bead unit calibration figures';
            s.beads.plotSize = [5 3.66];
            defaults('beads.plotSize') = 'calibration.graphPlotSize';
            
            % TASBE Setting migration
            s.channel_template_file = '';           % An example of this is CM.BeadFile
            % TODO: fix this redundancy of path --> plotPath
            s.path = [];
            defaults('path') = 'plots.plotPath';
            
            % OutputSettings migration
            s.OS = struct();
            s.OS.StemName='';
            s.OS.DeviceName='';
            s.OS.Description='';

            % TODO: fix this redundancy to plotPath and point the OS to appropriate uncommented sub-preferences
            s.OS.Directory=[]; % Default is current directory (might be wrong for windows)
            defaults('OS.Directory') = 'plots.plotPath';
            s.OS.FixedInducerAxis = [];      % fixed -> [min max]
            s.OS.FixedInputAxis =   [];      % fixed -> [min max]
            s.OS.FixedNormalizedInputAxis =   [];      % fixed -> [min max]
            s.OS.FixedOutputAxis =  [];      % fixed -> [min max]
            s.OS.FixedNormalizedOutputAxis =  [];      % fixed -> [min max]
            s.OS.FixedXAxis = [];             % fixed -> [min max]
            s.OS.FixedYAxis = [];             % fixed -> [min max]
            s.OS.ColorPlots = true;
            s.OS.PlotPopulation = true;
            s.OS.PlotNormalized = true;
            s.OS.PlotNonnormalized = true;
            s.OS.PlotEveryN = 1;
            s.OS.PlotTickMarks = false;
            s.OS.FigureSize = [];
            s.OS.csvfile = []; % may be either an fid or a string
            
            
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
        end
        
        function [out, default, doc] = setget(key,value,force)
            persistent settings;
            persistent documentation;
            persistent defaults;
            if isempty(settings), [settings, defaults, documentation] = TASBEConfig.init(); end;
            
            % If there is no arguments, just return the whole thing for inspection
            if nargin==0, out = settings; default = defaults; doc = documentation; return; end
            % if the key is '.reset', then reset
            if strcmp(key,'.reset'), [settings, defaults, documentation] = TASBEConfig.init(); return; end; 
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
        function out = set(key,value)
            out = TASBEConfig.setget(key,value);
        end
        
        function out = getexact(key,default)
            % try a get
            out = TASBEConfig.setget(key,[]);
            if isempty(out)
                % if empty, try to set to default
                if nargin>=2
                    out = TASBEConfig.setget(key,default);
                else
                    error('Requested non-existing setting without default: %s',key);
                end
            end
        end
        
        % Get the first defined in a sequence
        function out = getseq(varargin)
            for i=1:numel(varargin)
                try
                    out = TASBEConfig.get(varargin{i});
                    return
                catch e % ignore error and continue
                end
            end
            error('Couldn''t get any preference in sequence: %s',[varargin{:}]);
        end
        
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
                        error('Couldn''t get any preference for: %s',key);
                    end
                end
            end
        end
        
        function TF = isSet(key)
            try
                TASBEConfig.get(key);
                TF = true;
            catch % error means not set
                TF = false;
            end
        end
        function clear(key)
            TASBEConfig.setget(key,[],true);
        end
        function reset()
            TASBEConfig.setget('.reset');
        end
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
                for i = 1:numel(fieldnameset),
                    keydoc = [keydoc sprintf('\n  %s',fieldnameset{i})];
                    if(isstruct(val.(fieldnameset{i}))), keydoc = [keydoc sprintf('    [family]')]; end;
                end
                try about = doc.about; catch e, about = 'No documentation available'; end;
                text = sprintf('Configuration family: %s\n%s\nKeys: %s',key,about,keydoc);
            else
                text = sprintf('Configuration: %s\n%s\nDefaults to: %s\nCurrent value: %s\n',key,doc,def,val);
            end
        end
        
        function [settings, defaults, documentation] = list()
            [settings, defaults, documentation] = TASBEConfig.setget();
        end
    end
end
