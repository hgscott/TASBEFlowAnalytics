function enter_test_mode()

TASBEConfig.reset();
TASBEConfig.set('testing.fakeFigureSaves',1);
warning('off','backtrace');
warning('off','TASBE:outputfig:TestMode');
warning('off','TASBE:outputfig:MakeDirectory');
TASBEConfig.checkpoint('test');
