classdef LIfNode < LNode
    %LIFNODE A node that evaluates either branch depending on the statement.
    %
    %    {% if statement %}
    %        ...
    %    {% else %}
    %        ...
    %    {% end %}
    %
    % The is no ELSEIF node for now. For multiple branches, nest nodes:
    %
    %    {% if statement %}
    %        ...
    %    {% else %}{% if statement %}
    %        ...
    %    {% else %}
    %        ...  
    %    {% end %}{% end %}
    %
    % See also LElseNode, LNode
    
    properties
        Expression (1,1) string
        OnIfBranch = []
    end
    
    methods
        function self = LIfNode(fragment)
            self.CreatesScope = true;
            self.Expression = fragment;
        end
        
        function str = render(self, context)
            str = "";
            if evalin_struct(self.Expression, context)
                for k = 1:numel(self.Children)
                    if isa(self.Children{k}, "LElseNode")
                        break
                    end
                    str = str + render(self.Children{k}, context);
                end
            else
                skip = true;
                for k = 1:numel(self.Children)
                    if skip
                        skip = not(isa(self.Children{k}, "LElseNode"));
                        continue
                    end
                    str = str + render(self.Children{k}, context);
                end
            end
        end
    end
end
