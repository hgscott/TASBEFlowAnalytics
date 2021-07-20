function test_suite = test_small_fcs_files
    enter_test_mode();
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_small_fcs

% two micro-files, one with 0 events, one with 2 events
fcs0events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1endun9epg7tm.fcs';
fcs1events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1endun9efp22g.fcs';
fcs2events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1enduncr9sukn.fcs';
fcs79events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1endunfwb9kmg.fcs';

blankfile = fcs0events;

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('BL1-A', 488, 515, 20);
channels{1} = setPrintName(channels{1}, 'GFP'); % Name to print on charts
channels{1} = setLineSpec(channels{1}, 'g'); % Color for lines, when needed
colorfiles{1} = fcs79events;

CM = ColorModel([], blankfile, channels, colorfiles, {});

CM=set_ERF_channel_name(CM, 'BL1-A');
TASBEConfig.set('flow.channel_template_file',blankfile);
TASBEConfig.set('calibration.overrideUnits',1);

% Execute and save the model
CM=resolve(CM);

% Configure the analysis
bins = BinSequence(0,0.1,10,'log_bins');
AP = AnalysisParameters(bins,{});

% Make a map of condition names to file sets
file_pairs = {...
    'small1', {fcs0events, fcs1events, fcs79events, fcs2events};
    'small2', {fcs79events, fcs2events};
  };

[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'GFP'},AP);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results:

assertEqual(numel(results), 2);
assertElementsAlmostEqual(results{1}.n_events, [1 1 79 2],1e-2);
assertElementsAlmostEqual(results{2}.n_events, [79 2],1e-2);



function test_small_fcs_filtered

% two micro-files, one with 0 events, one with 2 events
fcs0events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1endun9epg7tm.fcs';
fcs1events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1endun9efp22g.fcs';
fcs2events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1enduncr9sukn.fcs';
fcs79events = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/aq1endunfwb9kmg.fcs';

blankfile = fcs0events;

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('BL1-A', 488, 515, 20);
channels{1} = setPrintName(channels{1}, 'GFP'); % Name to print on charts
channels{1} = setLineSpec(channels{1}, 'g'); % Color for lines, when needed
colorfiles{1} = fcs79events;

CM = ColorModel([], blankfile, channels, colorfiles, {});

CM=set_ERF_channel_name(CM, 'BL1-A');
TASBEConfig.set('flow.channel_template_file',blankfile);
TASBEConfig.set('calibration.overrideUnits',1);

% Execute and save the model
RF = RangeFilter('BL1-A',[20 21]);
CM=resolve(CM);

CM = add_prefilter(CM,RF);

% Configure the analysis
bins = BinSequence(0,0.1,10,'log_bins');
AP = AnalysisParameters(bins,{});

AP=setMinValidCount(AP,1');

% Make a map of condition names to file sets
file_pairs = {...
    'small1', {fcs0events, fcs1events, fcs2events};
    'small2', {fcs79events, fcs2events};
  };

[results, sampleresults] = per_color_constitutive_analysis(CM,file_pairs,{'GFP'},AP);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results:

assertEqual(numel(results), 2);
assertElementsAlmostEqual(results{1}.n_events, [0 0 0],1e-2);
assertElementsAlmostEqual(results{2}.n_events, [2 0],1e-2);


function test_complex_small_files_premade_colormodel

% Color model = 'cm'
load('../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/ColorModel.mat');

% Configure the analysis
bins = BinSequence(0,0.1,10,'log_bins');
AP = AnalysisParameters(bins,{});

AP=setMinValidCount(AP,1');

% Make a map of condition names to file sets
stem = '../TASBEFlowAnalytics-Tutorial/tests/additional_test_files/';
file_pairs = {...
    'A', {[stem 'aq1endun4pam9wj.fcs'], [stem 'aq1endun4pbrg2h.fcs'], [stem 'aq1endun4p9g3sk.fcs']}; 
    'B', {[stem 'aq1endun4pcvp6p.fcs'], [stem 'aq1endun4pf63em.fcs'], [stem 'aq1endun4pf63eq.fcs']}; 
    'B2', {[stem 'aq1endun4pcvp6p.fcs'], [stem 'aq1endun4pf63eq.fcs'], [stem 'aq1endun4pf63eq.fcs']}; 
    'C', {[stem 'aq1endun4p77phf.fcs']};
    'D', {[stem 'aq1endun4pjjntq.fcs']};
    'E', {[stem 'aq1endunfvwse75.fcs']};
    'F', {[stem 'aq1endun4p3t45d.fcs'], [stem 'aq1endun4p4xa9e.fcs']}; 
    'G', {[stem 'aq1endun4nw54g9.fcs'], [stem 'aq1endun4nx9am8.fcs']}; 
    'H', {[stem 'aq1endun4nzhpvb.fcs'], [stem 'aq1endun4p3t45a.fcs']}; 
    };

[results, sampleresults] = per_color_constitutive_analysis(cm,file_pairs,{'FSC-A','SSC-A','BL1-A','FSC-H','SSC-H','FSC-W','SSC-W'},AP);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results:

assertEqual(numel(results), 9);
assertElementsAlmostEqual(results{1}.n_events, [0 0 0],1e-2);
assertElementsAlmostEqual(results{2}.n_events, [0 0 25],1e-2);

