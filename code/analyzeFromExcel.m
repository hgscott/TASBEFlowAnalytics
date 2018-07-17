% Wrapper function that creates an Excel object and calls the color model
% and batch analysis functions. The only needed inputs are the template
% file path and type of analysis that needs to be run.
function analyzeFromExcel(file, type)
    TASBESession.warn('analyzeFromExcel', 'ExampleWarning', 'This is what a warning looks like.');
    TASBESession.succeed('analyzeFromExcel', 'ExampleSuccess', 'This is what a success/ notification looks like.');
    TASBESession.skip('analyzeFromExcel', 'ExampleSkip', 'A skip is also green.');
    try
        TASBESession.error('analyzeFromExcel', 'ExampleError', 'This is what an error looks like.');
    catch
        % Just makes sure that the program does not terminate after
        % establishing key for TASBESession log
    end
    extractor = TemplateExtraction(file);
    switch type
        case {'colormodel', 'CM', 'Colormodel'}
            % Make color model
            make_color_model_excel(extractor);
        case {'batch', 'BA', 'Batch'}
            % Run batch analysis
            batch_analysis_excel(extractor);
        case {'plusminus', 'PM', 'Plusminus'}
            % Run plus minus analysis
            plusminus_analysis_excel(extractor);
        case {'transfercurve', 'TC', 'Transfercurve'}
            % Run transfer curve analysis 
            transfercurve_analysis_excel(extractor);
        otherwise
            TASBESession.error('analyzeFromExcel', 'InvalidType', 'Input type of %s is invalid. The choices are colormodel, batch, plusminus, and transfercurve.', type);
    end
end