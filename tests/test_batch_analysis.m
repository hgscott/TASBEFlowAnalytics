function test_suite = test_batch_analysis
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_batch_analysis_endtoend

load('../TASBEFlowAnalytics-Tutorial/template_colormodel/CM120312.mat');
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
plot_batch_histograms(results,sampleresults,{'b','y','r'},CM);

save('/tmp/LacI-CAGop-batch.mat','AP','bins','file_pairs','results','sampleresults');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in results:

result1_expected_bincounts = [...
        6792        2206        1382;
        8014        2724        2695;
        8765        3321        2634;
        8559        4632        2631;
        7615        4618        3737;
        6321        5588        4704;
        3924        5932        5298;
        1814        6286        5431;
         510        5735        5794;
         124        4266        4746;
           0        3097        4161;
           0        2283        3252;
           0        2339        2923;
           0        2543        3276;
           0        2844        3593;
           0        3388        4010;
           0        3756        4006;
           0        4026        3973;
           0        4245        4138;
           0        4434        4182;
           0        4500        4182;
           0        4286        4097;
           0        4005        3880;
           0        3629        3823;
           0        3242        3681;
           0        2737        3505;
           0        2202        3228;
           0        1728        3040;
           0        1405        2597;
           0         989        2384;
           0         768        1921;
           0         493        1621;
           0         390        1339;
           0         214         989;
           0         150         802;
           0         101         632;
           0           0         420;
           0           0         269;
           0           0         176;
           0           0         121;
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
    0.2213    2.4800    4.0710
    0.2209    2.4616    4.0412
    0.2201    2.5476    4.1967
    0.2192    2.5526    4.2694
    0.2202    2.4836    4.2491
    0.2231    2.4599    4.2389
    0.2245    2.5201    4.1942
    0.2474    2.5473    4.3616
    0.3723    2.3949    4.5641
    0.4764    2.2965    4.6751
    0.6809    2.0817    4.6095
    1.0763    1.7331    5.6210
    1.5787    1.5278    6.6428
    1.9343    1.4047    7.4223
    ];

result_expected_stds = [...
    1.5962    6.7130    8.0132
    1.5880    6.7764    8.0448
    1.5852    6.7717    7.9832
    1.5882    6.8049    8.0720
    1.5874    6.6735    7.9756
    1.6029    6.7155    8.1864
    1.6348    6.6808    7.9787
    1.8582    6.6884    8.1892
    2.9436    6.3747    8.2777
    3.5229    6.0781    8.3190
    4.3920    5.7806    8.1339
    5.1732    5.2044    8.6436
    5.5498    4.6336    8.4909
    5.5327    4.3326    8.3846
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

