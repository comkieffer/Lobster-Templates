classdef LForNode < LNode
    %LFORNODE Renders children in a FOR loop.
    %
    %    {% for lhs = rhs %}
    %        ...
    %    {% end %}
    %
    % The right hand side of the expression can by any numerical, object or cell array.
    % The loop will iterate over all elements and render its children for each.
    %
    % See also LNode
    
    properties
        LHS (1,1) string
        RHS (1,1) string
    end
    
    methods
        function self = LForNode(fragment)
            self.CreatesScope = true;
            matches = regexp(fragment, "^(.*?) (?:in|=) (.*)$", "tokens");
            if length(matches{1}) ~= 2
                error("Lobster:TemplateSyntaxError", "{%% for %s %%} is invalid syntax.", fragment);
            end
            self.LHS = strtrim(matches{1}{1});
            self.RHS = matches{1}{2};
        end

        function str = render(self, context)
            collection = evalin_struct(self.RHS, context);
            
            str = "";
            n = numel(collection);
            isCell = iscell(collection);
            context.last_loop_idx__ = n;
            for k = 1:n
                context.loop_idx__ = k;
                if isCell
                    context.(self.LHS) = collection{k};
                else
                    context.(self.LHS) = collection(k);
                end
                str = str + self.render_children(context);
            end
        end
    end
end
