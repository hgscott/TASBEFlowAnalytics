% ensure path ends in slash
function new_path = end_with_slash(path)
    if path(numel(path)) ~= '/'
        path(numel(path)+1) = '/'; 
    end 
    new_path = path;
end