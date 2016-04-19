function strOut = derive(str)
% Recursive function to differentiate mathematical expressions
% String should be processed with prep() before being passed to this
% function
% meaningless edit

%% Removes parentheses that surround entire expression
% Creates a vector to store how "deep" in parentheses each character is
levels = NaN(1,length(str));
level = 0; % instantaneous measurement
for iChar = 1:length(str)
    if(str(iChar) == '(')
        level = level + 1;
    elseif(str(iChar) == ')')
        level = level - 1;
    else
        levels(iChar) = level;
    end
end

% If expression starts and ends with parentheses, and the whole thing is
% inside them
if(isnan(levels(1)) && isnan(levels(length(str))) && min(levels) > 0)
    % Removes parentheses from beginning and end
    for iii = 1:min(levels)
        str = str(2:length(str)-1);
    end
    % and then recounts parenthetical layers
    levels = NaN(1,length(str));
    level = 0;
    for iChar = 1:length(str)
       if(str(iChar) == '(')
            level = level + 1;
       elseif(str(iChar) == ')')
            level = level - 1;
       else
            levels(iChar) = level;
       end
    end

end

%% Finds operators to look at
% Only operators that are not inside any parentheses are considered

% NaN is used here instead of zeros so that only the values that are set
% later on are searched with min()
ops = NaN(1,length(str));

% Searches operators of the string and records how many parentheses they
% are surrounded by to calculate precedence
for iChar = 1:length(str)
    if(any(str(iChar) == '+-*/^'))
        ops(iChar) = levels(iChar);
    end
end

% anonymous function for searching substrings for the independent variable
hasX = @(str) (any(str == 'x'));

% pos is a vector containing the index/indeces of the operators that aren't
% in parentheses
pos = find(ops == 0);

% creates an array opChars of the operators corresponding to the indices
% in pos
opChars = str(pos);

%% Base Cases and Functions - no operators of zero precedence
% If there are no operators that aren't in parentheses, there are three
% possibilities:
% 1) The expression is a constant, so the derivative is 0
% 2) The expression is a plain x (coefficients use a * operator), so the
% derivative is 1
% 3) The expression is a function (e.g. sin, log, sqrt), so use chain rule

if(isempty(opChars))
    if(~hasX(str)) % if no x in string
        strOut = '0';
        return;
    elseif(strcmp(str,'x')) % if string is just 'x'
        strOut = '1';
        return;
    end
    % If program reaches this point, then it must be a function such as sin
    % or cos
    funcChar = str(1);
    funcArg = str(2:length(str));
    % If there's no x inside the function, derivative is 0
    if(~hasX(funcArg))
        strOut = '0';
        return;
    end
    % Derives functions using chain rule
    switch funcChar
        case 's'
            strOut = ['(c',funcArg,'*',derive(funcArg),')'];
            return;
        case 'c'
            strOut = ['(-s',funcArg,'*',derive(funcArg),')'];
            return;
        case 't'
            strOut = ['((S',funcArg,')^2*',derive(funcArg),')'];
            return;
        case 'S'
            strOut = ['(S',funcArg,'*t',funcArg,'*',derive(funcArg),')'];
            return;
        case 'C'
            strOut = ['(-C',funcArg,'*T',funcArg,'*',derive(funcArg),')'];
            return;
        case 'T'
            strOut = ['(-(C',funcArg,')^2*',derive(funcArg),')'];
            return;
        case 'g'
            strOut = ['(',derive(funcArg),'/(l(10)*',funcArg,'))'];
            return;
        case 'q'
            strOut = ['(',derive(funcArg),'/q',funcArg,')'];
            return;
        case 'L'
            strOut = ['(',derive(funcArg),'/',funcArg,')'];
            return;
        otherwise
            disp('Error');
            strOut = 'error';
            return;
    end
end 

 %% Checks for '+' operator
 % The + and - operators come last in the order of operations, so an 
 % expression can always be safely broken up over them.
 % Finds any '+' operators in opChars, then dereferences them using pos to
 % find their index in the string
indices = pos(opChars == '+');

if(indices) % Runs if index is not blank, i.e., if there is a plus
   index = indices(1); % Only pays attention to the first index
   strOut = [derive(str(1:index-1)),'+',derive(str(index+1:length(str)))];
   return;
end
 
 %% Checks for '-' operator
 % The '-' operator is a little trickier: the same character is used for the
 % binary operator (subtraction) and the unary operator (negation)
 % We can tell that it is the unary operator if:
 % 1) It is the first character in the expression
 % or 2) it follows another operator 
 
  % Finds any '-' operators in opChars, then dereferences them using pos to
 % find their index in the string
 indices = pos(opChars == '-');
 index = 0;

 % Checks to see if any '-' are binary operators, not unary
for i = 1:length(indices)
    if(indices(i) == 1)
        continue; % moves on if the '-' is in the first position
    elseif(any(str(indices(i)-1) == ['*','/','^']))
        continue; % moves on if the '-' is preceded by an operator
    end
    index = indices(i); % if reaches this point, is binary operator
    break;              % stores index and stops for loop
end

% will only execute if for loop found something
if(index)
    strOut = [derive(str(1:index-1)),'-',derive(str(index+1:length(str)))];
    return;    
end

%% Checks for '*' operator
% The '*' operator comes next in order of precedence. There are four
% possibilities for this derivative:
% 1) Constant*Constant: 0
% 2) Constant*Variable_Expression: Constant*derive(Variable_Expression)
% 3) Variable_Expression*Constant: Constant*derive(variable_Expression)
% 4) Variable_Expression*Variable_Expression: Use product rule

 % Finds any '*' operators in opChars, then dereferences them using pos to
 % find their index in the string
indices = pos(opChars == '*');

if(indices) % Runs if index is not blank, i.e., if there is a *
   index = indices(1); % Only pays attention to the first index
   
   arg1 = str(1:index-1);
   arg2 = str(index+1:length(str));
   
   % Makes string (for switch statement) representing if each argument,
   % before and after the *, have an x in them: 00, 01, 10, or 11
   xStr = [num2str(hasX(arg1)),num2str(hasX(arg2))];
   
   switch xStr
       case '00'
           strOut = '0';
           return;
       case '01'
           strOut = ['(',arg1,'*',derive(arg2),')'];
           return;
       case '10'
           strOut = ['(',arg2,'*',derive(arg1),')'];
           return;
       case '11'
           strOut = ['(',arg1,'*',derive(arg2),'+',arg2,'*',derive(arg1),')'];
           return;
   end   
end

%% Checks for '/' operator
% The '/' operator comes next in order of precedence. There are four
% possibilities for this derivative:
% 1) Constant/Constant: 0
% 2) Constant/Variable_Expression: Constant*derive(Variable_Expression^-1)
% 3) Variable_Expression/Constant: derive(Variable_Expression)/Constant
% 4) Variable_Expression/Variable_Expression: Use quotient rule

% Finds any '/' operators in opChars, then dereferences them using pos to
 % find their index in the string
indices = pos(opChars == '/');

if(indices) % Runs if index is not blank, i.e., if there is a /
   index = indices(1); % Only pays attention to the first index
   
   num = str(1:index-1);
   denom = str(index+1:length(str));

   % Makes string (for switch statement) representing if the numerator
   % and denominator have an x in them: 00, 01, 10, or 11
   xStr = [num2str(hasX(num)),num2str(hasX(denom))];

    switch xStr
       case '00'
           strOut = '0';
           return;
       case '01'
           strOut = ['(',num,'*',derive(['(',denom,')^(-1)']),')'];
           return;
       case '10'
           strOut = ['(',derive(num),'/',denom,')'];
           return;
       case '11'
           strOut = ['((',denom,'*',derive(num),'-',num,'*',derive(denom),...
               ')/',denom,'^2)'];
           return;
    end   
end
   
%% Checks for '^' operator
% The '^' operator comes next in order of precedence. There are four
% possibilities for this derivative:
% 1) Constant^Constant: 0
% 2) Constant^Variable_Expression: ln(c)*c^x*derive(x)
% 3) Variable_Expression^Constant: Use power rule
% 4) Variable_Expression^Variable_Expression: c^x*derive(ln(c)*x)

% Finds any '^' operators in opChars, then dereferences them using pos to
 % find their index in the string
indices = pos(opChars == '^');

if(indices) % Runs if index is not blank, i.e., if there is a ^
   index = indices(1); % Only pays attention to the first index
   
   arg1 = str(1:index-1);
   arg2 = str(index+1:length(str));

   % Makes string (for switch statement) representing if the arguments
   % before/after the '^' have an x in them: 00, 01, 10, or 11
   xStr = [num2str(hasX(arg1)),num2str(hasX(arg2))];

    switch xStr
       case '00'
           strOut = '0';
           return;
       case '01'
           strOut = ['(','L(',arg1,')*',str,'*',derive(arg2),')'];
           return;
       case '10'
           strOut = ['(',arg2,'*',arg1,'^(',arg2,'-1))'];
           return;
       case '11'
           strOut = ['(',str,'*',derive(['L(',arg1,')*',arg2]),')'];
           return;
    end   
end

%% Should never reach here
% The program should never reach this point. If it does, something's gone
% wrong
strOut = '¯\_(?)_/¯';









