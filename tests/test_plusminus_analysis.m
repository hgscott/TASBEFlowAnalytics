function test_suite = test_plusminus_analysis
    enter_test_mode();
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_plusminus_analysis_endtoend

CM = load_or_make_testing_colormodel();

% set up metadata
experimentName = 'LacI Transfer Curve';
device_name = 'LacI-CAGop';
inducer_name = '100xDox';

% Configure the analysis
% Analyze on a histogram of 10^[first] to 10^[third] ERF, with bins every 10^[second]
bins = BinSequence(4,0.1,10,'log_bins');

% Designate which channels have which roles
input = channel_named(CM, 'EBFP2');
output = channel_named(CM, 'EYFP');
constitutive = channel_named(CM, 'mKate');
AP = AnalysisParameters(bins,{'input',input; 'output',output; 'constitutive' constitutive});
% Ignore any bins with less than valid count as noise
AP=setMinValidCount(AP,100');
% Ignore any raw fluorescence values less than this threshold as too contaminated by instrument noise
AP=setPemDropThreshold(AP,5');
% Add autofluorescence back in after removing for compensation?
AP=setUseAutoFluorescence(AP,false');

% Make a map of the batches of plus/minus comparisons to test
% This analysis supports two variables: a +/- variable and a "tuning" variable
stem1011 = '../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';
batch_description = {...
 {'Lows';'BaseDox';{'+', '-'};
  % First set is the matching "plus" conditions
  {0.1,  {DataFile('fcs', [stem1011 'B9_P3.fcs'])}; % Replicates go here, e.g., {[rep1], [rep2], [rep3]}
   0.2,  {DataFile('fcs', [stem1011 'B10_P3.fcs'])}};
  % Second set is the matching "minus" conditions 
  {0.1,  {DataFile([stem1011 'B3_P3.fcs'])};
   0.2,  {DataFile([stem1011 'B4_P3.fcs'])}}};
 {'Highs';'BaseDox';{'+', '-'};
  {10,   {[stem1011 'C3_P3.fcs']};
   20,   {[stem1011 'C4_P3.fcs']}};
  {10,   {[stem1011 'B9_P3.fcs']};
   20,   {[stem1011 'B10_P3.fcs']}}};
 };

% Execute the actual analysis
TASBEConfig.set('OutputSettings.DeviceName',device_name);
TASBEConfig.set('plots.plotPath','/tmp/plots');
results = process_plusminus_batch( CM, batch_description, AP);

% Make additional output plots
for i=1:numel(results)
    TASBEConfig.set('OutputSettings.StemName',batch_description{i}{1});
    TASBEConfig.set('OutputSettings.DeviceName',device_name);
    TASBEConfig.set('OutputSettings.PlotTickMarks',1);
    plot_plusminus_comparison(results{i}, batch_description{i}{3});
end

save('-V7','/tmp/LacI-CAGop-plus-minus.mat','batch_description','AP','results');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in results:

expected_ratios1 = [...
       NaN    1.0086    0.9606    0.9771    0.9354    0.9644    ...
    1.0185    1.0080    0.9745    1.0056    0.9382    1.0183    ...
    0.9451    0.9722    0.9448    0.8899    1.0751    0.9440    ...
    0.9175    0.9634    1.0262    0.9926    0.9646    1.0168    ...
    1.0116    1.0355    0.9952    1.0080    1.0022    0.9941    ...
    0.9754    1.0673    0.9268    1.0025    1.0074    0.8959    ...
    1.0694    0.8552    0.8225       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN;
       NaN    0.9664    0.8940    0.9385    1.0209    0.9813    ...
    1.0078    0.9692    0.9432    0.9649    0.9092    0.9043    ...
    1.0011    1.0162    0.9402    1.0205    0.9296    0.8528    ...
    0.9153    1.0146    0.9160    0.9584    0.9931    0.9313    ...
    0.9573    0.9333    0.9286    0.9523    0.9035    0.9039    ...
    0.8542    0.9128    0.8938    0.7718    0.8671    0.8132    ...
    0.8296    0.8260    0.6837    0.6643       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN]';

expected_InSNR1 = [...
       NaN  -50.4876  -35.5677  -39.6846  -60.2398  -40.4353    ...
  -45.7498  -35.3940  -40.7624  -34.1766  -59.5005  -41.6042    ...
  -43.4850  -36.8905  -36.2304  -40.8816  -58.1243  -49.6369    ...
  -41.7020  -34.3396  -39.2137  -36.2969  -39.8594  -56.6814    ...
  -46.9717  -34.6402  -31.9336  -27.8541  -24.1057  -21.8985    ...
  -21.3048  -18.4210  -17.6606  -16.5609  -15.2061  -13.6520    ...
  -13.6705  -10.8209   -9.8168       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN;
       NaN  -33.5707  -51.4860  -45.2050  -46.0929  -42.2081    ...
  -35.7295  -41.5390  -51.2181  -41.2107  -41.5073  -31.1404    ...
  -45.1269  -36.9786  -40.1149  -55.8444  -33.6293  -43.3774    ...
  -53.6681  -29.8151  -28.8893  -41.4384  -27.7713  -24.3412    ...
  -24.2965  -19.9103  -18.8151  -16.3105  -13.9907  -13.4825    ...
  -12.5224  -11.3929   -9.5539   -9.2309   -8.7707   -8.5042    ...
   -8.1709   -8.7221   -4.9384   -5.0238       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN]';

expected_OutSNR1 = [...
       NaN  -51.5298  -38.3145  -43.4382  -34.0322  -39.4484    ...
  -45.3694  -52.6413  -42.4398  -56.0358  -35.0818  -46.4625    ...
  -37.3607  -43.7595  -37.7257  -31.5290  -35.7296  -37.6141    ...
  -34.1023  -40.9637  -43.9824  -54.2742  -40.2003  -45.8642    ...
  -48.7043  -38.0288  -54.3283  -49.2814  -59.6581  -50.9615    ...
  -37.8502  -29.0910  -27.9903  -57.9441  -48.2983  -24.9977    ...
  -29.5669  -22.6795  -21.4766       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN;
       NaN  -39.2975  -29.5771  -34.4862  -44.2632  -45.0543    ...
  -52.7365  -40.7116  -35.3894  -39.8367  -31.6605  -31.6725    ...
  -71.9792  -48.6811  -37.0106  -46.7376  -35.7282  -28.9247    ...
  -33.8540  -49.3235  -33.6035  -39.1766  -54.5511  -33.3914    ...
  -36.7538  -32.1892  -31.0335  -33.6606  -26.9353  -26.2829    ...
  -21.5899  -26.4749  -24.7117  -17.7002  -22.7739  -20.2524    ...
  -21.0083  -20.7342  -15.6818  -15.3731       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN]';

expected_ratios2 = [...
       NaN    0.8515    0.9436    0.9039    0.8732    0.8401    0.8830    0.8175    0.7666    0.7003    ...
    0.7233    0.5937    0.6280    0.5979    0.6195    0.6211    0.4905    0.4894    0.4615    0.3566    ...
    0.3546    0.3169    0.2954    0.2417    0.2115    0.1937    0.1664    0.1710    0.1462    0.1269    ...
    0.1049    0.0955    0.0988    0.0733    0.0762    0.0807    0.0631    0.0567    0.0469       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN;
       NaN    0.9924    0.8857    0.9436    0.8938    0.8439    0.8657    0.7836    0.7623    0.7237    ...
    0.6622    0.6388    0.5512    0.5837    0.6193    0.4723    0.4938    0.4422    0.3841    0.3327    ...
    0.3230    0.2664    0.2201    0.2117    0.1613    0.1558    0.1474    0.1194    0.1076    0.0936    ...
    0.0850    0.0762    0.0660    0.0641    0.0552    0.0520    0.0498    0.0394    0.0328    0.0300    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN]';

expected_InSNR2 = [...
       NaN  -26.2867  -21.8448  -17.9864  -20.8516  -19.0734  -18.3335  -17.5163  -17.4387  -15.1872    ...
  -12.8411  -10.4584   -7.7761   -8.0683   -7.0743   -6.2092   -5.2542   -4.4733   -3.4007   -2.2669    ...
   -1.1466    0.1529    0.6244    1.7463    2.5537    2.8679    3.4742    3.9855    4.1103    4.1814    ...
    4.5746    4.6932    4.1880    4.1644    3.9865    3.4480    3.4781    3.3437    2.7666       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN;
       NaN  -16.9708  -18.0594  -15.7344  -16.8694  -16.8607  -16.6613  -16.0137  -14.9443  -12.9653    ...
  -11.5909   -8.0905   -7.0605   -6.0781   -5.3351   -5.1998   -3.9302   -2.6338   -1.5806   -0.9217    ...
   -0.0713    1.2294    1.8748    2.2483    2.9876    3.2888    3.6028    3.4828    3.5926    3.5822    ...
    3.4890    3.2987    3.1824    2.9410    2.3671    2.2929    1.8390    2.4193    0.7461    0.6434    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN]';

expected_OutSNR2 = [...
       NaN  -25.7988  -35.1381  -30.5310  -27.7514  -25.6300  -28.6421  -24.5755  -22.1651  -19.9213    ...
  -20.8423  -17.0665  -18.7885  -18.2879  -18.9455  -19.0333  -15.6426  -15.5374  -14.9386  -12.2547    ...
  -11.9919  -10.7504   -9.9555   -8.0221   -6.9940   -6.0030   -4.9270   -4.5762   -3.6708   -2.9414    ...
   -2.0771   -1.5017   -1.7750   -1.2747   -1.1792   -2.0762   -1.4888   -0.9332   -1.0486       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN;
       NaN  -52.3255  -28.4970  -35.1367  -29.5957  -25.9082  -27.3607  -22.7542  -22.0238  -20.5665    ...
  -18.7798  -18.5022  -16.5700  -17.7626  -18.8904  -15.0606  -15.6683  -14.4813  -13.0611  -11.6190    ...
  -11.3301   -9.5345   -8.0891   -7.4733   -5.6032   -5.0626   -4.4712   -3.1378   -2.6121   -2.0064    ...
   -1.1426   -1.0365   -0.6120   -0.8491   -0.5000   -0.6560   -0.5601   -0.4992   -0.6355   -1.0099    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN    ...
       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN       NaN]';


assertEqual(numel(results),2);
assertElementsAlmostEqual(results{1}{1}.MeanRatio, [0.9761; 0.8910],   'relative', 0.01);
assertElementsAlmostEqual(results{1}{1}.Ratios, expected_ratios1,      'relative', 0.01);
assertElementsAlmostEqual(results{1}{1}.InputSNR, expected_InSNR1,     'relative', 0.1);
assertElementsAlmostEqual(results{1}{1}.OutputSNR, expected_OutSNR1,   'relative', 0.1);

assertElementsAlmostEqual(results{2}{1}.MeanRatio, [0.2384; 0.1793],   'relative', 0.01);
assertElementsAlmostEqual(results{2}{1}.Ratios, expected_ratios2,      'relative', 0.01);
assertElementsAlmostEqual(results{2}{1}.InputSNR, expected_InSNR2,     'relative', 0.1);
assertElementsAlmostEqual(results{2}{1}.OutputSNR, expected_OutSNR2,   'relative', 0.1);

