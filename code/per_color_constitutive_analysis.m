% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function [results, sampleresults] = per_color_constitutive_analysis(colorModel,batch_description,colors,AP)
% The 'results' here is not a standard ExperimentResults, but a similar scratch structure

TASBESession.warn('TASBE:BatchAnalysis','UpdateNeeded','Need to update per_color_constitutive_analysis to use new samplestatistics');
batch_size = size(batch_description,1);

% check to make sure batch_file has the correct dimensions
if size(batch_description, 2) ~= 2
    TASBESession.error('per_color_constitutive_analysis', 'TASBE:DimensionMismatch', 'Batch analysis invoked with incorrect number of columns. Make sure batch_file is a n X 2 matrix.');
end

for i = 1:batch_size
    condition_name = batch_description{i,1};
    fileset = batch_description{i,2};
    
    experiment = Experiment(condition_name,'', {0,fileset});
    data{i} = read_data(colorModel, experiment, AP);
    
    filenames = getInducerLevelsToFiles(experiment); % array of file names
    writeFcsPointCloudCSV(colorModel, filenames, data{i});
end

% first do all the processing
rawresults = cell(size(colors));
for i=1:numel(colors),
    fprintf(['Processing for color ' colors{i} '...\n']);
    AP = setChannelLabels(AP,{'constitutive',channel_named(colorModel,colors{i})});
    rawresults{i} = process_constitutive_batch( colorModel, batch_description, AP, data);
end

n_conditions = size(batch_description,1);
bincenters = get_bin_centers(getBins(AP));

results = cell(n_conditions,1); sampleresults = results;
for i=1:n_conditions,
    replicatecounts = numel(rawresults{1}{i,2});
    samplebincounts = cell(replicatecounts,1);
    sample_gmm_means = samplebincounts; sample_gmm_stds = samplebincounts; sample_gmm_weights = samplebincounts;
    samplemeans = zeros(replicatecounts,numel(colors)); samplestds = samplemeans;
    results{i}.condition = batch_description{i,1};
    results{i}.bincenters = bincenters;
    for j=1:numel(colors),
        ER = rawresults{j}{i,1};
        SR = rawresults{j}{i,2};
        rawbincounts = getBinCounts(ER);
        results{i}.bincounts(:,j) = rawbincounts;
        results{i}.means(j) = geomean(bincenters',rawbincounts);
        results{i}.stds(j) =  geostd(bincenters',rawbincounts);
        [results{i}.gmm_means(:,j), results{i}.gmm_stds(:,j), results{i}.gmm_weights(:,j)] = get_channel_gmm_results(rawresults{j}{i,1},'constitutive');
        % per-sample histograms
        for k=1:replicatecounts,
            samplebincounts{k}(:,j) = SR{k}.BinCounts;
            samplemeans(k,j) = geomean(bincenters',SR{k}.BinCounts);
            samplestds(k,j) = geostd(bincenters',SR{k}.BinCounts);
            color_column = find(colorModel,channel_named(colorModel,colors{j}));
            sample_gmm_means{k}(:,j) = SR{k}.PopComponentMeans(:,color_column);
            sample_gmm_stds{k}(:,j) = SR{k}.PopComponentStandardDevs(:,color_column);
            sample_gmm_weights{k}(:,j) = SR{k}.PopComponentWeights(:,color_column);
        end
        results{i}.stdofmeans(j) = geostd(samplemeans(:,j));
        results{i}.stdofstds(j) = mean(samplestds(:,j));
    end
    for k=1:replicatecounts,
        sampleresults{i}{k} = SampleResults([], batch_description{i,2}{k}, setChannelLabels(AP,colors'), samplebincounts{k}, samplemeans(k,:), samplestds(k,:), ...
            [], [], [], [], [], [], [], [], [], sample_gmm_means{k}, sample_gmm_stds{k}, sample_gmm_weights{k});
    end
end

