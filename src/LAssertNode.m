classdef LAssertNode < LNode
    %LASSERTNODE A silent output node throwing a runtime error if the expression fails.
    %
    %    {% assert statement %}
    %    {% assert statement, "error message" %}
    %
    % See also LErrorNode, LNode
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LAssertNode(fragment)
            self@LNode(fragment);
            self.Expression = "assert(" + fragment.Text + ")";
        end
        
        function str = render(self, context)
            evalin_struct(self.Expression, context, self.Fragment);
            str = "";
        end
    end
end
