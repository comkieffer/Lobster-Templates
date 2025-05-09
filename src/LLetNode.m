classdef LLetNode < LNode
    %LLETNODE Assigns a temporary variable in the current context.
    %
    %    {% let variable = statement %}
    %        ... {{variable}} is defined here
    %    {% end %}
    %
    % See also LNode
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LLetNode(fragment)
            self@LNode(fragment);
            self.CreatesScope = true;
            self.Expression = fragment.Text;
        end
        
        function str = render(self, context)
            lhs = extractBefore(self.Expression, "=");
            lhs = regexprep(lhs, "(^|(?<![.)}:])\<)([a-zA-Z][\w\d.(){}]*)", "context.$2");
            rhs = extractAfter(self.Expression, "="); %#ok<NASGU> 
            eval(lhs + " = evalin_struct(rhs, context, self.Fragment);");
            str = self.render_children(context);
        end
    end
end
