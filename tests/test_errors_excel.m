function test_suite = test_errors_excel
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_errors_excel_filenames
    % Create TemplateExtraction object
    extractor = TemplateExtraction('../../test_templates/faulty_batch_template1.xlsx');
    [filepath, ~, ~] = fileparts(mfilename('fullpath'));
    CM = load_or_make_testing_colormodel();
    assertExceptionThrown(@()batch_analysis_excel(filepath, extractor, CM), 'getExcelFilename:FilenameNotFound', 'No error was raised');
    