function test_suite = test_sizebeads
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

%%%%%%%%%%%%
% Note: test_colormodel tests the one and many bead cast; we just need to test a few special cases

function [CM] = setupSizePeakCM()

stem0312 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_';

beadfile = [stem0312 'Beads_P3.fcs'];
blankfile = [stem0312 'blank_P3.fcs'];

% Create one channel / colorfile pair for each color
channels = {}; colorfiles = {};
channels{1} = Channel('FITC-A', 488, 515, 20);
channels{1} = setPrintName(channels{1}, 'EYFP'); % Name to print on charts
channels{1} = setLineSpec(channels{1}, 'y'); % Color for lines, when needed
colorfiles{1} = [stem0312 'EYFP_P3.fcs']; % If there is only one channel, the color file is optional

channels{2} = Channel('FSC-A', 488, 488, 10);
channels{2} = setPrintName(channels{2}, 'FSC');
channels{2} = setLineSpec(channels{2}, 'k');

channels{3} = Channel('SSC-A', 488, 488, 0); % should be 10, not 0, but waiting for issue #361 fix
channels{3} = setPrintName(channels{2}, 'SSC');
channels{3} = setLineSpec(channels{2}, 'r');

% Multi-color controls are used for converting other colors into ERF units
% Any channel without a control mapping it to ERF will be left in arbirary units.
colorpairfiles = {};

sizebeadfile = '../TASBEFlowAnalytics-Tutorial/example_controls/180614_PPS6K_A02.fcs';

CM = ColorModel(beadfile, blankfile, channels, colorfiles, colorpairfiles, sizebeadfile);

TASBEConfig.set('beads.beadModel','SpheroTech RCP-30-5A'); % Entry from BeadCatalog.xls matching your beads
TASBEConfig.set('beads.beadBatch','Lot AA01, AA02, AA03, AA04, AB01, AB02, AC01, GAA01-R'); % Entry from BeadCatalog.xls containing your lot

CM=set_ERF_channel_name(CM, 'FITC-A');

% Configuration for size beads, if used
TASBEConfig.set('sizebeads.beadModel','SpheroTech PPS-6K'); % Entry from BeadCatalog.xls matching your beads
% Can also set bead channel or batch, if alternatives are available
% Ignore all size bead data below 10^[rangeMin] as being too "smeared" with noise
TASBEConfig.set('sizebeads.rangeMin', 2);
CM=set_um_channel_name(CM, 'FSC-A');

TASBEConfig.set('plots.plotPath', '/tmp/plots');


function test_sizepeaks
TASBEConfig.checkpoint('test');

CM = setupSizePeakCM();
% Execute and save the model
CM=resolve(CM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check results in CM:
CMS = struct(CM);
assertTrue(strcmp(CMS.sizeUnits,'Eum'));
expected_peaks = 1e5*[0.1257    0.2574    0.6506    1.3908    1.9087    3.1596];
UT = struct(CMS.size_unit_translation);
assertElementsAlmostEqual(UT.um_poly,       [0.5865 -2.0798],  'relative', 1e-2);
assertElementsAlmostEqual(UT.first_peak,    1);
assertElementsAlmostEqual(UT.fit_error,     0.0784,   'absolute', 0.01);
assertElementsAlmostEqual(UT.peak_sets{1},  expected_peaks, 'relative', 1e-2);

channels = getChannels(CM);
assertEqual(getUnits(channels{1}),'MEFL');
assertEqual(getUnits(channels{2}),'Eum');
assertEqual(getUnits(channels{3}),'a.u.');
