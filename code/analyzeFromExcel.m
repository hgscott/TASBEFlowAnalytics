% Wrapper function that creates an Excel object and calls the color model
% and batch analysis functions. The only needed input is the template
% file path.
function analyzeFromExcel(file)
    extractor = Excel(file);
    CM = make_color_model_excel(extractor);
    batch_analysis_excel(extractor, CM);
end