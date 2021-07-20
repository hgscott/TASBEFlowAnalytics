function test_suite = test_statistics
    enter_test_mode();
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_geomean
    assertElementsAlmostEqual(geomean([2 4 8]),4)
    
function test_geostd
    assertElementsAlmostEqual(geostd([2 4 8]),2)
