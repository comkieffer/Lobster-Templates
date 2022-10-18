classdef LElseNode < LNode
    %LELSENODE A silent output node that can only be placed inside an LIfNode.
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
            % ignore argument
        end
    end
end
