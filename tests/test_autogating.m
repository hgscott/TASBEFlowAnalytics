function test_suite = test_autogating
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_autogate

stem0312 = '../TASBEFlowAnalytics-Tutorial/example_controls/2012-03-12_';
blankfile = [stem0312 'blank_P3.fcs'];

% Autodetect gating with an N-dimensional gaussian-mixture-model
AGP = AutogateParameters();
AGP.channel_names = {'FSC-A','SSC-A'};
gate = GMMGating(blankfile,AGP,'/tmp/plots');

gate = struct(gate);

assertEqual(gate.selected_components, 1);

expected_mu = [5.1117    3.4087;    4.5555    3.3427];
GDS = struct(gate.distribution);
assertElementsAlmostEqual(GDS.mu,expected_mu,'absolute',0.01);

expected_sigma(:,:,1) = [0.0130    0.0149;    0.0149    0.0328];
expected_sigma(:,:,2) = [0.2053    0.0548;    0.0548    0.0515];
assertElementsAlmostEqual(GDS.Sigma,expected_sigma,'absolute',0.01);

