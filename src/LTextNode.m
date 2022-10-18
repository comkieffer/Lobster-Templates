classdef LTextNode < LNode
    %LTEXTNODE Rendering node for text output.
    %
    % See also LNode
    
    properties
        Text (1,1) string
    end
    
    methods
        function self = LTextNode(fragment)
            self.Text = fragment;
        end
        
        function str = render(self, ~)
            str = self.Text; 
        end
    end
end
