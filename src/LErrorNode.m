classdef LErrorNode < LNode
    %LERRORNODE A silent output node throwing a runtime error.
    %
    %    {% error "message" %}
    %    {% error "identifier", "message" %}
    %
    % See also LAssertNode, LNode
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LErrorNode(fragment)
            self.Expression = "error(" + fragment + ")";
        end
        
        function str = render(self, context)
            evalin_struct(self.Expression, context);
            str = "";
        end
    end
end
