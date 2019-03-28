function test_suite = test_csv_reading
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_fca_readcsv
    f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
    header = 'LacI-CAGop.json';

    [data, hdr] = fca_read(f1, header);

    PACIFIC_BLUE_CHANNEL = 3;
    NUM_CHANNELS = 3;
    assert(strcmp(hdr.par(PACIFIC_BLUE_CHANNEL).name,'Pacific Blue-A'));
    assert(all(size(data) == [161608 NUM_CHANNELS]));
    assertElementsAlmostEqual(data(1,:),[4.2471e4 4.0352e4 3.7367e4],'absolute',1e0);

function test_cm_read_csv

CM = load_or_make_testing_colormodel();
f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
% kludge to read as a.u. rather than MEFL
header = 'LacI-CAGop-au.json';
TASBEConfig.set('flow.defaultCSVReadHeader',header);

CM = clear_filters(CM); % got to drop the filters because there's no FSC and SSC
data = readfcs_compensated_ERF(CM,f1,false,true);
NUM_CHANNELS = 3;
assert(all(size(data) == [161608 NUM_CHANNELS]));
% numbers should change because all a.u. is treated as uncalibrated
assertElementsAlmostEqual(data(1,:),[9.5741e7 9.0444e7 3.8822e7],'absolute',1e3);


function test_cm_read_mixed_csv

CM = load_or_make_testing_colormodel();
f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
% kludge to read as a mix of a.u. and MEFL rather than all MEFL
header = 'LacI-CAGop-mixed.json';
TASBEConfig.set('flow.defaultCSVReadHeader',header);

CM = clear_filters(CM); % got to drop the filters because there's no FSC and SSC
data = readfcs_compensated_ERF(CM,f1,false,true);
NUM_CHANNELS = 3;
assert(all(size(data) == [161608 NUM_CHANNELS]));
% there is a non-a.u. channel, so it should all be treated as calibrated
assertElementsAlmostEqual(data(1,:),[4.2471e4 4.0352e4 3.7367e4],'absolute',1e0);


function test_cm_read_broken_csv

f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
header = 'LacI-CAGop-broken.json';

assertExceptionThrown(@()fca_read(f1, header), 'fca_readcsv:NumParameterMismatch', 'No error was raised.');


function test_cm_read_broken_csv2

f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
header = 'LacI-CAGop-broken2.json';

assertExceptionThrown(@()fca_read(f1, header), 'fca_readcsv:MissingRequiredHeaderField', 'No error was raised.');
log = TASBESession.list();
assertEqual(log{end}.contents{end-1}.name, 'UnknownHeaderField');


function test_cm_read_broken_csv3

f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
header = 'LacI-CAGop-broken3.json';

fca_read(f1, header);
log = TASBESession.list();
assertEqual(log{end}.contents{end-1}.name, 'UnknownHeaderField');
assertEqual(log{end}.contents{end}.name, 'FilenameMismatch');

