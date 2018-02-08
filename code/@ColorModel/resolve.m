% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed 
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function CM=resolve(CM) % call after construction and configuration

    % fill in channel descriptors from designated file (default = beadfile)
    if TASBEConfig.isSet('channel_template_file'), 
        template = TASBEConfig.get('channel_template_file');
    else template = CM.BeadFile; 
    end;
    [fcsdat fcshdr] = fca_readfcs(template);
    % Remember channel descriptions, for later confirmation
    for i=1:numel(CM.Channels),
        [ignored desc] = get_fcs_color(fcsdat,fcshdr,getName(CM.Channels{i}));
        CM.Channels{i} = setDescription(CM.Channels{i},desc);
        % TODO: figure out how to add FSC and SSC channel descriptions (used by filters) for confirmation
    end
    
    % build model
    % First, unit translation from beads
    if TASBEConfig.isSet('override_units')
        k_ERF = TASBEConfig.get('override_units');
        CM.unit_translation = UnitTranslation('Specified',k_ERF,[],[],{});
        warning('TASBE:ColorModel','Warning: overriding units with specified k_ERF value of %d',k_ERF);
    else
        [UT CM] = beads_to_ERF_model(CM,CM.BeadFile, 2);
        CM.unit_translation = UT;
    end
    
    % Next, autofluorescence and compensation model
    if TASBEConfig.isSet('override_autofluorescence')
        afmean = TASBEConfig.get('override_autofluorescence');
        if numel(afmean)==1, afmean = afmean*ones(numel(CM.Channels),1); end;
        warning('TASBE:ColorModel','Warning: overriding autofluorescence model with specified values.');
        for i=1:numel(afmean),
            CM.autofluorescence_model{i} = AutoFluorescenceModel(afmean(i)*ones(10,1));
            if(CM.Channels{i} == CM.ERF_channel)
                CM.autofluorescence_model{i}=ERFize(CM.autofluorescence_model{i},1,getK_ERF(CM.unit_translation));
            end
        end
    else
        CM.autofluorescence_model = computeAutoFluorescence(CM);
    end
    if TASBEConfig.isSet('override_compensation')
        matrix = TASBEConfig.get('override_compensation');
        warning('TASBE:ColorModel','Warning: overriding compensation model with specified values.');
        CM.compensation_model = LinearCompensationModel(matrix, zeros(size(matrix)));
    else
        CM.compensation_model = computeColorCompensation(CM);
    end
    CM.initialized = 0.5; % enough to read in AU
    if CM.compensation_plot, plot_compensated_controls(CM); end;
    
    % finally, color translation model
    if TASBEConfig.isSet('override_translation')
        scales = TASBEConfig.get('override_translation');
        color_translation_model = ColorTranslationModel(CM.Channels,scales);
        for i=1:numel(CM.Channels),
            if(CM.Channels{i}==CM.ERF_channel) i_ERF = i; end;
        end
        for i=1:numel(CM.Channels),
            if(CM.Channels{i}==CM.ERF_channel) continue; end;
            AFMi = CM.autofluorescence_model{i};
            k_ERF=getK_ERF(CM.unit_translation);
            CM.autofluorescence_model{i}=ERFize(AFMi,scales(i,i_ERF),k_ERF);
        end
        warning('TASBE:ColorModel','Warning: overriding translation scaling with specified values.');
    else
        [color_translation_model CM] = computeColorTranslations(CM);
    end
    CM.color_translation_model = color_translation_model;
    CM.initialized = 1; % enough to read in (pseudo)ERF
    
    %if ~confirm_ERF_translations(CM), return; end;% if can't translate all to ERF, then warn and stop here
    [ok CM] = confirm_ERF_translations(CM);% warn if can't translate all to ERF
    
    CM.noise_model = computeNoiseModel(CM);
    
