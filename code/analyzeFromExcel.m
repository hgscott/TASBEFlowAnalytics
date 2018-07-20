% Wrapper function that creates an Excel object and calls the color model
% and batch analysis functions. The only needed inputs are the template
% file path and type of analysis that needs to be run.
function analyzeFromExcel(file, type)
%     try
        % Editing file to get path
        file = strrep(file, '\', '/');
        file_parts = strsplit(file, '/');
        path = '';
        for i=1:numel(file_parts)-1
            path = [path file_parts{i} '/'];
        end
        path = end_with_slash(path);
        
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
        extractor = TemplateExtraction(file);
        switch type
            case {'colormodel', 'CM', 'Colormodel'}
                % Make color model
                make_color_model_excel(path, extractor);
            case {'batch', 'BA', 'Batch'}
                % Run batch analysis
                batch_analysis_excel(path, extractor);
            case {'plusminus', 'PM', 'Plusminus', 'comparativeanalysis', 'companalysis', 'comparative'}
                % Run plus minus analysis
                plusminus_analysis_excel(path, extractor);
            case {'transfercurve', 'TC', 'Transfercurve'}
                % Run transfer curve analysis 
                transfercurve_analysis_excel(path, extractor);
            otherwise
                TASBESession.error('analyzeFromExcel', 'InvalidType', 'Input type of %s is invalid. The choices are colormodel, batch, plusminus, and transfercurve.', type);
        end
%     catch exception
%         % Turn MATLAB error into a TASBESession error
%         TASBESession.error('analyzeFromExcel', exception.identifier, exception.message);
%     end
end