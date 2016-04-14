function shift = isFunc(str, iChar)
% Takes a string and a starting index and checks if that index is the start
% of a function (sin, cos, tan, sec, csc, cot, log, sqrt, and ln)
% Returns 'shift,' the length in characters of the function
% Returns 0 if it isn't a function (so this can be used as a bool function)

% check for ln
if(strcmp(str(iChar:iChar+1),'ln')) % L
    shift = 2;
    return;
end

% check for pi
if(strcmp(str(iChar:iChar+1),'pi')) % p
    shift = 2;
    return;
end

% check for sqrt
if(strcmp(str(iChar:iChar+3),'sqrt')) % q
    shift = 4;
    return;
end

% all other functions have length 3
switch(str(iChar:iChar+2))
    case 'sin' % s
        shift = 3;
        return;
    case 'cos' % c
        shift = 3;
        return;
    case 'tan' % t
        shift = 3;
        return;
    case 'sec' % S
        shift = 3;
        return;
    case 'csc' % C
        shift = 3;
        return;
    case 'cot' % T
        shift = 3;
        return;
    case 'log' % g
        shift = 3;
        return;
    otherwise
        shift = 0;
        return;
end