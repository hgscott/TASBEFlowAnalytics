% This template shows how to perform a simple batch analysis of a set of conditions
% Each color is analyzed independently
TASBEConfig.checkpoint('init');
% Read in Excel for information, Samples sheet
[num,txt,raw] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Samples', 'A1:O24');

% Read in Excel for information, Experiment sheet
[num2,txt2,raw2] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Experiment', 'A1:T36');

% Read in Excel for information, Cytometer sheet
[num3,txt3,raw3] = xlsread('C:/Users/coverney/Documents/SynBio/Template/batch_template.xlsx', 'Cytometer', 'A1:H22');

plotPath = cell2mat(raw(24,2));
if ~isnan(plotPath)
    TASBEConfig.set('plots.plotPath', char(plotPath));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing plotPath in "Samples" sheet');
end

if ~isnan(cell2mat(raw2(13,10)))
    stem = char(cell2mat(raw2(13,10)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing data directory stem in "Experiment" sheet');
    stem = '';
end
    
% load the color model
if ~isnan(cell2mat(raw(24,3)))
    CM_file = char(cell2mat(raw(24,3)));
else
    %CM = make_color_model_excel();
    CM_file = char(cell2mat(raw3(22,3)));
end
load(CM_file);

% set up metadata
if ~isnan(cell2mat(raw2(4,1)))
    experimentName = char(cell2mat(raw2(4,1)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing experiment name in "Experiment" sheet');
end

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
if isnan(cell2mat(raw(24,9))) | isnan(cell2mat(raw(24,10))) | isnan(cell2mat(raw(24,11)))
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Bin Sequence information in "Samples" sheet');
else
    bins = BinSequence(cell2mat(raw(24,9)),(1/cell2mat(raw(24,10))),cell2mat(raw(24,11)),'log_bins');
end

% Designate which channels have which roles
ref_channels = {'constitutive', 'input', 'output'};
outputs = {};
for i=9:16
    print_name = cell2mat(raw3(i,2));
    if ~isnan(print_name)
        channel_type = char(cell2mat(raw3(i,4)));
        for j=1:numel(ref_channels)
            if strcmpi(ref_channels{j}, channel_type)
                outputs{j} = channel_named(CM, char(print_name));
            end
        end
    else
        break
    end
end

if numel(outputs) == 3
    AP = AnalysisParameters(bins,{'input',outputs{2}; 'output',outputs{3}; 'constitutive',outputs{1}});
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing constitutive, input, output in "Cytometer" sheet');
    AP = AnalysisParameters(bins,{});
end
    
% Ignore any bins with less than valid count as noise
if ~isnan(cell2mat(raw(24,6)))
    AP=setMinValidCount(AP,cell2mat(raw(24,6)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing min valid count in "Samples" sheet');
end

% % Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
% if ~isnan(cell2mat(raw(24,7)))
%     AP=setPemDropThreshold(AP,cell2mat(raw(24,7)));
% else
%     TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing pem drop threshold in "Samples" sheet');
% end

% Add autofluorescence back in after removing for compensation?
if ~isnan(cell2mat(raw(24,7)))
    AP=setUseAutoFluorescence(AP,cell2mat(raw(24,7)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing use auto fluorescence in "Samples" sheet');
end

if ~isnan(cell2mat(raw(24,8)))
    AP=setMinFractionActive(AP,cell2mat(raw(24,8)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing min fraction active in "Samples" sheet');
end

sample_names = {};
file_names = {};
for i=3:size(raw,1)
    if ~isnan(cell2mat(raw(i,1)))
        % is a sample, check if should be included in batch analysis
        if isnan(cell2mat(raw(i,15)))
            sample_names{end+1} = char(cell2mat(raw(i,11)));
            file_names{end+1} = {[stem char(cell2mat(raw(i,12)))]};
        end
    else
        break
    end
end

% Make a map of condition names to file sets
file_pairs = {};
file_pairs(:,1) = sample_names;
file_pairs(:,2) = file_names;

n_conditions = size(file_pairs,1);

% Execute the actual analysis
channel_names = {};
for i=9:16
    print_name = cell2mat(raw3(i,2));
    if ~isnan(print_name)
        channel_names{end+1} = char(print_name);
    else
        break
    end
end

[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,channel_names,AP);

% Make output plots
if ~isnan(cell2mat(raw(24,4)))
    TASBEConfig.set('OutputSettings.StemName',char(cell2mat(raw(24,4))));
else
    TASBESession.warn('make_color_model', 'MissingPreference', 'Missing stem name in "Samples" sheet');
    TASBEConfig.set('OutputSettings.StemName',experimentName);
end

% if ~isnan(cell2mat(raw(24,5)))
%     bounds = strsplit(char(cell2mat(raw(24,5))), ',');
%     TASBEConfig.set('OutputSettings.FixedInputAxis',[str2double(bounds{1}) str2double(bounds{1})]);
% else
%     TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing fixed input axis in "Samples" sheet');
% end

plot_batch_histograms(results,sampleresults,CM);

[statisticsFile, histogramFile] = serializeBatchOutput(file_pairs, CM, AP, sampleresults);

if ~isnan(cell2mat(raw(24,5)))
    save(char(cell2mat(raw(24,5))),'AP','bins','file_pairs','results','sampleresults');
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing output filename in "Samples" sheet');
end
