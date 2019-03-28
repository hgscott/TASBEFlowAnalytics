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

function test_cm_read_csv

CM = load_or_make_testing_colormodel();
f1 = '../TASBEFlowAnalytics-Tutorial/template_analysis/csv/LacI-CAGop_Dox01_PointCloud.csv';
% kludge to read as a.u. rather than CSV
header = 'LacI-CAGop-au.json';
TASBEConfig.set('flow.defaultCSVReadHeader',header);

CM = clear_filters(CM); % got to drop the filters because there's no FSC and SSC
data = readfcs_compensated_ERF(CM,f1,false,true);
assert(all(size(data) == [161608 NUM_CHANNELS]));
