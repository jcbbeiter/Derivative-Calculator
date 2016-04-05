function strOut = prep(str)
% Takes a string polynomial and prepares it for differentiation
% Returns the prepared string if valid
% If invalid, returns a '&' followed by an error message
% Removes spaces, adds * for implicit parenthetical multiplication, etc.

% adds blank space to make checking for trig functions not have to check
% bounds of string, will be removed later anyway
str = lower([str,'   ']);

% set of characters that are valid on their own (not as part of functions)
validChars = ['1','2','3','4','5','6','7','8','9','0',...
    '+','-','*','/','^','(',')','x','e',' '];

%% Scans for invalid characters
iChar = 1;
% use a while loop so we can control the incrementation
while(iChar < length(str))
    char = str(iChar);
    if(any(char == validChars)) % if char matches an element of validChars
        iChar = iChar + 1;
        continue;
    end
    
    shift = isFunc(str,iChar);
    
    % shift = 0 is the error case for isFunc, so would evaluate to false if
    % no function
    if(shift)
        if(str(iChar+shift) ~= '(')
            strOut = ['&Function ''',str(iChar:iChar+shift-1),...
                ''' must be followed by parentheses'];
            return;
        elseif(strcmp(str(iChar+shift:iChar+shift+1),'()'))
            strOut = ['&Function ''',str(iChar:iChar+shift-1),...
                ''' has no arguments'];
            return;
        end
        %Replaces function with one character
        func = str(iChar:iChar+shift-1);
        switch (func)
            case 'sin'
                funcChar = 's';
            case 'cos'
                funcChar = 'c';
            case 'tan'
                funcChar = 't';
            case 'sec'
                funcChar = 'S';
            case 'csc'
                funcChar = 'C';
            case 'cot'
                funcChar = 'T';
            case 'sqrt'
                funcChar = 'q';
            case 'ln'
                funcChar = 'L';
            case 'log'
                funcChar = 'g';
        end
        % Sets unique character
        str(iChar) = funcChar;
        % Deletes rest of function characters
        str = [str(1:iChar),str(iChar+shift:length(str))];
        iChar = iChar + 1;
        continue;        
    end
    
    %If reaches here, character is not valid
    strOut = ['&','Invalid character ''',char,''' detected at index ',...
        num2str(iChar)];
    return;
end

%% Cleans up string
% Inserts a * operator if there is implicit parenthetical multiplication
% i.e., an open paren, function character, or x preceded by a close paren or a digit
for iChar = 2:length(str)-1
    if((any(str(iChar) == ['(','x','s','c','t','S','C','T','g','L','q']))...
            && (str(iChar-1) == 'e'...
            || isDigit(str(iChar-1)) || str(iChar-1) == ')'))
        str = [str(1:iChar-1),'*',str(iChar:length(str))];
    end
end

% Combines pluses and minuses (e.g. x+(-2) or x-(-2)
% To delete, just replace character with a space to be trimmed later
for iChar = 1:length(str)-1
    if(str(iChar) == '+' && str(iChar+1) == '-')
        str(iChar) = ' ';
    elseif(str(iChar) == '-' && str(iChar+1) == '-')
        str(iChar) = ' ';
        str(iChar+1) = '+';
    end
end

% Trims spaces
iChar = 1;
while(iChar <= length(str))
    if(str(iChar) == ' ')
        str = [str(1:iChar-1),str(iChar+1:length(str))];
        iChar = iChar - 1;
    end
    iChar = iChar + 1;
end

%% Scans for invalid character combinations
% Operators next to operators, empty parentheses, multiple adjacent x's,
% operators before close parentheses or after open parentheses, e after x
for iChar = 2:length(str)
    char = str(iChar);
    prevChar = str(iChar-1);
    
    if(char == 'x' && prevChar == 'x')
        strOut = '&Must have an operator between adjacent variables.';
        return;
    end
    
    % Operator can be followed by the unary operator '-'
    if(isChar(char,['+','*','/','^']) && isChar(prevChar,['+','-','*','/','^']))
        strOut = ['&No argument between operators ''',char,''' and ''',...
            prevChar,'''.'];
        return;
    end
    
    if(char == ')' && prevChar == '(')
        strOut = '&Empty parentheses detected';
        return;
    end
    
    if(char == ')' && isChar(prevChar,['+','-','*','/','^']))
        strOut = '&An operator cannot be followed by close parentheses';
        return;
    end
    
    % Open parentheses can be followed by the unary operator '-'
    if(prevChar == '(' && isChar(char,['+','*','/','^']))
        strOut = '&Open parentheses cannot be followed by an operator';
        return;
    end;
    
    % 'xe' is invalid, but 'ex' is valid
    if(char == 'e' && prevChar == 'x')
        strOut = '&Operator required between ''x'' and ''e''';
        return;
    end;
    
end

%% Makes sure open and close parentheses counts match
parens = [0,0]; % vector to count parentheses
for iChar = 1:length(str)
    if(str(iChar) == '(')
        parens(1,1) = parens(1,1) + 1;
    elseif(str(iChar) == ')')
        parens(1,2) = parens(1,2) + 1;
    end
end

if(parens(1,1) > parens(1,2))
    strOut = '&Unmatched open parentheses';
    return;
elseif(parens(1,1) < parens(1,2))
    strOut = '&Unmatched close parentheses';
    return;
end

%% Returns successfully
strOut = str;
        