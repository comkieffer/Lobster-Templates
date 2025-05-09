classdef (Abstract) LNode < handle
    %LNODE Base class for template nodes.
    %
    % See also LAssertNode, LElseNode, LForNode, LIfNode, LIncludeNode,
    %          LLetNode, LRoot, LTextNode, LVarNode

    properties
        CreatesScope (1,1) logical = false
        Children (1,:) cell
        Fragment
    end

    methods
        function self = LNode(fragment)
            self.Fragment = fragment;
        end
        
        function end_scope(~)
            % stub
        end

        function str = render(self, context)
            str = render_children(self, context);
        end

        function str = render_children(self, context, children)
            if nargin < 3
                children = self.Children;
            end
            
            str = "";
            for k = 1:numel(children)
                str = str + render(children{k}, context);
            end
        end
    end
end
