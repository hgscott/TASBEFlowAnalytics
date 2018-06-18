% Copyright (C) 2010-2017, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE analytics package distribution's top directory.
%
% This file is part of the TASBE analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the TASBE analytics
% package distribution's top directory.

function [pm_results, pm_sampleresults] = process_plusminus_batch( colorModel, batch_description, analysisParams, batch_names, data)
% batch_description is a cell-array of: {condition_name, inducer_name, plus_level_file_pairs, minus_level_file_pairs}
% pm_results is a cell-array of PlusMinusResults
if nargin < 4
    batch_names = {'+', '-'};
end

batch_size = numel(batch_description);

% check to make sure batch_description has the correct dimensions
category_size = size(batch_description, 1);

for i=1:category_size
    section_size = numel(batch_description{i});
    if section_size ~= numel(batch_names)+2
        TASBESession.error('process_plusminus_batch', 'SetDimensionMismatch', 'Plus Minus analysis invoked with incorrect number of sets. Make sure batch_description is a n X 2 matrix with four sets (last two sets are plus and minus conditions).');
    end
    for j=3:section_size
        if size(batch_description{i}{j}, 2) ~= 2
            TASBESession.error('process_plusminus_batch', 'ColumnDimensionMismatch', 'Plus Minus analysis invoked with incorrect number of columns. Make sure batch_description is a n X 2 matrix.');
        end
    end
end

% verify that all files exist
% Begin by scanning to make sure all expected files are present
fprintf('Confirming files are present...\n');
for i=1:batch_size
    level_file_pairs = [batch_description{i}{3}; batch_description{i}{4}];
    for j=1:size(level_file_pairs,1),
        fileset = level_file_pairs{j,2};
        for k=1:numel(fileset),
            if ~exist(fileset{k},'file'),
                error('Could not find file: %s',fileset{k});
            end
        end
    end
end

pm_results = cell(batch_size,1);
pm_sampleresults = cell(batch_size,2);
for i = 1:batch_size
    condition_name = batch_description{i}{1};
    inducer_name = batch_description{i}{2}; 
    level_file_pairs = {numel(batch_names)};
    experiment_names = {numel(batch_names)};
    experiments = {numel(batch_names)};
    sampleresults = {numel(batch_names)};
    results = {numel(batch_names)};
    % Go through batch_names
    for j = 1:numel(batch_names)
        level_file_pair = batch_description{i}{j+2};
        experiment_name = [condition_name ': ' inducer_name ' ' batch_names{j}];
        experiment = Experiment(experiment_name,{inducer_name}, level_file_pair);
        data{i} = read_data(colorModel, experiment, analysisParams);
        fprintf(['Starting analysis of ' experiment_name '...\n']);
        sampleresult = process_data(colorModel,experiment,analysisParams, data{i});
        result = summarize_data(colorModel,experiment,analysisParams,sampleresult);
        experiment_names{j} = experiment_name;
        experiments{j} = experiment;
        sampleresults{j} = sampleresult;
        results{j} = result;
        level_file_pairs{j} = level_file_pair;
    end
    
    % Comparisons between batches
    fprintf(['Computing comparison for ' condition_name '...\n']);
    comp_results = {numel(results)-1};
    for j = 1:numel(results)-1
        comp_results{j} = compare_plusminus(results{j},results{end}); % compare against last batch
    end
    pm_sampleresults{i} = sampleresults; % array of arrays of sampleresults
    pm_results{i} = comp_results; % array of arrays of comparisons
    % dump bincounts files
    % get/set should be replaced by push/pop of output settings
    stemName = TASBEConfig.getexact('OutputSettings.StemName',[]);
    ERROR = [];
    try
        for j = 1:numel(batch_names)
            TASBEConfig.set('OutputSettings.StemName', [condition_name '-' batch_names{j}]);
            plot_bin_statistics(sampleresults{j});
        end
    catch ERROR
    end
    TASBEConfig.set('OutputSettings.StemName', stemName);
    if ~isempty(ERROR)
        rethrow(ERROR);
    end
end
