% Wrapper function that creates an Excel object and calls the color model
% and batch analysis functions. The only needed inputs are the template
% file path and type of analysis that needs to be run.
function analyzeFromExcel(file, type)
    try
        % Editing file to get path
        [filepath, name, ext] = fileparts(file);
        path = end_with_slash(filepath);
        % Setting up TASBESession log key
        TASBESession.warn('analyzeFromExcel', 'ExampleWarning', 'This is what a warning looks like.');
        TASBESession.succeed('analyzeFromExcel', 'ExampleSuccess', 'This is what a success/ notification looks like.');
        TASBESession.skip('analyzeFromExcel', 'ExampleSkip', 'A skip is also green.');
        try
            TASBESession.error('analyzeFromExcel', 'ExampleError', 'This is what an error looks like.');
        catch
            % Just makes sure that the program does not terminate after
            % establishing key for TASBESession log
        end
        
        % Running the actual analysis
        switch type
            case {'colormodel', 'CM', 'Colormodel'}
                % Make color model
                extractor = TemplateExtraction([path name ext]);
                make_color_model_excel(path, extractor);
            case {'batch', 'BA', 'Batch'}
                % Run batch analysis
                extractor = TemplateExtraction([path name ext]);
                batch_analysis_excel(path, extractor);
            case {'plusminus', 'PM', 'Plusminus', 'comparativeanalysis', 'companalysis', 'comparative'}
                % Run plus minus analysis
                extractor = TemplateExtraction([path name ext]);
                plusminus_analysis_excel(path, extractor);
            case {'transfercurve', 'TC', 'Transfercurve'}
                % Run transfer curve analysis 
                extractor = TemplateExtraction([path name ext]);
                transfercurve_analysis_excel(path, extractor);
            otherwise
                TASBESession.error('analyzeFromExcel', 'InvalidType', 'Input type of %s is invalid. The choices are colormodel, batch, plusminus, and transfercurve.', type);
        end
    catch exception
        % Turn MATLAB error into a TASBESession error
        if isempty(exception.identifier) || is_octave()
            TASBESession.error('analyzeFromExcel', 'NoIdentifier', exception.message);
        else
            msg = strrep(sprintf(getReport(exception, 'extended', 'hyperlinks', 'off')), newline, '');
            TASBESession.error('analyzeFromExcel', exception.identifier, msg);
        end
    end
end