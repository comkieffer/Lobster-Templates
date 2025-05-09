classdef (SharedTestFixtures = { ...
            matlab.unittest.fixtures.ProjectFixture(fileparts(fileparts(mfilename("fullpath")))) ...
        }) ConditionalTests < matlab.unittest.TestCase

    methods (Test)
        function it_renders_if(test)
            template = LTemplate("{% if a %}A{% end %}");
            test.verifyEqual(template.render(struct("a", true)), "A");
            test.verifyEqual(template.render(struct("a", false)), "");
        end

        function it_renders_ifelse(test)
            template = LTemplate("{% if a %}A{% else %}B{% end %}");
            test.verifyEqual(template.render(struct("a", 1)), "A");
            test.verifyEqual(template.render(struct("a", 0)), "B");
        end

        function it_renders_elseif(test)
            template = LTemplate("{% if a %}A{% elseif b %}B{% else %}C{% end %}");
            test.verifyEqual(template.render(struct("a", 1, "b", 0)), "A");
            test.verifyEqual(template.render(struct("a", 0, "b", 1)), "B");
            test.verifyEqual(template.render(struct("a", 0, "b", 0)), "C");
        end
    end
end
