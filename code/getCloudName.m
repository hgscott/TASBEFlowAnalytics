% Helper function that obtains the correct point cloud filename for a given row in the
% "Samples" sheet with an Excel object, row number, and template number as inputs. 
function [filename] = getCloudName(extractor, row, template_num)
    multiple = 1;
    % First get the template number and create position reference variables
    sh_num1 = extractor.getSheetNum('first_sample_num');
    TASBEConfig.set('template.displayErrors', 1);
    filename_templates = extractor.getExcelCoordinates('filename_templates');
    template_pos = filename_templates{template_num};
    filename_template = extractor.getExcelValuePos(template_pos{1}, template_pos{2}, template_pos{3}, 'char');
    TASBEConfig.set('template.displayErrors', 0);
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
            checkError = true;
            header = section;
            for j=sample_start_col:size(extractor.sheets{sh_num1},2)
                try 
                    ref_header = extractor.getExcelValuePos(sh_num1, sample_start_row, j, 'char');
                catch
                    try
                        ref_header = num2str(extractor.getExcelValuePos(sh_num1, sample_start_row, j, 'numeric'));
                        if isempty(ref_header)
                            continue
                        end
                    catch 
                        continue
                    end
                end
                % Find the matching section name in filename template
                % and column header in "Samples"
                if strcmp(header, ref_header)
                    checkError = false;
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
            
            if checkError
                TASBESession.error('getFilename', 'InvalidHeaderName', 'The header, %s, does not match with any column titles in "Samples" sheet.', header);
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
    
    % Add ext 
    for i=1:numel(names)
        [~, name, ext] = fileparts(names{i});
        exts = {'fcs', 'csv'};
        ind = find(ismember(exts, ext), 1);
        if ~isempty(ind)
            names{i} = [name '.fcs'];
        else
            names{i} = [names{i} '.fcs'];
        end
    end
    
    filename = names;
    
end