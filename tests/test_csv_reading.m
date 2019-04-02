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
    
    datafile = DataFile('csv', f1, header);

    [data, hdr] = fca_read(datafile);

    PACIFIC_BLUE_CHANNEL = 3;
    NUM_CHANNELS = 3;
    assert(strcmp(hdr.par(PACIFIC_BLUE_CHANNEL).name,'Pacific Blue-A'));
    assert(all(size(data) == [161608 NUM_CHANNELS]));

