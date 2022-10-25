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
        function self = LElseNode(~)
            self@LElseifNode("1");
        end
    end
end
