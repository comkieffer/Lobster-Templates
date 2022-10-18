classdef LFragment
    %LFRAGMENT Internal value class to tokenize template strings.
    
    properties
       Type (1,1) LFRAGMENT_TYPE
       Text (1,1) string
    end
    
    methods
        function self = LFragment(type, text)
            self.Type = type;
            self.Text = text;
        end
    end
end
