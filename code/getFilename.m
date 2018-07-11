% Helper function that obtains the correct filename for a given row in the
% "Samples" sheet with an Excel object and row number as inputs. 
function [filename] = getFilename(extractor, row)
    % filename_sh = extractor.getSheetNum('first_sample_filename');
    % filename_col = extractor.getColNum('first_sample_filename');
    % filename_col2 = extractor.getColNum('first_sample_exclude');
    % filename = {};
    multiple = 1;
%     % See if there is already a filename inputted at that row
%     for i=filename_col:filename_col2
%         try
%             filename{end+1} = extractor.getExcelValuePos(filename_sh, row, i, 'char');
%         catch
%             break
%         end
%     end
    
%     if numel(filename) > 0
%         return
%     else

    % Only reference filename template if there is no another filename in the override columns
    % First get the template number and create position reference variables
    sh_num1 = extractor.getSheetNum('first_sample_num');
    template_col = extractor.getColNum('first_sample_template');
    template_num = extractor.getExcelValuePos(sh_num1, row, template_col, 'numeric');
    filename_templates = extractor.getExcelCoordinates('filename_templates');
    template_pos = filename_templates{template_num};
    filename_template = extractor.getExcelValuePos(template_pos{1}, template_pos{2}, template_pos{3}, 'char');
    % Extracting the data stem path 
    try
        stem = extractor.getExcelValuePos(template_pos{1}, template_pos{2}+1, template_pos{3}+4, 'char');
    catch
        TASBESession.warn('getFilename','ValueNotFound','Template %s has no data stem.', num2str(template_num));
        stem = '';
    end
    sh_num2 = template_pos{1};
    start_col = template_pos{3};
    start_row = template_pos{2} + 1;
    main_col = start_col + 1;
    variable_col =  main_col + 1;
    sample_start_col = extractor.getColNum('first_sample_num');
    sample_start_row = extractor.getRowNum('first_sample_num') - 1;
    sections = {};
    % Collect the parts (sections) of the filename template
    for i=start_row:size(extractor.sheets{sh_num2},1)
        % Check to see if there is a valid section of the filename template. If so, then check if
        % variable
        try 
            section = extractor.getExcelValuePos(sh_num2, i, main_col, 'char');
        catch
            try
                section = num2str(extractor.getExcelValuePos(sh_num2, i, main_col, 'numeric'));
                if isempty(section)
                    break
                end
            catch
                break
            end
        end  

        try
            extractor.getExcelValuePos(sh_num2, i, variable_col, 'char');
            % Variable, look through columns in samples sheet
            header = section;
            for j=sample_start_col:size(extractor.sheets{sh_num1},2)
                try 
                    ref_header = extractor.getExcelValuePos(sh_num1, sample_start_row, j, 'char');
                catch
                    try
                        ref_header = num2str(extractor.getExcelValuePos(sh_num1, sample_start_row, j, 'numeric'));
                        if isempty(ref_header)
                            break
                        end
                    catch 
                        TASBESession.error('getFilename', 'InvalidHeaderName', 'The header, %s, does not match with any column titles in "Samples" sheet.', header);
                    end
                end
                % Find the matching section name in filename template
                % and column header in "Samples"
                if strcmp(header, ref_header)
                    section = extractor.getExcelValuePos(sh_num1, row, j, 'char');
                    % If the contents is an array, split into
                    % subsections and make filenames for all
                    if ~isempty(strfind(section, ',')) 
                        sub_sections = strsplit(section, ',');
                        sections{end+1} = sub_sections;
                        multiple = numel(sub_sections);
                    else
                        sections{end+1} = {section};
                    end
                    break
                end
            end

        catch
            % Not variable so just add to sections
            sections{end+1} = {section};
        end
        
    end
    positions = {};
    % Replace the numbers in filename_template with the correct section
    for i=1:numel(sections)
        positions{end+1} = strfind(filename_template, num2str(i));
    end

    names = {};
    for i=1:multiple
        names{i} = filename_template;
    end
    
    for j=numel(sections):-1:1
        section = sections{j};
        if ~isempty(section{1})
            % Make sure all sections have the correct length
            for k=numel(section):multiple
                section{k} = section{end};
            end
            for k=1:numel(section)
                names{k} = [names{k}(1:positions{j}) section{k} names{k}(positions{j}+1:end)];
                names{k} = [names{k}(1:positions{j}-1) names{k}(positions{j}+1:end)];
            end
        end
    end
    
    % Add stem name
    for i=1:numel(names)
        names{i} = [stem names{i}];
    end
    
    filename = names;

%     end
    
end