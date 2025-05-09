classdef LElseNode < LElseifNode
    %LELSENODE A silent node that can only be placed inside an LIfNode.
    %
    %    {% if statement %}
    %        ...
    %    {% else %}
    %        ...
    %    {% end %}
    %
    % See also LIfNode, LNode

    methods
        function self = LElseNode(fragment)
            fragment.Text = "1";
            self@LElseifNode(fragment);
        end
    end
end
