function [filename] = getFilename(row)
    extractor = Excel;
    filename_sh = extractor.getSheetNum('first_sample_filename');
    filename_col = extractor.getColNum('first_sample_filename');
    try
        filename = extractor.getExcelValuePos(filename_sh, row, filename_col, 'char');
        return;
    catch
        % Only reference filename template if there is not another filename in the override columns
        % in "Samples"
        filename_template = extractor.getExcelValue('filename_template', 'char');
        sh_num = extractor.getSheetNum('filename_template');
        sh_num2 = extractor.getSheetNum('first_sample_num');
        start_col = extractor.getColNum('filename_template');
        start_row = extractor.getRowNum('filename_template') + 1;
        main_col = start_col + 1;
        variable_col =  main_col + 1;
        sample_start_col = extractor.getColNum('first_sample_num');
        sample_start_row = extractor.getRowNum('first_sample_num') - 1;
        sections = {};
        for i=start_row:size(extractor.sheets{sh_num},1)
            % check to see if there is something at col 6. If so, then check if
            % variable
            try 
                section = extractor.getExcelValuePos(sh_num, i, main_col, 'char');
            catch
                try
                    section = num2str(extractor.getExcelValuePos(sh_num, i, main_col, 'numeric'));
                catch
                    break
                end
            end

            try
                extractor.getExcelValuePos(sh_num, i, variable_col, 'char');
                % variable, look for columns in samples sheet
                header = section;
                for j=sample_start_col:size(extractor.sheets{sh_num2},2)
                    try 
                        ref_header = extractor.getExcelValuePos(sh_num2, sample_start_row, j, 'char');
                    catch
                        try
                            ref_header = num2str(extractor.getExcelValuePos(sh_num2, sample_start_row, j, 'numeric'));
                        catch 
                            TASBESession.error('getFilename', 'InvalidHeaderName', 'The header, %s, does not match with any column titles in "Samples" sheet.', header);
                        end
                    end
                    if strcmp(header, ref_header)
                        section = extractor.getExcelValuePos(sh_num2, row, j, 'char');
                        if contains(section, ',')
                            sub_sections = strsplit(section, ',');
                        end
                        sections{end+1} = sub_sections{1};
                    end
                end

            catch
                % not variable
                sections{end+1} = section;
            end
        end
        positions = {};
        filename = filename_template;
        % replace the numbers in filename_template with the correct section
        for i=1:numel(sections)
            positions{end+1} = strfind(filename_template, num2str(i));
        end

        for i=numel(sections):-1:1
            filename = insertAfter(filename, positions{i}, sections{i});
            filename = [filename(1:positions{i}-1) filename(positions{i}+1:end)];
        end
    end
    
end