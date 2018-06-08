function test_suite = test_batchAnalysisError
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_batchAnalysisEndtoend

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

% Make a faulty map of condition names to file sets
bad_file_pairs1 = {...
  'Dox 0.1',    {[stem1011 'B3_B03_P3.fcs']}, [stem1011 'B3_B03_P3.fcs']; 
  'Dox 0.2',    {[stem1011 'B4_B04_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 0.5',    {[stem1011 'B5_B05_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 1.0',    {[stem1011 'B6_B06_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 2.0',    {[stem1011 'B7_B07_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 5.0',    {[stem1011 'B8_B08_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 10.0',   {[stem1011 'B9_B09_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 20.0',   {[stem1011 'B10_B10_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 50.0',   {[stem1011 'B11_B11_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 100.0',  {[stem1011 'B12_B12_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 200.0',  {[stem1011 'C1_C01_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 500.0',  {[stem1011 'C2_C02_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 1000.0', {[stem1011 'C3_C03_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  'Dox 2000.0', {[stem1011 'C4_C04_P3.fcs']}, [stem1011 'B3_B03_P3.fcs'];
  };

% Execute the actual analysis to see if an error gets thrown
assertError(@()per_color_constitutive_analysis(CM,bad_file_pairs1,{'EBFP2','EYFP','mKate'},AP), 'per_color_constitutive_analysis:DimensionMismatch', 'No error was raised.');