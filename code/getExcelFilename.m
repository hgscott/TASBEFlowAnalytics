% Helper function that obtains the correct filename for a given row in the
% "Samples" sheet with an Excel object and row number as inputs. 
function [filename] = getExcelFilename(extractor, row, path)
    % Take filenames from Excel and throw error if no filename is found
    sh_num1 = extractor.getSheetNum('first_sample_num');
    exclude_col = extractor.getColNum('first_sample_exclude');
    template_col = extractor.getColNum('first_sample_template');
    TASBEConfig.set('template.displayErrors', 1);
    template_num = extractor.getExcelValuePos(sh_num1, row, template_col, 'numeric');
    filename_templates = extractor.getExcelCoordinates('filename_templates');
    template_pos = filename_templates{template_num};
    TASBEConfig.set('template.displayErrors', 0);
    % Extracting the data stem path 
    try
        stem = extractor.getExcelValuePos(template_pos{1}, template_pos{2}+1, template_pos{3}+4, 'char');
        javaFileObj = javaObject("java.io.File", end_with_slash(stem));
        if javaFileObj.isAbsolute()
            stem = end_with_slash(stem);
        else
            stem = end_with_slash(fullfile(path, stem));
        end
    catch
        TASBESession.warn('getExcelFilename','ValueNotFound','Template %s has no data stem.', num2str(template_num));
        stem = '';
    end
    
    names = {};
    
    % Extracting the filenames
    for i=exclude_col+1:size(extractor.sheets{sh_num1},2)
        try
            name = extractor.getExcelValuePos(sh_num1, row, i);
            display(name);
            names{end+1} = name;
        catch
            if isempty(names)
                TASBESession.error('getExcelFilename', 'FilenameNotFound', 'No filename found at row %s. Make sure "Click to Update Filenames" button was pressed.', num2str(row));
            end
            break
        end
    end
    
    % Add stem name
    for i=1:numel(names)
        names{i} = [stem names{i}];
    end
    
    filename = names;
end