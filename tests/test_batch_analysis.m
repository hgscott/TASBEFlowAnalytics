function test_suite = test_batch_analysis
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_batch_analysis_endtoend

CM = load_or_make_testing_colormodel();
stem1011 = '../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';

% set up metadata
experimentName = 'LacI Transfer Curve';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
AP = AnalysisParameters(bins,{});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');

% Make a map of condition names to file sets
file_pairs = {...
  'Dox 0.1',    {[stem1011 'B3_B03_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
  'Dox 0.2',    {[stem1011 'B4_B04_P3.fcs']};
  'Dox 0.5',    {[stem1011 'B5_B05_P3.fcs']};
  'Dox 1.0',    {[stem1011 'B6_B06_P3.fcs']};
  'Dox 2.0',    {[stem1011 'B7_B07_P3.fcs']};
  'Dox 5.0',    {[stem1011 'B8_B08_P3.fcs']};
  'Dox 10.0',   {[stem1011 'B9_B09_P3.fcs']};
  'Dox 20.0',   {[stem1011 'B10_B10_P3.fcs']};
  'Dox 50.0',   {[stem1011 'B11_B11_P3.fcs']};
  'Dox 100.0',  {[stem1011 'B12_B12_P3.fcs']};
  'Dox 200.0',  {[stem1011 'C1_C01_P3.fcs']};
  'Dox 500.0',  {[stem1011 'C2_C02_P3.fcs']};
  'Dox 1000.0', {[stem1011 'C3_C03_P3.fcs']};
  'Dox 2000.0', {[stem1011 'C4_C04_P3.fcs']};
  };

n_conditions = size(file_pairs,1);

% Execute the actual analysis
[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'EBFP2','EYFP','mKate'},AP);

% Make output plots
TASBEConfig.set('OutputSettings.StemName','LacI-CAGop');
TASBEConfig.set('plots.plotPath','/tmp/plots');
TASBEConfig.set('OutputSettings.FixedInputAxis',[1e4 1e10]);
plot_batch_histograms(results,sampleresults,CM,{'b','g','r'});

save('/tmp/LacI-CAGop-batch.mat','AP','bins','file_pairs','results','sampleresults');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in results:

result1_expected_bincounts = [...
        6806        2178        1373;
        8017        2753        2706;
        8782        3323        2637;
        8558        4640        2623;
        7617        4624        3739;
        6343        5595        4714;
        3931        5937        5304;
        1817        6282        5434;
         511        5747        5801;
         124        4272        4683;
           0        3097        4012;
           0        2284        3469;
           0        2340        2917;
           0        2545        3200;
           0        2845        3612;
           0        3390        3985;
           0        3755        4034;
           0        4031        3985;
           0        4246        4135;
           0        4436        4179;
           0        4502        4199;
           0        4289        4095;
           0        4007        3890;
           0        3630        3817;
           0        3244        3685;
           0        2738        3509;
           0        2203        3248;
           0        1731        3032;
           0        1406        2598;
           0         989        2401;
           0         769        1920;
           0         493        1626;
           0         391        1353;
           0         214         995;
           0         150         808;
           0         101         634;
           0           0         428;
           0           0         272;
           0           0         176;
           0           0         122;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           0           0           0;
           ];
       
result_expected_means = 1e5 * [...
    0.2213      2.4796      4.0832
    0.2217      2.4605      4.0592
    0.2201      2.5462      4.2334
    0.2192      2.5524      4.2831
    0.2202      2.4833      4.2658
    0.2230      2.4613      4.2593
    0.2246      2.5221      4.2116
    0.2488      2.5455      4.3739
    0.3723      2.3947      4.5774
    0.4764      2.2973      4.6921
    0.6808      2.0812      4.6243
    1.0768      1.7335      5.6471
    1.5798      1.5283      6.6706
    1.9350      1.4045      7.4507
    ];

result_expected_stds = [...
    1.5964      6.7127      8.0237
    1.5955      6.7718      8.0481
    1.5855      6.7734      8.0462
    1.5881      6.8054      8.0832
    1.5876      6.6713      7.9815
    1.6027      6.7166      8.1935
    1.6348      6.6764      7.9794
    1.8831      6.6863      8.2016
    2.9448      6.3741      8.2915
    3.5238      6.0771      8.3279
    4.3923      5.7805      8.1472
    5.1748      5.2045      8.6548
    5.5516      4.6337      8.5021
    5.5331      4.3324      8.3937
    ];

% Blue, Yellow, Red
result_expected1_gmm_means = [...
    4.2543    4.6200    4.6817
    4.2543    5.9921    6.0832
    ];
result_expected1_gmm_stds = [...
    0.0692    0.0783    0.0900
    0.0692    0.3112    0.5154
    ];
result_expected1_gmm_weights = [...
    0.5000    0.4195    0.3215
    0.5000    0.5805    0.6785
    ];

result_expected14_gmm_means = [...
    4.3427    4.6252    4.7382
    5.6856    5.5610    6.2619
    ];
result_expected14_gmm_stds = [...
    0.0904    0.0804    0.1034
    0.2825    0.2650    0.5099
    ];
result_expected14_gmm_weights = [...
    0.3486    0.4211    0.2456
    0.6514    0.5789    0.7544
    ];
    
assertEqual(numel(results), 14);

% spot-check name, bincenter, bin-count
assertEqual(results{1}.condition, 'Dox 0.1');
assertElementsAlmostEqual(log10(results{1}.bincenters([1 10 40 end])), [4.0500    4.9500    7.9500    9.9500], 'relative', 1e-2);
assertElementsAlmostEqual(results{1}.bincounts, result1_expected_bincounts,     'relative', 1e-2);

assertEqual(results{14}.condition, 'Dox 2000.0');
assertElementsAlmostEqual(log10(results{14}.bincenters([1 10 40 end])), [4.0500    4.9500    7.9500    9.9500], 'relative', 1e-2);

for i=1:14,
    assertElementsAlmostEqual(results{i}.means, result_expected_means(i,:), 'relative', 1e-2);
    assertElementsAlmostEqual(results{i}.stds,  result_expected_stds(i,:),  'relative', 1e-2);
end

assertElementsAlmostEqual(results{1}.gmm_means,  result_expected1_gmm_means,  'relative', 1e-2);
assertElementsAlmostEqual(results{1}.gmm_stds,  result_expected1_gmm_stds,  'relative', 1e-2);
assertElementsAlmostEqual(results{1}.gmm_weights,  result_expected1_gmm_weights,  'relative', 1e-2);
assertElementsAlmostEqual(results{14}.gmm_means,  result_expected14_gmm_means,  'relative', 1e-2);
assertElementsAlmostEqual(results{14}.gmm_stds,  result_expected14_gmm_stds,  'relative', 1e-2);
assertElementsAlmostEqual(results{14}.gmm_weights,  result_expected14_gmm_weights,  'relative', 1e-2);

function test_batch_analysis_plot_warnings
% Test for warnings in plot_batch_histograms
CM2 = load_or_make_testing_colormodel2();
stem1011 = '../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';

% set up metadata
experimentName = 'LacI Transfer Curve';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
AP = AnalysisParameters(bins,{});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');

% Make a map of condition names to file sets
file_pairs = {...
  'Dox 0.1',    {[stem1011 'B3_B03_P3.fcs']}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
  'Dox 0.2',    {[stem1011 'B4_B04_P3.fcs']};
  'Dox 0.5',    {[stem1011 'B5_B05_P3.fcs']};
  'Dox 1.0',    {[stem1011 'B6_B06_P3.fcs']};
  'Dox 2.0',    {[stem1011 'B7_B07_P3.fcs']};
  'Dox 5.0',    {[stem1011 'B8_B08_P3.fcs']};
  'Dox 10.0',   {[stem1011 'B9_B09_P3.fcs']};
  'Dox 20.0',   {[stem1011 'B10_B10_P3.fcs']};
  'Dox 50.0',   {[stem1011 'B11_B11_P3.fcs']};
  'Dox 100.0',  {[stem1011 'B12_B12_P3.fcs']};
  'Dox 200.0',  {[stem1011 'C1_C01_P3.fcs']};
  'Dox 500.0',  {[stem1011 'C2_C02_P3.fcs']};
  'Dox 1000.0', {[stem1011 'C3_C03_P3.fcs']};
  'Dox 2000.0', {[stem1011 'C4_C04_P3.fcs']};
  };

n_conditions = size(file_pairs,1);

% Execute the actual analysis
[results, sampleresults] = per_color_constitutive_analysis(CM2,file_pairs,{'EBFP2','EYFP','mKate'},AP);

% Make output plots
TASBEConfig.set('OutputSettings.StemName','LacI-CAGop');
TASBEConfig.set('plots.plotPath','/tmp/plots');
TASBEConfig.set('OutputSettings.FixedInputAxis',[1e4 1e10]);
plot_batch_histograms(results,sampleresults,CM2);
[~, ~] = serializeBatchOutput(file_pairs, CM, AP, sampleresults); % should not error
log = TASBESession.list();
assertEqual(log{end}.contents{end}.name, 'NoLineSpecs');
assertExceptionThrown(@()plot_batch_histograms(results,sampleresults,CM2,{'b'}), 'plot_batch_histograms:LineSpecDimensionMismatch', 'No error was raised.');

% Execute the actual analysis
[results, sampleresults] = per_color_constitutive_analysis(CM2,file_pairs,{'EYFP','mKate'},AP); % shouldn't error, but should set one color to 'k'
% Make output plots
TASBEConfig.set('OutputSettings.StemName','LacI-CAGop');
TASBEConfig.set('plots.plotPath','/tmp/plots');
TASBEConfig.set('OutputSettings.FixedInputAxis',[1e4 1e10]);
plot_batch_histograms(results,sampleresults,CM2);
log = TASBESession.list();
assertEqual(log{end}.contents{end}.name, 'NoLineSpecs');
[~, ~] = serializeBatchOutput(file_pairs, CM, AP, sampleresults); % should not error
