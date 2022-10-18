function template = LFileTemplate(filename)
    %LFILETEMPLATE Accessor for templates stored in files with cached output.
    %
    %    template = LFileTemplate("myfile.template")
    %
    % Uses an internal cache to resolve templates faster and avoid recompilation.
    % This makes loading static templates fast but the cache might grow large.
    % To empty the template file cache, call:
    %
    %    clear LFileTemplate
    %
    % See also LTemplate, LIncludeNode
    
    persistent cache
    try
        template = cache(filename);
    catch
        if isempty(cache)
            cache = containers.Map();
        end
        template = compile(filename);
        cache(filename) = template;
    end
end

function template = compile(filename)
    filename = which(filename);
    fileinfo = dir(filename);
    if isempty(fileinfo)
        template = LTemplate();
    else
        try
            template = LTemplate(fileread(filename));
        catch reason
            error("Lobster:FileCompilationError", ...
                "Error while compiling template file %s: %s %s", ...
                filename, reason.identifier, reason.message);
        end
    end
end
