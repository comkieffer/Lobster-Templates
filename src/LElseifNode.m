classdef LElseifNode < LNode
    %LELSENODE A silent node that can only be placed inside an LIfNode.
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
    end

    methods
        function self = LElseifNode(expression)
            self.Expression = expression;
        end
    end
end
