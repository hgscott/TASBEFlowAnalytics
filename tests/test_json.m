function test_suite = test_json
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_write

writeable = {'foo',3; 'bar','something'; 'baz',true; 'qux',[3.14 0 623 Inf -Inf]; 'quux',NaN};

output = cellpairs_to_json(writeable);

expected = {...
    '{';
    '  "foo" : 3,';
    '  "bar" : "something",';
    '  "baz" : true,';
    '  "qux" : [3.14, 0, 623, "Inf", "-Inf"],';
    '  "quux" : "NaN"';
    '}'
    };
splitout = strsplit(output,'\n');

assertEqual(numel(expected),numel(splitout));
for i=1:numel(expected),
    assertEqual(splitout{i},expected{i});
end


function test_read
