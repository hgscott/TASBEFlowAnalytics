function test_suite = test_fcs_reading
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_fca_readfcs
    f1 = '../TASBEFlowAnalytics-Tutorial/example_controls/07-29-11_blank_P3.fcs';
    f2 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_Beads_P3.fcs';

    [data, hdr] = fca_read(f1);

    PACIFIC_BLUE_CHANNEL = 10;
    NUM_CHANNELS = 13;
    assert(strcmp(hdr.par(PACIFIC_BLUE_CHANNEL).name,'Pacific Blue-A'));
    assert(all(size(data) == [19865 NUM_CHANNELS]));

    [data2, hdr2] = fca_read(f2);
    PACIFIC_BLUE_CHANNEL = 11;
    assert(strcmp(hdr2.par(PACIFIC_BLUE_CHANNEL).name,'Pacific Blue-A'));
    assert(all(size(data2) == [114929 NUM_CHANNELS]));

function test_fcs_scatter
    TASBEConfig.set('plots.plotPath','/tmp');
    f2 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_Beads_P3.fcs';
    [data, h] = fcs_scatter(f2,'FITC-A','Pacific Blue-A',1,[],0);
    assert(all(size(data) == [114929 2]));
    outputfig(h,'fcs_test',TASBEConfig.get('plots.plotPath'));

function test_fcs_too_small

CM = load_or_make_testing_colormodel();

stem1011 = '../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';

% First read without warning
data = readfcs_compensated_ERF(CM,[stem1011 'B4_P3.fcs'],0,1);
log = TASBESession.list();
assertFalse(strcmp(log{end}.contents{end}.name, 'UnusuallySmallFile'));

% now make everything too small and get a warning when reading
TASBEConfig.set('flow.smallFileWarning',1e8);
data = readfcs_compensated_ERF(CM,[stem1011 'B4_P3.fcs'],0,1);
log = TASBESession.list();
assertEqual(log{end}.contents{end}.name, 'UnusuallySmallFile');
