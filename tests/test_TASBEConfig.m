function test_suite = test_TASBEConfig
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions=localfunctions();
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;

function test_config

assert(TASBEConfig.isSet('foo') == false);

missingError = false;
try
    TASBEConfig.getexact('foo.bar.baz.qux')
    missingError = true;
catch e  % error is expected
end
if missingError, error('Should have failed on missing preference'); end;

assert(TASBEConfig.getexact('foo.bar.baz.qux',1) == 1);
assert(TASBEConfig.getexact('foo.bar.baz.qux') == 1);

assert(TASBEConfig.getexact('foo.bar.baz.qux',2) == 1);
assert(TASBEConfig.get('foo.bar.baz.qux') == 1);

assert(TASBEConfig.set('foo.bar.baz.qux',3) == 3);
assert(TASBEConfig.get('foo.bar.baz.qux') == 3);

assert(TASBEConfig.list.foo.bar.baz.qux == 3);

try
    TASBEConfig.getexact('calibration.plotPath');
    missingError = true;
catch e  % error is expected
end
if missingError, error('Should have failed on missing preference'); end;

assert(strcmp(TASBEConfig.get('calibration.plotPath'),'plots/'));

assert(TASBEConfig.isSet('foo') == true);
TASBEConfig.clear('foo');
assert(TASBEConfig.isSet('foo') == false);

try
    TASBEConfig.get('foo')
    missingError = true;
catch e  % error is expected
end
if missingError, error('Should have failed on missing preference'); end;

try
    TASBEConfig.list.foo.bar.baz.qux
    missingError = true;
catch e  % error is expected
end
if missingError, error('Should have failed on missing preference'); end;
