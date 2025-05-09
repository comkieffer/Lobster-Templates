classdef LIfNode < LNode
    %LIFNODE A node that evaluates either branch depending on the statement.
    %
    %    {% if statement %}
    %        ...
    %    {% elseif statement %}
    %        ...
    %    {% else %}
    %        ...
    %    {% end %}
    %
    % See also LElseifNode, LElseNode, LNode

    properties
        Expressions (1,:) string
        ChildGroups (1,:) cell
    end

    methods
        function self = LIfNode(fragment)
            self@LNode(fragment);
            
            self.CreatesScope = true;
            self.Expressions = fragment.Text;
            self.ChildGroups = {{}};
        end

        function end_scope(self)
            iGroup = 1;
            for k = 1:numel(self.Children)
                child = self.Children{k};
                if isa(child, "LElseifNode")
                    iGroup = iGroup + 1;
                    self.Expressions(iGroup) = child.Expression;
                    self.ChildGroups{iGroup} = {};
                elseif isa(child, "LElseNode")
                    iGroup = iGroup + 1;
                    self.ChildGroups{iGroup} = {};
                else
                    self.ChildGroups{iGroup}{end + 1} = child;
                end
            end
        end

        function str = render(self, context)
            for iBranch = 1:numel(self.Expressions)
                if evalin_struct(self.Expressions(iBranch), context, self.Fragment)
                    % {% elseif %} group
                    str = self.render_children(context, self.ChildGroups{iBranch});
                    return
                end
            end

            if numel(self.ChildGroups) > numel(self.Expressions)
                % {% else %} group
                str = self.render_children(context, self.ChildGroups{end});
            else
                str = "";
            end
        end
    end
end
