% Copyright (C) 2011 - 2018, Raytheon BBN Technologies and contributors listed
% in the AUTHORS file in TASBE Flow Analytics distribution's top directory.
%
% This file is part of the TASBE Flow Analytics package, and is distributed
% under the terms of the GNU General Public License, with a linking
% exception, as described in the file LICENSE in the BBN Flow Cytometry
% package distribution's top directory.

% string contains a single JSON object, cellpairs is a cell array of {{name, value}, ...}
function cellpairs = json_to_cellpairs(string)

% begin by using library to load into a struct
try
    json_object = loadjson(string);
catch exception
    TASBESession.error('TASBE:JSON','Parsing','JSON object did not parse correctly: %s',exception);
end

fields = fieldnames(struct);
cellpairs = cell(numel(fields),2);
for i=1:numel(fields);
    value = json_object.(fields{i});
    cellpairs(i,1) = fields{i};
    if(isstruct(value)), % sub-structures not allowed
        TASBESession.error('TASBE:JSON','Parsing','Cellpairs not allowed to have sub-structure',exception);
        
        subpairs = TASBEConfig.struct_to_json_fields([prefix fields{i} '.'], value);
        fieldpairs = [fieldpairs; subpairs];
    elseif isempty(value)
        % continue: don't serialize fields that aren't set
    else % add the new pair
        fieldpairs = [fieldpairs; {[prefix fields{i}] value}];
    end
    
end

% transform struct into cellpairs, converting semicompleted values as we go


% % first, remove leading and trailing whitespace
% trimmed = strtrim(string);
% % Make sure we are dealing with an curly-bounded object
% if trimmed(1) ~='{'
%     TASBESession.error('TASBE:JSON','Parsing','JSON object does not start with "{"');
% elseif trimmed(end) ~='}'
%     TASBESession.error('TASBE:JSON','Parsing','JSON object does not end with "}"');
% end
% 
% % split everything between the curlies into property entries
% [properties, matches] = strsplit(trimmed(2:(end-1)),',');
% % drop all whitespace around property entries
% for i=1:numel(properties)
%     properties{i} = strtrim(properties{i});
%     if isempty(properties{i}),
%         TASBESession.error('TASBE:JSON','Parsing','JSON property %i is missing; trailing comma?',i);
%     end
% end
% if(numel(matches{1}) ~= numel(properties)-1)
%     TASBESession.error('TASBE:JSON','Parsing','Extra commas found in JSON properties %s');
% end
% 
% % walk the entries, parsing each into propery/value pairs
% cellpairs = cell(numel(properties),2);
% for i=1:numel(properties),
%     % split on property/value
%     prop_val = strsplit(properties{i},':');
%     if(numel(prop_val) ~= 2)
%         TASBESession.error('TASBE:JSON','Parsing','Property does not follow "name : value" format: "%s"',properties{i});
%     end
%     
%     % interpret property and value
%     cellpairs{i,1} = JSON_string_value(strtrim(prop_val{1}));
%     cellpairs{i,2} = interpret_value(strtrim(prop_val{2}));
% end
% 
% end
% 
% 
% function value = interpret_value(string)
%     if string(1)=='[' % is this an array?
%         % TODO: handle multi-dimensional arrays
%         value = JSON_array_value(string);
%     elseif string(1)=='"' % is this a string?
%         value = JSON_string_value(string);
%         % special case for infinity and NaN
%         if strcmp(value,'NaN'), value = NaN;
%         elseif strcmp(value,'Inf'), value = Inf;
%         elseif strcmp(value,'-Inf'), value = -Inf;
%         end
%     else % assume it's a number or boolean
%         value = str2num(string);
%         if(isempty(value))
%             TASBESession.error('TASBE:JSON','Parsing','Could not interpret JSON value: %s',string);
%         end
%     end
% end
% 
% function value = JSON_string_value(string)
%     property_split = strsplit(string,'"');
%     if(numel(property_split)==3 && isempty(property_split{1}) && isempty(property_split{3}))
%         value = property_split{2};
%     else
%         TASBESession.error('TASBE:JSON','Parsing','JSON string does not follow "string" format: %s',string);
%     end
% end
% 
% function values = JSON_array_value(string)
%     % make sure it starts and stops with a square bracket
%     if string(1) ~='['
%         TASBESession.error('TASBE:JSON','Parsing','JSON array does not start with "["');
%     elseif string(end) ~=']'
%         TASBESession.error('TASBE:JSON','Parsing','JSON array does not end with "]"');
%     end
%     
%     % split everything between the brackets into elements
%     elements = strsplit(string(2:(end-1),','));
%     % drop all whitespace around elements and parse into numbers
%     values = zeros(numel(elements),1);
%     for i=1:numel(elements)
%         elements{i} = strtrim(elements{i});
%         if isempty(elements{i}),
%             TASBESession.error('TASBE:JSON','Parsing','JSON array element %i is missing; extra comma?',i);
%         end
%         values(i) = interpret_value(elements{i});
%     end
% end
