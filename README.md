# The Lobster Template Engine

The Lobster Template, LTemplate for short, is a simple template engine for MATLAB. It provides variable expansion, conditionals, and for loops.

## Getting Started

Download LTemplate and place it on your MATLAB path.

You can now render your first template:

    >>> tpl = LTemplate('Hello {{ name }}!');
    >>> context.name = 'Mark';
    >>> tpl.render()
    ans =
        'Hello Mark!'

LTemplate also accepts cellarrays of strings. Each string in the cellarray will correspond to a new line in the output:

    >>> tpl = LTemplate({'Hello {{ name }}!', 'It''s a beautiful day.'});
    >>> context.name = 'Mark';
    >>> tpl.render()
    ans =
        'Hello Mark!
        It's a beautiful day.'

You can also load a template from a file:

    >>> tpl = LTemplate.load('template.tpl');

The context variable is a struct that contains any additional data that the template might need.

## Variable blocks

To print the value of a variable in your template insert a `{{ varname }}` block into your template and to add the variable to the context object.

    >>> LTemplate('{{ myvar }}').render(struct('myvar', 'Hello World!'))
    ans =
        Hello World!

Internally the template renderer will `eval` the content of the variable block so you can perform indexing operations on the variable or even access a value in a `containers.Map`. You can also use this to call functions.

    >>> LTemplate('{{ myarray(3:5) }}').render(struct('myarray', 1:10))
    ans =
        3 4 5

    >>> context.mymap = containers.Map('something', 101);
    >>> LTemplate('{{ mymap(''something'') }}').render(context)
    ans =
        101

## If statements

The syntax for conditional statements is:

    {% if something %}
        Do stuff here
    {% elseif statement %}
        Do something elseif
    {% else %}
        Do something else
    {% end %}

You can also do this on a single line:

    {% if something %}Do stuff{% else %}Do something else{% end %}

Or skip the `{% else %}` block entirely ! The condtional in the if statement can be any valid piece of MATLAB code. You can for example write:

    {% if length(1:5) > 3 && some_function() %}Do stuff{% end %}

## Switch Cases

The syntax for switch case statements is:

    {% switch value %}
    {% case 'A' %}
        Matched A
    {% case {'B', 'C'} %}
        Matched {{value}}
    {% otherwise %}
        Did not match
    {% end %}

The `{% otherwise %}` block is optional.

## For loops

A simple for loop is written:

    {% for k = 1:10 %}{{ k }}, {% end %}

This defines a variable called `k` that will only be available inside the for-loop. At every iteration of the loop this variable will be assigned the next value in the collection the loop is iterating over.

The collection can be a cellarray:

    {% for k = num2cell(1:10) %}{{ k }}, {% end %}

In this case `k` will contain the actual contents of the cell. Not the cell object.

You can also iterate over items in a struct.

    >>> s(1).name = 'Mark';
    >>> s(2).name = 'Toby';
    >>> s(3).name = 'Jennifer';
    >>> context.people = s;
    >>> LTemplate('{% for p = people %}{{ p.name }}, {% end %}').render(context)
    ans =
        'Mark, Toby, Jennifer,'

To iterate struct fields, iterate over `fieldnames(struct)`:

    >>> context.contact = struct('name', 'Mark', 'address', 'Foo St.');
    >>> LTemplate([
    ...     '<dl>' ...
    ...         '{% for field = fieldnames(contact) %}' ...
    ...             '<dt>{{field}}</dt>' ...
    ...             '<dd>{{contact.(field)}}</dd>' ...
    ...         '{% end %}' ...
    ...     '</dl>' ...
    ... ]).render(context)
    ans =
        '<dl><dt>name</dt><dd>Mark</dd><dt>address</dt><dd>Foo St.</dd></dl>'

## File Includes

To include sub-templates, use the include node:

    {% include "sub.tpl" %}

The include node is capable of rendering any text file accessible on the MATLAB path
as a jinja template. File endings can be used as you like. MATLAB will search for
the file on the search path and insert the first one found. The evaluation context
is the same as the current context where the node was placed.

The argument for the file name is dynamic, so you can assemble file names to include.
WARNING: If a template file is not found, the include node will render an empty string.
There will be no error or warning if the file is not found.

    {% include "customizations_for_" + getenv("USER") + ".tpl" %}

File templates are cached to speed up including many sub-templates. To clear the cache, run:

    >>> clear LFileTemplate

## Modifying the Context

To set temporary variables in the context, use either `let` or `with`:

    {% let temp = tempname() %}
        cd {{temp}}
        # ...
        cd ..
        rm -rf {{temp}}
    {% end %}

    {% with temp = tempname() %}
        cd {{temp}}
        # ...
        cd ..
        rm -rf {{temp}}
    {% end %}

This node is a scoped node, so make sure to place an `{% end %}` node where needed.

## Whitespace Control

This template engine also support a simplified feature set of the original Jinja whitespace control.
By adding a minus character to either end of a block definition, the whitespace before or after
the block will be removed:

    {%- if condition %}
        Content without trailing whitespace
    {%- else -%}
        Content without leading or trailing whitespace
    {%- end %}
