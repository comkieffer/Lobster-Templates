classdef LSwitchNode < LNode
    %LSWITCHNODE A node for a switch case statement.
    %
    %    {% switch expression %}
    %    {% case value %}
    %        ...
    %    {% case value %}
    %        ...
    %    {% case value %}
    %        ...
    %    {% otherwise %}
    %        ...
    %    {% end %}
    %
    % See also LCaseNode, LOtherwiseNode, LNode

    properties
        Expression (1,1) string
        Values (1,:) string
        ChildGroups (1,:) cell
    end

    methods
        function self = LSwitchNode(fragment)
            self@LNode(fragment);
            self.CreatesScope = true;
            self.Expression = fragment.Text;
            self.ChildGroups = {};
        end

        function end_scope(self)
            iGroup = 0;
            for k = 1:numel(self.Children)
                child = self.Children{k};
                if isa(child, "LCaseNode")
                    iGroup = iGroup + 1;
                    self.Values(iGroup) = child.Expression;
                    self.ChildGroups{iGroup} = {};
                elseif isa(child, "LOtherwiseNode") || isa(child, "LElseNode")
                    iGroup = iGroup + 1;
                    self.ChildGroups{iGroup} = {};
                elseif iGroup > 0
                    self.ChildGroups{iGroup}{end + 1} = child;
                end
            end

            assert(iGroup > 0, "Lobster:IncompleteSwitchCase", ...
                "The {%% switch e %%} node requires at least one {%% case v %%} node.");
        end

        function str = render(self, context)
            value = evalin_struct(self.Expression, context, self.Fragment);
            for iBranch = 1:numel(self.Values)
                % {% case expression %} group
                if value == evalin_struct(self.Values(iBranch), context, self.Fragment)
                    str = self.render_children(context, self.ChildGroups{iBranch});
                    return
                end
            end

            if numel(self.ChildGroups) > numel(self.Values)
                % {% otherwise %} group
                str = self.render_children(context, self.ChildGroups{end});
            else
                str = "";
            end
        end
    end
end
