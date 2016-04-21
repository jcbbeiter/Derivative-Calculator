function output = LaTeXify(expression)
%
%   Version 1.1, revision 1. Last edited 4/20/2016, 20:10
%   This is a much simpler version of the original LaTeXify function. This
%   one takes an expression as an input and converts it to a format that 
%   is readable by a LaTeX interpreter. 
%
%   Most of the code in the old one was replaced by the simplify function
%   that Sam wrote, so it's gone now.


%% Working Code

% Variables to keep track of

elements = 0;
iStart = 0;
iEnd = 0;
parent_depth = 0; % Level of parentheses

% Isolate elements of the expression

expression = strrep(expression,'+','+');
expression = strrep(expression,'-','-');
expression = strrep(expression,'*','');

% Determine number of elements to be addressed

for i = 1:length(expression)
    if expression(i) == '('
        iStart = i;
    elseif expression(i) == ')'
        iEnd = i;
    end
    
    if iStart*iEnd > 0
        for k = iStart:iEnd
            if strcmp(expression(k),'+') || strcmp(expression(k),'-') || strcmp(expression(k),'/')
                if expression(k) == '+'
                    expression(k) = char(190);
                elseif expression(k) == '-'
                    expression(k) = char(191);
                elseif expression(k) == '/'
                    expression(k) = char(192);
                end
                elements = elements + 1;
                eleArray{elements} = expression(iStart:iEnd);
                iStart = 0;
                iEnd = 0;
                found = true;
                break;
            else
                found = false;
            end
        end
        
        if ~found
            elements = elements + 1;
            expression(iStart) = ' ';
            expression(iEnd) = ' ';
            eleArray{elements} = char(expression(iStart:iEnd)); 
            iStart = 0;
            iEnd = 0;
        end
    end
end

[elements,operators] = strsplit(expression,{'+','-'},'CollapseDelimiters',true);

for iI = 1:length(elements)
    element = char(elements(iI));
    index = strfind(element, '/');
    if ~isempty(index)
        first_half = element(1:index(1)-1);
        second_half = element(index(1)+1:length(element));
        element_overwrite = ['\frac{' first_half '}{' second_half '}'];
        elements(iI) = cellstr(element_overwrite);
    else
        elements(iI) = elements(iI);
    end
end

string = '$$ ';

for i = 1:length(elements)-1
    string = [string, char(elements(i)), char(operators(i))];
end

string = [string, char(elements(length(elements))) '$$'];

for i = 1:length(string)
    if string(i) == char(190)
        string(i) = '+';
    elseif string(i) == char(191)
        string(i) = '-';
    elseif string(i) == char(192)
        string(i) = '/';
    end
end

output = string;

%% Failsafe Mechanism

% This runs to make sure that the string is formatted correctly to be
% interpreted by LaTeX. If it isn't, then it will replace the output with
% the one that is evaluated using MATLAB functions

% Scratch that. This failsafe mechanism will be available in the next
% patch.

