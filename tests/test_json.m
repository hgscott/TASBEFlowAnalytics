function test_suite = test_json
    TASBEConfig.checkpoint('test');
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

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

end


function test_read

readable = '{"foo" : 3, "bar" : "something", "baz" : true, "qux" : [3.14, 0, 623, "Inf", "-Inf"], "quux" : "NaN"}';
expected = {'foo',3; 'bar','something'; 'baz',true; 'qux',[3.14 0 623 Inf -Inf]; 'quux',NaN};

output = json_to_cellpairs(readable);

assertEqual(size(expected), size(output));
assertEqual(expected,output);
end

function test_whitespace_reading

readable = sprintf('\n\n {  \n"foo":3\n \n,  \n"baz"   :   true}\n\n\n');
expected = {'foo',3; 'baz',true};

output = json_to_cellpairs(readable);

assertEqual(size(expected), size(output));
assertEqual(expected,output);
end


function test_read_errors

error_reads = {
    ' "foo" : 3 ';
    '{ "foo" : 3';
    ' "foo" : 3}';
    '{ "foo" : 3,}';
    '{ "foo" : 3   "bar":4}';
    '{ "foo" : 3,,"bar":4}';
    '{ "foo" : 3,"bar":4,}';
    '{ "foo" : 3:4}';
    '{ "foo" : [3,]}';
    '{ "foo" : [4,"bar"]}';
    '{ "foo" : [4}';
    '{ "foo" : 4]}';
    '{ "foo" : "bar]}';
    '{ "foo" : "bar""]}';
    '{ foo" : "bar"]}';
    };

for i=1:numel(error_reads)
    error = false;
    try 
        json_to_cellpairs(error_reads{i});
        warning('Failed to error on %s',error_reads{i});
    catch 
        error = true;
    end
    assert(error);
end

end
