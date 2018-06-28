function [filename] = getFilename(row)
    % Read in Excel for information, Experiment sheet
    [~,~,raw] = xlsread('C:/Users/coverney/Documents/SynBio/Template/Templatev2.xlsx', 'Experiment', 'A1:J20');
    % Read in Excel for information, Samples sheet
    [~,~,raw2] = xlsread('C:/Users/coverney/Documents/SynBio/Template/Templatev2.xlsx', 'Samples', 'A1:O18');
    
    filename_template = cell2mat(raw(13,5));
    if ~isnan(filename_template)
        filename_template = char(filename_template);
    else
        TASBESession.warn('make_color_model', 'CriticalInfoMissing', 'Filename template is missing from "Experiment" sheet');
    end
    
    for i=14:size(raw,1)
        % check to see if there is something at col 6. If so, then check if
        % variable
        if ~isnan(cell2mat(raw(i,6)))
            display(cell2mat(raw(i,6)))
        else
            break
        end
    end

end