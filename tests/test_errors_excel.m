function test_suite = test_errors_excel
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_errors_excel_filenames
    % Create TemplateExtraction object
    extractor = TemplateExtraction('test_templates/faulty_batch_template1.xlsx');
    [filepath, ~, ~] = fileparts(mfilename('fullpath'));
    CM = load_or_make_testing_colormodel();
    assertExceptionThrown(@()batch_analysis_excel([end_with_slash(filepath) '../'], extractor, CM), 'getExcelFilename:FilenameNotFound', 'No error was raised');

function test_errors_excel_session
    assertExceptionThrown(@()analyzeFromExcel('', ''), 'analyzeFromExcel:NoIdentifier', 'No error was raised');    
    
function test_errors_excel_channel_roles
    CM = load_or_make_testing_colormodel();
    % Test 0 channel roles
    extractor = TemplateExtraction('test_templates/test_batch_template3.xlsx');
    assertExceptionThrown(@()getChannelRoles(CM, extractor), 'getChannelRoles:NoInformation', 'No error was raised'); 
    % Test 1 channel role
    extractor = TemplateExtraction('test_templates/test_batch_template2.xlsx');
    assertExceptionThrown(@()getChannelRoles(CM, extractor), 'getChannelRoles:TooFew', 'No error was raised'); 
    % Test 2 channel roles
    extractor = TemplateExtraction('test_templates/test_batch_template5.xlsx');
    [channel_roles, print_names] = getChannelRoles(CM, extractor); 
    expected_names = {'EYFP', 'mKate'};
    assertEqual(numel(channel_roles), 1);
    assertEqual(print_names, expected_names);
    % Test 3 channel roles
    extractor = TemplateExtraction('test_templates/test_batch_template1.xlsx');
    [channel_roles, print_names] = getChannelRoles(CM, extractor); 
    expected_names = {'EYFP', 'mKate', 'EBFP2'};
    assertEqual(numel(channel_roles), 1);
    assertEqual(print_names, expected_names);
    % Test 4 channel roles
    extractor = TemplateExtraction('test_templates/faulty_batch_template1.xlsx');
    [channel_roles, print_names] = getChannelRoles(CM, extractor); 
    expected_names = {'EYFP', 'mKate', 'EBFP2', 'EYFP'};
    assertEqual(numel(channel_roles), 2);
    assertEqual(print_names, expected_names); 
    
        