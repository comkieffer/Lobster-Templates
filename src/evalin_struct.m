function varargout = evalin_struct(expression, context)
    %EVALIN_STRUCT Evaluates an expression in a (struct) context.
    %
    % This function relies heavily on expression caching and the cache has no
    % size limit. Specifically, expressions will be precompiled and stored as
    % anonymous function handles. To clear the expression cache, call:
    % 
    %    clear evalin_struct
    % 
    % See also eval, str2func, containers.Map

    persistent cache
    try
        compiled = cache(expression);
    catch
        if isempty(cache)
            cache = containers.Map();
        end
        compiled = string(regexp(expression, "(?<![.""'])\<([a-zA-Z]\w*)\>", "match"));
        compiled = reshape(string(intersect(compiled, fieldnames(context))), 1, []);
        compiled = "@(c)" + regexprep(expression, "(?<![.""'])\<(" + strjoin(compiled, "|") + ")\>", "c.$1");
        compiled = str2func(compiled);
        cache(expression) = compiled;
    end

    try
        [varargout{1:nargout}] = compiled(context);
    catch ME
        error(ME.identifier, "Expression '%s' failed in context %s.\n\n%s", expression, ...
            jsonencode(fieldnames(context)), ME.message);
    end
end
