function varargout = evalin_struct(expression, c__, fragment)
    %EVALIN_STRUCT Evaluates an expression in a (struct) context.
    %
    % This function relies heavily on expression caching and the cache has no
    % size limit. Specifically, expressions will be precompiled and stored as
    % anonymous function handles. To clear the expression cache, call:
    % 
    %    clear evalin_struct
    % 
    % See also eval, str2func, containers.Map

    if contains(expression, 'exist') && not(isfield('exist', c__))
        c__.exist = @(varargin) existin_struct(c__, varargin{:});
    end
    
    persistent cache
    try
        compiled = cache(expression);
    catch
        if isempty(cache)
            cache = containers.Map();
        end
        compiled = string(regexp(expression, "(?<![.""'])\<([a-zA-Z]\w*)\>", "match"));
        compiled = reshape(string(intersect(compiled, fieldnames(c__))), 1, []);
        compiled = "@(c__)" + regexprep(expression, "(?<![.""'])\<(" + strjoin(compiled, "|") + ")\>", "c__.$1");
        compiled = str2func(compiled);
        cache(expression) = compiled;
    end

    try
        [varargout{1:nargout}] = compiled(c__);
    catch ME
        variablesUsed = string(regexp(expression, "(?<![.""'])\<([a-zA-Z]\w*)\>", "match"));
        variablesUsed = reshape(string(intersect(variablesUsed, fieldnames(c__))), 1, []);
        variableValues = arrayfun(@(v) c__.(v), variablesUsed, "UniformOutput", false);
        isFcn = cellfun(@(v) isa(v, 'function_handle'), variableValues);
        variableValues(isFcn) = cellfun(@func2str, variableValues(isFcn), "UniformOutput", false);
        c__ = cell2struct(variableValues, variablesUsed, 2);
        
        
        used = jsonencode(c__, PrettyPrint = true);
        used = replace(used, newline, [newline, '        ']);
        if strlength(used) > 1000
            used = extractBefore(used, 1000) + "...";
        end
        error(ME.identifier, "Expression '%s' failed.\n\n  file: %s\n  line: %d\n  func: %s\n  what: %s\n  used: %s\n\n", ...
            strip(expression), fragment.File, fragment.Line, func2str(compiled), ME.message, used);
    end
end

function code = existin_struct(context, name, type)
    if nargin < 3
        type = 'var';
    end
    
    if strcmp(type, 'var')
        code = double(isfield(context, name));
    elseif strcmp(type, '')
        code1 = double(isfield(context, name));
        code2 = exist(name, type);
        if mod(code1, 2) == 1
            code = code2;
        else
            code = code1 + code2;
        end
    else
        code = exist(name, type);
    end
end
