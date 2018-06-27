% Write TASBEConfig preferences into Template1 spreadsheet
TASBEConfig.checkpoint('init');
[settings, defaults, documentation] = TASBEConfig.list();

names = fieldnames(documentation);
% display(fieldnames(documentation));
% display(documentation.about);
% display(getfield(documentation, 'beads'));

preferences = [];

for i=2:numel(names)
    name = char(names{i});
    doc_section = getfield(documentation, name);
    set_section = getfield(settings, name);
    doc_names = fieldnames(doc_section);
    about_note = getfield(doc_section, doc_names{1});
    row = {name, '', char(about_note)};
    preferences = [preferences; row];
    for j=2:numel(doc_names)
        sub_name = doc_names{j};
        note = getfield(doc_section, doc_names{j});
        value = getfield(set_section, doc_names{j});
        row = {[name '.' char(sub_name)], num2str(value), char(note)};
        preferences = [preferences; row];
    end
end

filename = 'C:/Users/coverney/Documents/SynBio/Template/Template1.xlsx';
sheet = 8;
xlswrite(filename, preferences, sheet);

