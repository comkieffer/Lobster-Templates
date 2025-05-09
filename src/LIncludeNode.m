classdef LIncludeNode < LNode
    %LINCLUDENODE Includes a template from another file.
    %
    %    {% include "myfile.template" %}
    %    {% include dynamic_filename_expression %}
    %
    % See also LFileTemplate
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LIncludeNode(fragment)
            self@LNode(fragment);
            self.Expression = fragment.Text;
        end
        
        function str = render(self, context)
            filenames = string(evalin_struct(self.Expression, context, self.Fragment));
            filenames = reshape(filenames, 1, []);
            
            mask = not(endsWith(filenames, ".template"));
            filenames(mask) = filenames(mask) + ".template";
            
            template = [];
            for filename = filenames
                try
                    template = LFileTemplate(filename);
                    break
                catch e
                    if e.identifier == "Lobster:NoSuchTemplate"
                        continue
                    else
                        rethrow(e);
                    end
                end
            end
            
            if isempty(template)
                error("lobster:NoSuchTemplate", "Could not find any of the templates: %s", jsonencode(filenames));
            end
            
            str = template.render(context);
        end
    end
end
