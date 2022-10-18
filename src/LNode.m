classdef (Abstract) LNode < handle
    %LNODE Base class for template nodes.
    %
    % See also LAssertNode, LElseNode, LForNode, LIfNode, LIncludeNode,
    %          LLetNode, LRoot, LTextNode, LVarNode
    
    properties
        CreatesScope (1,1) logical = false
        Children (1,:) cell
    end
    
    methods
        function str = render(self, context)
            str = render_children(self, context);
        end
        
        function str = render_children(self, context)
            str = "";
            for k = 1:numel(self.Children)
                str = str + render(self.Children{k}, context);
            end
        end
    end
end
