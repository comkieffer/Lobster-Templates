classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.ProjectFixture(fileparts(fileparts(mfilename("fullpath")))) ...
        }) SwitchCaseTests < matlab.unittest.TestCase

    methods (Test)
        function it_renders_numerical_switch(test)
            template = LTemplate("{% switch a %}{% case 1 %}A{% case 2 %}B{% end %}");
            test.verifyEqual(template.render(struct("a", 1)), "A");
            test.verifyEqual(template.render(struct("a", 2)), "B");
        end

        function it_renders_string_switch_with_otherwise(test)
            template = LTemplate("{% switch a %}{% case ""A"" %}A{% case ""B"" %}B{% otherwise %}C{% end %}");
            test.verifyEqual(template.render(struct("a", "A")), "A");
            test.verifyEqual(template.render(struct("a", "B")), "B");
            test.verifyEqual(template.render(struct("a", "C")), "C");
        end

        function it_fails_to_build_empty_switch(test)
            test.verifyError(@() LTemplate("{% switch a %}this will error{% end %}"), ...
                "Lobster:IncompleteSwitchCase");
        end
    end
end
