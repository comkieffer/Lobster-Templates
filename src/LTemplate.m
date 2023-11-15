classdef LTemplate < handle
    %LTEMPLATE Base class for string templates.
    %
    %    template = LTemplate(jinja_markup)
    %    template.render(context)
    %
    % See also LFileTemplate
    
    properties (SetAccess = immutable)
       Root (1,1) LRoot
    end
    
    methods
        function self = LTemplate(template)
            if nargin > 0
                self.Root = LCompiler(template).compile();
            end
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
