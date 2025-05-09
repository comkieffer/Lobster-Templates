classdef LCompiler < handle

    properties
        Template (1,1) string
        DebugFile (1,1) string
    end

    properties (Access = private, Constant)
        TOKEN_REGEX = "\{\{(?![\{%#])\s*(.*?)\s*(?<![\}%#])\}\}|\{%(?!%)-?\s*(.*?)\s*-?(?<!%)%\}|\{#\s*(.*?)\s*#\}"
    end

    methods
        function self = LCompiler(template, debugFile)
            arguments
                template (1,:) string
                debugFile (1,1) string = ""
            end

            self.Template = strjoin(template, newline);
            self.DebugFile = debugFile;
        end

        function root = compile(self)
            stack = {LRoot([])};
            debugStack = "";
            fragments = self.make_fragments();
            trimTrail = [fragments(2:end).TrimBefore, false];
            trimFront = [false, fragments(1:end-1).TrimAfter];

            for k = 1:numel(fragments)
                switch fragments(k).Type
                case LFRAGMENT_TYPE.BLOCK_END
                    assert(numel(stack) > 1, "Lobster:NestingError", "Too many {%%end%%} in template. Syntax tree:\n\n%s", debugStack);
                    end_scope(stack{end});
                    stack(end) = [];
                    debugStack = debugStack + ")";
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
                        debugStack = debugStack + " ";
                    end
                case LFRAGMENT_TYPE.VAR
                    stack{end}.Children{end + 1} = LVarNode(fragments(k));
                    debugStack = debugStack + "_";
                case LFRAGMENT_TYPE.BLOCK_START
                    fragment = fragments(k);
                    [type, rest] = strtok(fragment.Text, " ");
                    fragment.Text = rest;
                    node = feval(regexprep(type, "^(\w)(\w+)$", "L${upper($1)}$2Node"), fragment);
                    stack{end}.Children{end + 1} = node;
                    debugStack = debugStack + type;
                    if node.CreatesScope
                        stack{end + 1} = node; %#ok<AGROW>
                        debugStack = debugStack + "(";
                    end
                end
            end

            if not(isscalar(stack))
                error("Lobster:NestingError", "Missing {%%end%%} in template. Syntax tree:\n\n%s", debugStack);
            end
            root = stack{1};
        end
    end

    methods (Access = private)
        function fragments = make_fragments(self)
            [vars, text, index] = regexp(self.Template, self.TOKEN_REGEX, "match", "split", "start");
            lines = arrayfun(@(k) sum(char(extractBefore(self.Template, k)) == newline), index) + 1;
            vars = arrayfun(@create_fragment, vars, lines);
            text = arrayfun(@(t) LFragment(LFRAGMENT_TYPE.TEXT, t, false, false, [], []), text);
            fragments = [text(1), reshape([vars; text(2:end)], 1, [])];

            function fragment = create_fragment(raw, line)
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
                fragment = LFragment(type, regexprep(raw, self.TOKEN_REGEX, "$1"), trim{:}, self.DebugFile, line);
            end
        end
    end
end
