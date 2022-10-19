classdef LCompiler < handle
    
    properties
        Template (1,1) string
        Debug (1,1) logical
    end
    
    properties (Access = private, Constant)
        TOKEN_REGEX = "\{\{(?![\{%#])\s*(.*?)\s*(?<![\}%#])\}\}|\{%\s*(.*?)\s*%\}|\{#\s*(.*?)\s*#\}"
    end
    
    methods
        function self = LCompiler(template, debug)
            arguments
                template (1,:) string
                debug (1,1) logical = false
            end
            
            self.Template = strjoin(template, newline);
            self.Debug = debug;
        end
        
        function root = compile(self)
            stack = {LRoot()};
            debug = "";
            
            for fragment = self.make_fragments()
                switch fragment.Type
                case LFRAGMENT_TYPE.BLOCK_END
                    assert(numel(stack) > 1, "Lobster:NestingError", "Too many {%%end%%} in template. Syntax tree:\n\n%s", debug);
                    stack(end) = [];
                    debug = debug + ")";
                case LFRAGMENT_TYPE.TEXT
                    if fragment.Text ~= ""
                        stack{end}.Children{end + 1} = LTextNode(fragment.Text);
                        debug = debug + " ";
                    end
                case LFRAGMENT_TYPE.VAR
                    stack{end}.Children{end + 1} = LVarNode(fragment.Text);
                    debug = debug + "_";
                case LFRAGMENT_TYPE.BLOCK_START
                    [type, rest] = strtok(fragment.Text, " ");
                    node = feval(regexprep(type, "^(\w)(\w+)$", "L${upper($1)}$2Node"), rest);
                    stack{end}.Children{end + 1} = node;
                    debug = debug + type;
                    if node.CreatesScope
                        stack{end + 1} = node; %#ok<AGROW>
                        debug = debug + "(";
                    end
                end
            end
            
            if not(isscalar(stack))
                error("Lobster:NestingError", "Missing {%%end%%} in template. Syntax tree:\n\n%s", debug);
            end
            root = stack{1};
        end
    end
    
    methods (Access = private)
        function fragments = make_fragments(self)
            [vars, text] = regexp(self.Template, self.TOKEN_REGEX, "match", "split");
            vars = arrayfun(@create_fragment, vars);
            text = arrayfun(@(t) LFragment(LFRAGMENT_TYPE.TEXT, t), text);
            fragments = [text(1), reshape([vars; text(2:end)], 1, [])];
            
            function fragment = create_fragment(raw)
                if startsWith(raw, "{{")
                    type = LFRAGMENT_TYPE.VAR;
                elseif startsWith(raw, "{#")
                    type = LFRAGMENT_TYPE.COMMENT;
                elseif startsWith(raw, regexpPattern("{%\s*end"))
                    type = LFRAGMENT_TYPE.BLOCK_END;
                elseif startsWith(raw, "{%")
                    type = LFRAGMENT_TYPE.BLOCK_START;
                end
                fragment = LFragment(type, regexprep(raw, self.TOKEN_REGEX, "$1"));
            end
        end
    end
end

