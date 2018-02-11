function test_suite = test_beadpeaks
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

%%%%%%%%%%%%
% Note: test_colormodel tests the one and many bead cast; we just need to test a few special cases

function [CM] = setupRedPeakCM()

stem0312 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_';

beadfile = [stem0312 'Beads_P3.fcs'];
blankfile = [stem0312 'blank_P3.fcs'];

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('PE-Tx-Red-YG-A', 561, 610, 20);
channels{1} = setPrintName(channels{1}, 'mKate');
channels{1} = setLineSpec(channels{1}, 'r');
colorfiles{1} = [stem0312 'mkate_P3.fcs'];

% Multi-color controls are used for converting other colors into ERF units
% Any channel without a control mapping it to ERF will be left in arbirary units.
colorpairfiles = {};

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);

CM=set_bead_model(CM,'SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
CM=set_bead_batch(CM,'Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot
CM=set_bead_channel(CM,'PE-TR');

CM=set_ERF_channel_name(CM, 'PE-Tx-Red-YG-A');

TASBEConfig.set('plots.plotPath', '/tmp/plots');


function test_twopeaks

[CM] = setupRedPeakCM();
% Ignore all bead data below 10^[bead_min] as being too "smeared" with noise
CM=set_bead_min(CM, 2.7);
CM=set_bead_peak_threshold(CM, 600);
% Execute and save the model
CM=resolve(CM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,        64.5559,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    7);
assertElementsAlmostEqual(UT.fit_error,     0.00,   'absolute', 0.002);
assertElementsAlmostEqual(UT.peak_sets{1},  [855.4849 2.4685e+03], 'relative', 1e-2);

function test_onepeak

[CM] = setupRedPeakCM();
% Ignore all bead data below 10^[bead_min] as being too "smeared" with noise
CM=set_bead_min(CM, 3.1);
CM=set_bead_peak_threshold(CM, 600);
% Execute and save the model
CM=resolve(CM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,        68.971,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    8);
assertElementsAlmostEqual(UT.fit_error,     0.00,   'absolute', 0.002);
assertElementsAlmostEqual(UT.peak_sets{1},  [2.4685e+03], 'relative', 1e-2);

function test_toomanypeaks

[CM] = setupRedPeakCM();
 % set threshold and min too low so that it should sweep up lots of noise, get too many peaks
CM=set_bead_min(CM, 1);
CM=set_bead_peak_threshold(CM, 300);
% Execute and save the model
CM=resolve(CM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,        11.2510,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    2);
assertElementsAlmostEqual(UT.fit_error,     0.4658,   'absolute', 0.002);
expected_peaks = 1e3 .* [0.0104    0.0114    0.0123    0.0138    0.0175    0.0372    0.1095    0.2280    0.8523 1.3515    2.4685    3.8884];
assertElementsAlmostEqual(UT.peak_sets{1},  expected_peaks, 'absolute', 1);


function test_nopeaks

[CM] = setupRedPeakCM();
CM=set_bead_peak_threshold(CM, 1e7); % set too high to see anything
% Execute and save the model
CM=resolve(CM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,        1);
assertElementsAlmostEqual(UT.first_peak,    NaN);
assertTrue(isinf(UT.fit_error));
assertTrue(isempty(UT.peak_sets{1}));


function [CM] = setupBV421CM()

beadfile = '../TASBEFlowAnalytics-Tutorial/example_controls/171221_E1_p1_AJ02.fcs';
blankfile = [];

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('VL1-A', 405, 440, 50);
channels{1} = setPrintName(channels{1}, 'BV421');
channels{1} = setLineSpec(channels{1}, 'b');
colorfiles{1} = [];

% Multi-color controls are used for converting other colors into ERF units
% Any channel without a control mapping it to ERF will be left in arbirary units.
colorpairfiles = {};

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);

CM=set_bead_model(CM,'SpheroTech URCP-38-2K'); % Entry from BeadCatalog.xls matching your beads
CM=set_bead_batch(CM,'Lot AJ02'); % Entry from BeadCatalog.xls containing your lot
CM=set_bead_channel(CM,'BV421');

CM=set_ERF_channel_name(CM, 'VL1-A');


function test_rightpeaks

[CM] = setupBV421CM();
% Execute and save the model
TASBEConfig.set('plots.plotPath', '/tmp/plots');
TASBEConfig.set('override_autofluorescence',true);
CM=resolve(CM);
TASBEConfig.clear('override_autofluorescence');

% Reset TASBEConfig to not contaminate other tests.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,       0.2966, 'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    2);
assertElementsAlmostEqual(UT.fit_error, 0.0363,   'absolute', 0.002);
expected_peaks = 1e5 .* [0.0100    0.0689    0.2023    0.5471    1.5223];
assertElementsAlmostEqual(UT.peak_sets{1},  expected_peaks, 'relative', 1e-2);


function test_forcepeaks

[CM] = setupRedPeakCM();
% Ignore all bead data below 10^[bead_min] as being too "smeared" with noise
CM=set_bead_min(CM, 2.7);
CM=set_bead_peak_threshold(CM, 600);
% Execute and save the model
TASBEConfig.set('beads.forceFirstPeak',3);
CM=resolve(CM);
TASBEConfig.clear('beads.forceFirstPeak');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,        0.8833,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    3);
assertElementsAlmostEqual(UT.fit_error,     0.00,   'absolute', 0.002);
assertElementsAlmostEqual(UT.peak_sets{1},  [855.4849 2.4685e+03], 'relative', 1e-2);



function [CM] = setupYellowPeakCM()

stem0312 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_';

beadfile = [stem0312 'Beads_P3.fcs'];
blankfile = [stem0312 'blank_P3.fcs'];

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('PE-Tx-Red-YG-A', 561, 610, 20);
channels{1} = setPrintName(channels{1}, 'mKate');
channels{1} = setLineSpec(channels{1}, 'r');
colorfiles{1} = [stem0312 'mkate_P3.fcs'];

channels{2} = Channel('FITC-A', 488, 515, 20);
channels{2} = setPrintName(channels{2}, 'EYFP');
channels{2} = setLineSpec(channels{2}, 'r');
colorfiles{2} = [stem0312 'EYFP_P3.fcs'];

% Multi-color controls are used for converting other colors into ERF units
% Any channel without a control mapping it to ERF will be left in arbirary units.
colorpairfiles = {};

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles);

CM=set_bead_model(CM,'SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
CM=set_bead_batch(CM,'Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot
CM=set_bead_channel(CM,'FITC');
CM=set_ERF_channel_name(CM, 'FITC-A');

TASBEConfig.set('plots.plotPath', '/tmp/plots');

function test_secondarypeaks

[CM] = setupYellowPeakCM();
% Ignore all bead data below 10^[bead_min] as being too "smeared" with noise
CM=set_bead_min(CM, 2.7);
CM=set_bead_peak_threshold(CM, 600);
% Execute and save the model
TASBEConfig.set('beads.secondaryBeadChannel','PE-Tx-Red-YG-A');
CM=resolve(CM);
TASBEConfig.clear('beads.secondaryBeadChannel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
UT = struct(CMS.unit_translation);
assertElementsAlmostEqual(UT.k_ERF,        2.3166e+03,  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    7);
assertElementsAlmostEqual(UT.fit_error,     0.00,   'absolute', 0.002);
assertElementsAlmostEqual(UT.peak_sets{1},  [0.8555e+03    2.4685e+03], 'relative', 1e-2);
assertElementsAlmostEqual(UT.peak_sets{2},  [53.6450  128.2913], 'relative', 1e-2);
