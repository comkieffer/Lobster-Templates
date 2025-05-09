classdef LFragment
    %LFRAGMENT Internal value class to tokenize template strings.
    
    properties
       Type (1,1) LFRAGMENT_TYPE
       Text (1,1) string
       TrimBefore (1,1) logical
       TrimAfter (1,1) logical
       File
       Line
    end
    
    methods
        function self = LFragment(type, text, trimBefore, trimAfter, file, line)
            self.Type = type;
            self.Text = text;
            self.TrimBefore = trimBefore;
            self.TrimAfter = trimAfter;
            self.File = file;
            self.Line = line;
        end
    end
end
