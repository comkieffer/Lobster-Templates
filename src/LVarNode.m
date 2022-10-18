classdef LVarNode < LNode
    %LVARNODE Rendering node for variable output.
    %
    %    {{statement}}
    %
    % The statement will be interpreted in the current variable context. Variables
    % accessible in the context will take precedence over functions with the same
    % name. String conversion is provided via the string() function. If you need
    % different formatting, i.e. hexadecimal output, produce a string directly:
    %
    %    {{sprintf("0x%08X", hexadecimal_value)}}
    %
    % See also evalin_struct, LNode

    properties
        Expression (1,1) string
    end

    methods
        function self = LVarNode(fragment)
            self.Expression = fragment;
        end

        function str = render(self, context)
            str = string(evalin_struct(self.Expression, context));
            
            if ismissing(str)
                str = "<missing>";
            end
        end
    end
end
