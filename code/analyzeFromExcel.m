% Wrapper function that creates an Excel object and calls the color model
% and batch analysis functions. The only needed inputs are the template
% file path and type of analysis that needs to be run.
function analyzeFromExcel(file, type)
    extractor = TemplateExtraction(file);
    if ~isempty(strfind(type, 'colormodel'))
        % Make color model
        make_color_model_excel(extractor);
    elseif ~isempty(strfind(type, 'batch'))
        % Run batch analysis
        batch_analysis_excel(extractor);
    elseif ~isempty(strfind(type, 'plusminus'))
        % Run plus minus analysis
        plusminus_analysis_excel(extractor);
    else
        % Run transfer curve analysis 
        transfercurve_analysis_excel(extractor);
    end

end