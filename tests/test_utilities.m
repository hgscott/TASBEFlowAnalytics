function test_suite = test_utilities
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_isolated_points

assertEqual(isolated_points([1 NaN 3 4 5]), logical([1 0 0 0 0]));
assertEqual(isolated_points([NaN NaN 3 4 5]), logical([0 0 0 0 0]));
assertEqual(isolated_points([1 2 3 4 5]), logical([0 0 0 0 0]));
assertEqual(isolated_points([NaN 2 3 NaN 5]), logical([0 0 0 0 1]));
assertEqual(isolated_points([1 2 NaN 4 5]), logical([0 0 0 0 0]));
assertEqual(isolated_points([1 2 NaN NaN 5 6]), logical([0 0 0 0 0 0]));
assertEqual(isolated_points([NaN 2 NaN 4 NaN]), logical([0 1 0 1 0]));
assertEqual(isolated_points([1 NaN 3 -4 5],1), logical([1 0 1 0 1]));
assertEqual(isolated_points([1 Inf 3 -Inf 5]), logical([1 0 1 0 1]));
assertEqual(isolated_points([1 NaN 3 4 5]'), logical([1 0 0 0 0]));


function test_fcs_channel_names

stem1011 = '../TASBEFlowAnalytics-Tutorial/example_assay/LacI-CAGop_';
names = fcs_channel_names([stem1011 'B5_B05_P3.fcs']);

expectedNames = {'FSC-A', 'FSC-H', 'FSC-W', 'SSC-A', 'SSC-H', 'SSC-W',...
    'FITC-A', 'PerCP-Cy5-5-A', 'PE-YG-A', 'PE-Tx-Red-YG-A', ...
    'Pacific Blue-A', 'AmCyan-A', 'Time'};

assertEqual(names,expectedNames);
