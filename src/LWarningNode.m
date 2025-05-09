classdef LWarningNode < LNode
    %LWARNINGNODE A silent output node throwing a runtime warning.
    %
    %    {% warning "message" %}
    %    {% warning "identifier", "message" %}
    %
    % See also LAssertNode, LErrorNode, LNode
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LWarningNode(fragment)
            self@LNode(fragment);
            self.Expression = "warning(" + fragment.Text + ")";
        end
        
        function str = render(self, context)
            evalin_struct(self.Expression, context, self.Fragment);
            str = "";
        end
    end
end
