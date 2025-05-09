classdef LTemplate < handle
    %LTEMPLATE Base class for string templates.
    %
    %    template = LTemplate(jinja_markup)
    %    template.render(context)
    %
    % See also LFileTemplate
    
    properties (SetAccess = immutable)
       Root
    end
    
    methods
        function self = LTemplate(template, debugFile)
            arguments
                template (1,1) string = ""
                debugFile (1,1) string = ""
            end
            
            self.Root = LCompiler(template, debugFile).compile();
        end
        
        function str = render(self, context)
            arguments
                self
                context (1,1) struct = struct()
            end

            str = self.Root.render(context);
        end
    end
end
