function strOut = addFuncs(str)
% Swaps the function names back in for the single characters 
% s -> sin, c -> cos, etc.

iChar = 1;

while(iChar < length(str)-1)
    % Current character represents a function
    if(any(str(iChar) == 'sctSCTLqg') && str(iChar+1) == '(')
        
        switch str(iChar)
            case 's'
                func = 'sin';
            case 'c'
                func = 'cos';
            case 't'
                func = 'tan';
            case 'S'
                func = 'sec';
            case 'C'
                func = 'csc';
            case 'T'
                func = 'cot';
            case 'L'
                func = 'ln';
            case 'q'
                func = 'sqrt';
            case 'g'
                func = 'log';
            otherwise
                func = 'ERROR';
        end
        % inserts function string
        str = [str(1:iChar-1),func,str(iChar+1:length(str))];
        iChar = iChar + length(func) - 1;
    end 
    iChar = iChar + 1;
end

strOut = str;