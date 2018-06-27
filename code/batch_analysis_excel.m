% This template shows how to perform a simple batch analysis of a set of conditions
% Each color is analyzed independently
TASBEConfig.checkpoint('init');
% Read in Excel for information, Samples sheet
[num,txt,raw] = xlsread('C:/Users/coverney/Documents/SynBio/Template/Template1.xlsx', 'Samples', 'A1:O24');

% Read in Excel for information, Experiment sheet
[num2,txt2,raw2] = xlsread('C:/Users/coverney/Documents/SynBio/Template/Template1.xlsx', 'Experiment', 'A1:T36');

% Read in Excel for information, Cytometer sheet
[num3,txt3,raw3] = xlsread('C:/Users/coverney/Documents/SynBio/Template/Template1.xlsx', 'Cytometer', 'A1:H22');
plotPath = cell2mat(raw(24,2));
if ~isnan(plotPath)
    TASBEConfig.set('plots.plotPath', char(plotPath));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing plotPath in "Samples" sheet');
end
% load the color model
CM_file = cell2mat(raw(24,3));
if ~isnan(CM_file)
    load(char(CM_file));
else
    TASBESession.warn('make_color_model', 'MissingPreference', 'Missing CM filename in "Samples" sheet. Will generate Color Model');
    CM = make_color_model_excel(); % Currently does not work because the function is not in the right place
end

% set up metadata
if ~isnan(cell2mat(raw2(4,1)))
    experimentName = char(cell2mat(raw2(4,1)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing experiment name in "Experiment" sheet');
end

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
if isnan(cell2mat(raw(24,11))) | isnan(cell2mat(raw(24,12))) | isnan(cell2mat(raw(24,13)))
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing Bin Sequence information in "Samples" sheet');
else
    bins = BinSequence(cell2mat(raw(24,11)),cell2mat(raw(24,12)),cell2mat(raw(24,13)),'log_bins');
end

% Designate which channels have which roles TODO: COMBINE WITH TEMPLATE
input = channel_named(CM, 'BFP');
output = channel_named(CM, 'GFP');
constitutive = channel_named(CM, 'mRuby');
AP = AnalysisParameters(bins,{'input',input; 'output',output; 'constitutive' constitutive});

% Ignore any bins with less than valid count as noise
if ~isnan(cell2mat(raw(24,7)))
    AP=setMinValidCount(AP,cell2mat(raw(24,7)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing min valid count in "Samples" sheet');
end

% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
if ~isnan(cell2mat(raw(24,8)))
    AP=setPemDropThreshold(AP,cell2mat(raw(24,8)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing pem drop threshold in "Samples" sheet');
end

% Add autofluorescence back in after removing for compensation?
if ~isnan(cell2mat(raw(24,9)))
    AP=setUseAutoFluorescence(AP,cell2mat(raw(24,9)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing use auto fluorescence in "Samples" sheet');
end

if ~isnan(cell2mat(raw(24,10)))
    AP=setMinFractionActive(AP,cell2mat(raw(24,10)));
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing min fraction active in "Samples" sheet');
end

%TODO: ADD CHECKS ON SAMPLE INFORMATION
stem = '../FCS/';
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

% TODO: get list of channels from template
% Execute the actual analysis
[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'GFP','BFP', 'mRuby'},AP);

% Make output plots
if ~isnan(cell2mat(raw(24,4)))
    TASBEConfig.set('OutputSettings.StemName',char(cell2mat(raw(24,4))));
else
    TASBESession.warn('make_color_model', 'MissingPreference', 'Missing stem name in "Samples" sheet');
    TASBEConfig.set('OutputSettings.StemName',experimentName);
end

if ~isnan(cell2mat(raw(24,5)))
    bounds = strsplit(char(cell2mat(raw(24,5))), ',');
    TASBEConfig.set('OutputSettings.FixedInputAxis',[str2double(bounds{1}) str2double(bounds{1})]);
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing fixed input axis in "Samples" sheet');
end


plot_batch_histograms(results,sampleresults,CM);

[statisticsFile, histogramFile] = serializeBatchOutput(file_pairs, CM, AP, sampleresults);

if ~isnan(cell2mat(raw(24,6)))
    save(char(cell2mat(raw(24,6))),'AP','bins','file_pairs','results','sampleresults');
else
    TASBESession.warn('make_color_model', 'ImportantMissingPreference', 'Missing output filename in "Samples" sheet');
end
