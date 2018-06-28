% Write TASBEConfig preferences into Template1 spreadsheet
TASBEConfig.checkpoint('init');

% Read in Excel for information
[num,txt,raw] = xlsread('C:/Users/coverney/Documents/SynBio/Template/Templatev2.xlsx', 'Additional Settings', 'A1:D63');

for i=2:63
    if ~isnan(cell2mat(raw(i,3)))
        if contains(char(cell2mat(raw(i,1))), 'Size')
            bounds = strsplit(char(cell2mat(raw(i,3))), ',');
            TASBEConfig.set(char(cell2mat(raw(i,1))), [str2double(bounds{1}), str2double(bounds{2})]);
        else
            TASBEConfig.set(char(cell2mat(raw(i,1))), cell2mat(raw(i,3)));
        end
    end
end