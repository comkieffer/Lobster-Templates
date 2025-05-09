classdef LPrefixNode < LNode
    %LPREFIXNODE Prefixes each line of a block of text.
    %
    %    {% prefix "   % " %}
    %       {%- include "LICENSE" -%}
    %    {% endprefix %}
    %
    % See also LFileTemplate
    
    properties
        Expression (1,1) string
    end
    
    methods
        function self = LPrefixNode(fragment)
            self@LNode(fragment);
            self.CreatesScope = true;
            self.Expression = fragment.Text;
        end
        
        function str = render(self, context)
            str = self.render_children(context);
            prefix = evalin_struct(self.Expression, context, self.Fragment);
            str = regexprep(str, "(?<=\n).", prefix + "$0");
        end
    end
end
