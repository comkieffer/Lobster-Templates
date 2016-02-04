
# The Lobster Template Engine

The Lobster Template, LTemplate for short, is a simple template engine for MATLAB. It provides variable expansion, conditionals, and for loops. 

## Getting Started 

Download LTemplate and place it on your MATLAB path. 

You can now render your first template: 

    >> tpl = LTemplate('Hello {{ name }}!');
    >> context.name = 'Mark';
    >> tpl.render()
    ans = Hello Mark!

LTemplate also accepts cellarrays of strings. Each string in the cellarray will correspond to a new line in the output: 

    >> tpl = LTemplate({'Hello {{ name }}!', 'It''s a beautiful day.'});
    >> context.name = 'Mark';
    >> tpl.render()
    ans = 
    Hello Mark!    
    It's a beautiful day.

You can also load a template from a file:

    >> tpl = LTemplate.load('template.tpl');

The context variable is a struct that contains any additional data that the template might need. 

## Variable blocks

To print the value of a variable in your template insert a `{{ varname }}` block into your template and to add the variable to the context object. 
    
    >> LTemplate('{{ myvar }}').render(struct('myvar', 'Hello World!'))
    ans = 
    Hello World!

Internally the template renderer will `eval` the content of the variable block so you can perform indexing operations on the variable or even access a value in a `containers.Map`. You can also use this to call functions but to aid readability I encourage you to use a `call` block. 

    >> LTemplate('{{ myarray(3:5) }}').render(struct('myarray', 1:10))
    ans = 
    3 4 5

    >> context.mymap = containers.Map('something', 101);
    >> LTemplate('{{ mymap(''something'') }}').render(context)
    ans = 
    101

## If statements

The syntax for conditional statements is: 
    
    {% if something %}
        Do stuff here 
    {% else %}
        Do something else
    {% end %}

You can also do this on a single line: 

    {% if something %}Do stuff{% else %}Do something else{% end %}

Or skip the `{% else %}` block entirely ! The condtional in the if statement can be any valid piece of MATLAB code. You can for example write: 

    {% if length(1:5) > 3 && some_function() %}Do stuff{% end %}

`elseif` statements are curently not supported.

## For loops

A simple for loop is written:

    {% for k in 1:10 %}{{ k }}, {% end %}

This defines a variable called `k` that will only be available inside the for-loop. At every iteration of the loop this variable will be assigned the next value in the collection the loop is iterating over. 

The collection can be a cellarray:

    {% for k in num2cell(1:10) %}{{ k }}, {% end %}

In this case `k` will contain the actual contents of the cell. Not the cell object. 

You can also iterate over items in a struct. 

    >> s(1).name = 'Mark';
    >> s(2).name = 'Toby';
    >> s(3).name = 'Jennifer';
    >> context.people = s;
    >> LTemplate('{% for p in people %}{{ p.name }}, {% end %}').render(context)
    ans = Mark, Toby, Jennifer, 

It even works with map objects ?

## Call blocks

Sometimes instead of simply reading a variable you want to call a function in your template. You could use a variable block: 

    {{ my_function(my_variable) }}

But this could also be an array or map access. To make your intent clear use a `call` block: 

    {% call my_function(my_variable) %}

The major difference between call blocks and variable expansions is that the call block will not try to convert the output to a string. You must do it manually.


## Printing a litteral '{'

In most cases you should be able to print '{' just fine. It only becomes a problem if you need to do something like this : 

    >> tpl = LTemplate('\definecolor{{{color}}}').render(struct('color', 'mycolor'))

This will produce an error because the template engine will look for the variable '{color}'. To get around this we ca use the litteral '{': '{#'

    >> tpl = LTemplate('\definecolor{#{{color}}#}').render(struct('color', 'mycolor'))
    ans = 
    \definecolor{mycolor}

