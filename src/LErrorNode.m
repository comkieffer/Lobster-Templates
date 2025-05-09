classdef LErrorNode < LNode
    %LERRORNODE A silent output node throwing a runtime error.
    %
    %    {% error "message" %}
    %    {% error "identifier", "message" %}
    %
    % See also LAssertNode, LWarningNode, LNode
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LErrorNode(fragment)
            self@LNode(fragment);
            self.Expression = "error(" + fragment.Text + ")";
        end
        
        function str = render(self, context)
            evalin_struct(self.Expression, context, self.Fragment);
            str = "";
        end
    end
end
