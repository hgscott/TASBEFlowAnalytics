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
        
        extractor = TemplateExtraction([path name ext]);
        
        % Running the actual analysis
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
    catch exception
        % Turn MATLAB error into a TASBESession error
        if isempty(exception.identifier)
            TASBESession.error('analyzeFromExcel', 'NoIdentifier', exception.message);
        else
            if is_octave()
                msg = exception.message;
            else
                msg = strrep(sprintf(getReport(exception, 'extended', 'hyperlinks', 'off')), newline, '');
            end
            id = exception.identifier;
            id_parts = strsplit(id, ':');
            if numel(id_parts) > 1
                name = '';
                for i=2:numel(id_parts)
                    if i > 2
                        name =[name ':' id_parts{i}];
                    else
                        name = id_parts{i};
                    end
                end
                TASBESession.error(id_parts{1}, name, msg);
            else
                TASBESession.error('analyzeFromExcel', exception.identifier, msg);
            end
        end
    end
end