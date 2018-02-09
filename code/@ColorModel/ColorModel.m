% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.


% ColorModel is the class that allows
% a) Colors to be mapped to standard units (ERF)
% b) Autofluorescence removal
% c) Spectral overlap compensation
function CM = ColorModel(beadfile, blankfile, channels, colorfiles, pairfiles)
        CM.version = tasbe_version();
        %public settings
        CM.ERF_channel_name = 'FITC-A'; % Which channel are ERFs on?  Default is FITC-A
        CM.ERF_channel=[];
        CM.bead_plot = 1  ;         % Should the bead calibration plot be produced?
        CM.bead_peak_threshold=[];  % If set, determines minimum for bead peaks
        CM.bead_min = 2 ;           % No signal be considered below 10^bead_min
        CM.bead_max = 6 ;           % No signal be considered above 10^bead_max
        CM.bead_model = 'SpheroTech RCP-30-5A';     % Which beads are being used? Should match an option in BeadCatalog.xlsx
        CM.bead_channel = 'FITC';   % Defaults to FITC; should match an option in BeadCatalog.xlsx
        CM.bead_batch = [];         % Empty unless designated; if designated, should match an option in BeadCatalog.xlsx
        CM.autofluorescence_plot = 1; % Should the autofluorescence calibration plots be produced?
        CM.compensation_plot = 1;   % Should the color compenation calibration plots be produced?
        CM.translation_plot = 1 ;   % Should the color translation calibration plots be produced?
        CM.translation_channel_min = [];    % If set, all data below 10.^min(channel_id) is excluded from computation
        CM.translation_channel_min_samples = 100;    % Minimum number of samples in a bin to consider it for translation
        CM.noise_plot = 1 ;         % Should the noise model plots be produced?
        CM.dequantize = 0 ;         % Should small randomness be added to fuzz low bins? 
        
        % other fields
        CM.initialized = 0;        % true after resolution
        
        %%% NOT SURE if we need to initialize these properties
        
        CM.unit_translation=[]  ;      % conversion of ERF channel au to ERF
        CM.autofluorescence_model=[];  % array, one per channel, for removing autofluorescence
        CM.compensation_model=[]     ; % For compensating for spectral overlap
        CM.color_translation_model=[] ;% For converting other channels to ERF channel AU equiv
        CM.noise_model=[]             ;% For understanding the expected constitutive expression noise
        CM.filters={};                 % filters to remove problematic data (e.g. debris, time-contamination)
        CM.standardUnits = 'not yet set';  % Should instead be the value from column E in BeadCatalog.xlsx

        CM.filters{1} = TimeFilter(); % add default quarter second data exclusion
        
        if nargin == 0
            channels{1} = Channel();
            colorfiles{1} = '';
            colorpairfiles{1} = {channels{1}, channels{1}, channels{1}, ''};
            
            CM.BeadFile = '';
            CM.BlankFile = '';
            CM.Channels = channels;
            CM.ColorFiles = colorfiles;
            CM.ColorPairFiles = colorpairfiles;
                
        elseif nargin == 5
            % constructor initialized fields
            % same FPs in the same order
            CM.BeadFile = beadfile;
            CM.BlankFile = blankfile;
            if numel(channels)~=numel(colorfiles)
                if ~(numel(channels) == 1 && isempty(colorfiles)) % can drop colorfile if only one channel
                    error('Must have one-to-one match between colors and channels');
                end
            end
            CM.Channels = channels;
            CM.ColorFiles = colorfiles;
            CM.ColorPairFiles = pairfiles;
        end
        

        % constructs for every data file -- this might need another class
        % that associates the file name with a description 
        CM = class(CM,'ColorModel');
        
