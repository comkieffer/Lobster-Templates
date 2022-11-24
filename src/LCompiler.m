classdef LCompiler < handle

    properties
        Template (1,1) string
        Debug (1,1) logical
    end

    properties (Access = private, Constant)
        TOKEN_REGEX = "\{\{(?![\{%#])\s*(.*?)\s*(?<![\}%#])\}\}|\{%-?\s*(.*?)\s*-?%\}|\{#\s*(.*?)\s*#\}"
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
            fragments = self.make_fragments();
            trimTrail = [fragments(2:end).TrimBefore, false];
            trimFront = [false, fragments(1:end-1).TrimAfter];

            for k = 1:numel(fragments)
                switch fragments(k).Type
                case LFRAGMENT_TYPE.BLOCK_END
                    assert(numel(stack) > 1, "Lobster:NestingError", "Too many {%%end%%} in template. Syntax tree:\n\n%s", debug);
                    end_scope(stack{end});
                    stack(end) = [];
                    debug = debug + ")";
                case LFRAGMENT_TYPE.TEXT
                    text = fragments(k).Text;
                    if trimFront(k)
                        text = strip(text, "left");
                    end
                    if trimTrail(k)
                        text = strip(text, "right");
                    end
                    if text ~= ""
                        stack{end}.Children{end + 1} = LTextNode(text);
                        debug = debug + " ";
                    end
                case LFRAGMENT_TYPE.VAR
                    stack{end}.Children{end + 1} = LVarNode(fragments(k).Text);
                    debug = debug + "_";
                case LFRAGMENT_TYPE.BLOCK_START
                    [type, rest] = strtok(fragments(k).Text, " ");
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
            text = arrayfun(@(t) LFragment(LFRAGMENT_TYPE.TEXT, t, false, false), text);
            fragments = [text(1), reshape([vars; text(2:end)], 1, [])];

            function fragment = create_fragment(raw)
                if startsWith(raw, "{{")
                    type = LFRAGMENT_TYPE.VAR;
                    trim = {false, false};
                elseif startsWith(raw, "{#")
                    type = LFRAGMENT_TYPE.COMMENT;
                    trim = {false, false};
                elseif startsWith(raw, regexpPattern("{%-?\s*end"))
                    type = LFRAGMENT_TYPE.BLOCK_END;
                    trim = {startsWith(raw, "{%-"), endsWith(raw, "-%}")};
                elseif startsWith(raw, "{%")
                    type = LFRAGMENT_TYPE.BLOCK_START;
                    trim = {startsWith(raw, "{%-"), endsWith(raw, "-%}")};
                end
                fragment = LFragment(type, regexprep(raw, self.TOKEN_REGEX, "$1"), trim{:});
            end
        end
    end
end
