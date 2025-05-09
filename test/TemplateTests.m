classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.ProjectFixture(fileparts(fileparts(mfilename("fullpath")))) ...
        }) TemplateTests < matlab.unittest.TestCase

    properties (TestParameter)
       falsy_value = {false, 0, '', []};
       truthy_value = {true, 1, -1, 2, 5, -7, 'true', 'stuff', [1, 1]};
    end

    methods (TestMethodSetup)
        function clear_cache(~)
            clear evalin_struct
        end
    end

    methods (Test)
        function test_empty(test)
            tpl = LTemplate("");
            test.assertEqual(tpl.render(), "");
        end

        function test_simple(test)
            tpl = LTemplate("This is a test string.");
            test.assertEqual(tpl.render(), "This is a test string.");
        end

        function test_int_var(test)
            context.var = 1;
            tpl = LTemplate("{{ var }}");
            test.assertEqual(tpl.render(context), "1");
        end

        function test_string_var(test)
            context.var = 'stuff';
            tpl = LTemplate("{{ var }}");
            test.assertEqual(tpl.render(context), "stuff");
        end

        function test_text_and_var(test)
            context.var = 1;
            tpl = LTemplate("This is {{ var }}");
            test.assertEqual(tpl.render(context), "This is 1");
        end

        function test_var_and_text(test)
            context.var = 1;
            tpl = LTemplate("{{ var }} is cool");
            test.assertEqual(tpl.render(context), "1 is cool");
        end

        function test_var_with_map_access(test)
            context.var = containers.Map('some_key', 'the value');
            tpl = LTemplate("{{ var('some_key') }} is cool");
            test.assertEqual(tpl.render(context), "the value is cool");
        end

        function test_undefined_var_error(test)
            tpl = LTemplate("{{ abc }} is cool");
            test.assertError(@() tpl.render(), "MATLAB:UndefinedFunction");
        end

        function test_if_true_with_no_context(test)
            tpl = LTemplate("{% if true %}You should see this{% endif %}");
            test.assertEqual(tpl.render(), "You should see this");
        end

        function test_if_false_with_no_context(test)
           tpl = LTemplate("{% if false %}You should not see this{% end %}");
           test.assertEqual(tpl.render(), "");
        end

        function test_if_true_with_else(test)
           tpl = LTemplate("{% if true %}Show this{% else %} Not this{% end %}");
           test.assertEqual(tpl.render(), "Show this");
        end

        function test_if_false_with_else(test)
           tpl = LTemplate("{% if false %}Show this{% else %}Not this{% end %}");
           test.assertEqual(tpl.render(), "Not this");
        end

        function test_if_with_conditional(test)
            tpl = LTemplate("{% if length(1:5) > 4 %}You should see this{% endif %}");
            test.assertEqual(tpl.render(), "You should see this");
        end

        function test_for_with_array(test)
            tpl = LTemplate("{% for k in 1:5 %}{{ k }} {% end %}");
            test.assertEqual(tpl.render(), "1 2 3 4 5 ");
        end

        function test_for_with_empty_array(test)
            tpl = LTemplate("{% for k in [] %}{{ k }} {% end %}");
            test.assertEqual(tpl.render(), "");
        end

        function test_for_with_cell(test)
            context.collection = num2cell(1:5);
            tpl = LTemplate("{% for k in 1:5 %}{{ k }} {% end %}");
            test.assertEqual(tpl.render(context), "1 2 3 4 5 ");
        end

        function test_for_with_empty_cell(test)
            context.collection = cell(0);
            tpl = LTemplate("{% for k in collection %}{{ k }} {% end %}");
            test.assertEqual(tpl.render(context), "");
        end

        function test_for_with_struct(test)
            context.collection = struct("val", num2cell(1:5));
            tpl = LTemplate("{% for k in collection %}{{ k.val }} {% end %}");
            test.assertEqual(tpl.render(context), "1 2 3 4 5 ");
        end

        function test_for_with_empty_struct(test)
            context.collection = struct([]);
            tpl = LTemplate("{% for k in collection %}{{ k.val }} {% end %}");
            test.assertEqual(tpl.render(context), "");
        end

        function test_let_replaces_temporarily(test)
            context.var = 42;
            tpl = LTemplate("{{ var }} {% let var = 43 %}{{ var }}{% end %} {{ var }}");
            test.assertEqual(tpl.render(context), "42 43 42");
        end

        function test_with_is_alias_for_let(test)
            context.var = 42;
            tpl = LTemplate("{{ var }} {% with var = 43 %}{{ var }}{% end %} {{ var }}");
            test.assertEqual(tpl.render(context), "42 43 42");
        end

        function test_error_node(test)
            tpl = LTemplate("{% error 'my:id', 'message' %}");
            test.assertError(@() tpl.render(), "my:id");
        end

        function test_trim_whitespace(test)
            test.assertEqual(LTemplate(" a {% if true %} b {% end %} c ").render(), " a  b  c ");
            test.assertEqual(LTemplate(" a {%- if true %} b {% end %} c ").render(), " a b  c ");
            test.assertEqual(LTemplate(" a {% if true -%} b {% end %} c ").render(), " a b  c ");
            test.assertEqual(LTemplate(" a {% if true %} b {%- end %} c ").render(), " a  b c ");
            test.assertEqual(LTemplate(" a {% if true %} b {% end -%} c ").render(), " a  b c ");
            test.assertEqual(LTemplate(" a {%- if true -%} b {% end %} c ").render(), " ab  c ");
            test.assertEqual(LTemplate(" a {%- if true -%} b {%- end -%} c ").render(), " abc ");
        end
    end

    methods (Test, ParameterCombination='sequential')
        function test_if_false_with_context(test, falsy_value)
            context.var = falsy_value;
            tpl = LTemplate("{% if var %}You should not see this{% end %}");
            test.assertEqual(tpl.render(context), "");
        end

        function test_if_true_with_context(test, truthy_value)
            context.var = truthy_value;
            tpl = LTemplate("{% if var %}You should see this{% endif %}");
            test.assertEqual(tpl.render(context), "You should see this");
        end
    end
end
