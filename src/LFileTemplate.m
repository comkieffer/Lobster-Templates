function template = LFileTemplate(filename, searchPath, verbose)
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
    % As an additional feature, you can specify a list of search folders that
    % contain template files. This will register all template files in the
    % specified folders and their subfolders. This is useful if you want to
    % include templates from different folders without specifying the full path.
    % Normally, Lobster will look for templates on the MATLAB search path. That
    % is however unavailable in deployed applications. To make sure that Lobster
    % can find the templates in deployed applications, you can specify the search
    % path manually. This is done by passing an array of strings, a cell array
    % of strings or a containers.Map object as the second argument. The
    % containers.Map object should map template names to their full paths:
    %
    %   template = LFileTemplate("myfile.template", "templates")
    %   template = LFileTemplate("myfile.template", ["base", "override"])
    %   searchPath = containers.Map();
    %   searchPath("alias") = "templates/myfile.template";
    %   template = LFileTemplate("alias", searchPath)
    %
    % You can pass a special empty string, "", to get an empty template. This is
    % needed for inclusion lists with silent fail behaviour. The following first
    % example renders an empty block, while the second line throws an error:
    %
    %   {% include ["does-not-exist", ""] %}
    %   {% include "does-not-exist" %}
    %
    % If you pass in true as the third argument, the template file registration
    % will be printed to the console. Use this to debug if your template overrides
    % are not working as expected.
    %
    % See also LTemplate, LIncludeNode
    
    arguments
        filename (1,1) string
        searchPath = []
        verbose (1,1) logical = false
    end
    
    persistent registeredFiles
    persistent cache
    
    if isnumeric(registeredFiles)
        registeredFiles = containers.Map();
    end
    
    if nargin > 1 && isa(searchPath, "containers.Map")
        registeredFiles = searchPath;
    end
    
    if nargin > 1 && (isstring(searchPath) || iscellstr(searchPath))
        for folder = searchPath
            for file = transpose(dir(fullfile(folder, "**", "*.template")))
                if file.isdir
                    continue
                end
                registeredFiles(file.name) = fullfile(file.folder, file.name);
            end
        end
    end
    
    if nargin > 1 && verbose
        fprintf("-- template files registered\n");
        cellfun(@(v) fprintf("    - %s\n", v), registeredFiles.values());
    end
    
    try
        template = cache(filename);
    catch
        if isempty(cache)
            cache = containers.Map();
        end
        template = compile(filename);
        cache(filename) = template;
    end
    
    function template = compile(filename)
        if filename == ""
            template = LTemplate();
            return
        end
        
        try
            filename = registeredFiles(filename);
        catch
            fullFilename = which(filename);
            if isempty(dir(fullFilename))
                error("Lobster:NoSuchTemplate", ...
                    "Could not find template file %s", filename);
            end 
            filename = fullFilename;
        end
        
        try
            template = LTemplate(fileread(filename), filename);
        catch reason
            error("Lobster:FileCompilationError", ...
                "Error while compiling template file %s: %s %s", ...
                filename, reason.identifier, reason.message);
        end
    end
end
