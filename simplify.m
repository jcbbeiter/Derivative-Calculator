function strOut = simplify(str)
% simplifies an expression returned by prep.m and derive.m by evaluating
% simple mathematical equations found in the expression, removing indentity
% statements, removing unnecessary parentheses, and changing function names
% back to readable form
% author: Sam Berning
% version: 2.0

%% replaces x/x with 1
% this is an easy simplification to implement, so we just take care of it
% at the beginning.

str = strrep(str,'x*(1/(x))','1');

%% replace parentheses with other characters
% parentheses are a valuable tool for simplification because they give us a
% really good idea of the architecture of the mathematical expression. here
% we are replacing the parentheses in the expression with ASCII chars based
% on their level in the expression. This allows the computer to more easily
% understand what each parenthesis means

minchar = 161; % this is the 'safe range' of ASCII chars, the chars that would not otherwise be used in
maxchar = 255; % the expression
lvl = 0;       % level of the parentheses, this number is added to minchar to choose which char will
% replace this level of parentheses
complete = false;    % whether or not this process is complete
funcs = 'sctSCTLgq'; % the characters that represent functions (like sin and ln) after prep has run

while ~complete
    for i = 1:length(str)
        if strcmp(str(i),'(')
            nxtopen = strfind(str(i+1:length(str)),'(');  % finds the next open parentheses
            nxtclose = strfind(str(i+1:length(str)),')'); % finds the next closed parentheses
            if isempty(nxtopen)
                if (i-1) > 0 && any(str(i-1) == funcs)    % replaces parentheses used to denote functions
                    str(i) = '[';                         % with square brackets so they will be treated
                    str(i + nxtclose(1)) = ']';           % differently
                else
                    str(i) = char(minchar + lvl);               % changes parentheses to the ASCII char
                    str(i + nxtclose(1)) = char(minchar + lvl); % corresponding to the current level
                end
            elseif nxtopen(1) < nxtclose(1) % if next open is closer than next closed, we move on for now
                continue;
            elseif (i-1) > 0 && any(str(i-1) == funcs)    % replaces parentheses used to denote functions
                str(i) = '[';                             % with square brackets so they will be treated
                str(i + nxtclose(1)) = ']';               % differently
            elseif (i-1) > 0 && str(i-1) == '^'           % replaces parentheses around exponents with curly
                str(i) = '{';                             % braces so they will be treated differently as well
                str(i + nxtclose(1)) = '}';               % this is for latexify, mainly
            else
                str(i) = char(minchar + lvl);               % changes parentheses to the ASCII char
                str(i + nxtclose(1)) = char(minchar + lvl); % corresponding to the current level
            end
        end
    end
    nxtopen = strfind(str,'('); % to check for completeness, we see if there are any parentheses left.
    if isempty(nxtopen)         % because we always change them in pairs and prep and derive ensure that
        complete = true;        % every parenthesis has a partner, we only need to check for either open
    else                        % or closed parentheses, not both
        lvl = lvl + 1;          % if it is complete, we exit this while loop. otherwise, we just increase
    end                         % the level of the parentheses
end

%% solves simple mathematical expressions within parentheses
% 'simple mathematical expressions' in this context is defined as anything
% that is only composed of numbers and operators and can be easily
% evaluated by doing a simple operation

for i = 0:lvl
    pars = strfind(str,char(minchar+i));        % finds all of the parentheses on this level
    jmax = length(pars)/2;                      % every odd parenthesis on this level will be an open
    for j = 1:jmax                              % parenthesis, so we can jump through all of the
        start = pars(2*j-1) + 1;                % parentheses on this level by using 2*j-1 to get all of
        stop = pars(2*j) - 1;                   % the odd-numbered parentheses and 2*j to get the evens
        if isSimple(str(start:stop))            % tests to see if the string is easily evaluable mathematically
            str = [str(1:start-2), evalString(str(start:stop)),...  % (that is, it contains only numbers)
                str(stop+2:end)];                                   % if it is, it evaluates it
        end
    end
end

%% removes unnecessary parentheses
% derive.m outputs expressions that are absolutely riddled with
% parentheses. here we try to make sense of that.

for j = 0:lvl                               % max level of parentheses is stored in lvl, so we can now use a for loop
    pars = strfind(str,char(minchar+j));    % this finds all of the parentheses on this level
    for i = 1:length(pars)/2                % then we can easily index through pairs of parentheses by using a for loop
        if pars(2*i-1) == 1                 % and finding all of the odd- and even- numbered parentheses
                                            % (odds are open parentheses, evens are closed parentheses)
            if any(str(pars(2*i-1):pars(2*i)) == '/') && ~(pars(2*i) == length(str) || any(str(pars(2*i)+1) == '*+-/'))
                continue;                   % checks to see if there is a division operation going on. if there is,
                                            % and if it is not the only expression, we keep the parentheses
            else
                str(pars(2*i-1)) = '!';     % if it is the only expression, though, we get rid of the parentheses
                str(pars(2*i)) = '!';       % notice we actually replace the parentheses with exclamation points.
                                            % if we didn't do this, the string would change length on each iteration
                                            % and we would have another problem. the code removes the exclamation
                                            % points later. 
            end
        elseif pars(2*i) - pars(2*i-1) < 3  % if there is only one character between the two parentheses, we get rid
            str(pars(2*i-1)) = '!';         % of the parentheses
            str(pars(2*i)) = '!';
        elseif any(str(pars(2*i-1):pars(2*i)) == '/') % if there is a division operation inside, we
            continue;                                 % keep the parentheses
        elseif str(pars(2*i-1)-1) == '+'                % otherwise if it comes after a plus, we get rid of the
            str(pars(2*i-1)) = '!';                     % parentheses
            str(pars(2*i)) = '!';
        elseif any(str(pars(2*i-1):pars(2*i)) == '+')   % if it's anything besides a plus, however, and there is a plus
            continue;                                   % or minus inside, we keep the parentheses in case it is a 
        elseif any(str(pars(2*i-1):pars(2*i)) == '-')   % times or subtraction operation
            continue;
        elseif strcmp(str(pars(2*i-1)-1),'/')           % if the parentheses come after a division operation, 
            continue;                                   % we keep the parentheses
        elseif strcmp(str(pars(2*i)+1),'^')             % if the parentheses are raised to an exponent, we also
            continue;                                   % keep the parentheses
        else
            str(pars(2*i-1)) = '!';                     % otherwise we pitch them
            str(pars(2*i)) = '!';
        end
    end
end

%% turns characters back into parentheses
% in order to help the user read this string, we need to make our weird
% characters back into parentheses and delete all of the exclamation
% points.

for l = 0:lvl                               % goes through all levels of parentheses
    pars = strfind(str,char(minchar+l));    % finds the parentheses on that level
    for i = 1:(length(pars)/2)
        start = pars(2*i - 1);              % goes through all of the odds and evens
        stop = pars(2*i);
        str(start) = '(';                   % and changes odds to open parentheses
        str(stop) = ')';                    % and evens to closed parentheses
    end
end
str = strrep(str,'[','(');                  % finally, we replace square brackets with parentheses
str = strrep(str,']',')');
str = strrep(str,'!','');                   % and eliminate any exclamation points

%% evaluates any unevaluated expressions
% generally at this point there are some expressions such as 4*2*x that
% could easily be simplified to 8*x. This is what we do here.

ops = '*/+-';                           % sets up the proper order of operations

for i = 1:length(ops)                   % runs through each operation one at a time
    for j = 1:length(str)               % goes through the whole string trying to find the current operation
        if strcmp(str(j),ops(i))
            if ~(j == 1) && isDigit(str(j-1)) && isDigit(str(j+1))  % if the operation isn't the first char in the
                firstnum = j-1;                                     % string, and the char on either side is a digit
                secndnum = j+1;                                     % congrats! we can operate on it.
                for k = 2:j                             % reads forward and back to make sure that the multipliers are
                    if j-k <= 0 && j+k > length(str)    % not multi digit numbers
                        break;
                    elseif j-k <= 0
                        if isDigit(str(j+k))
                            secndnum = j+k;
                        end
                    elseif j+k > length(str)
                        if isDigit(str(j-k))
                            firstnum = j-k;
                        end
                    elseif isDigit(str(j-k)) && isDigit(str(j+k))
                        firstnum = j-k;
                        secndnum = j+k;
                    elseif isDigit(str(j-k))
                        firstnum = j-k;
                    elseif isDigit(str(j+k))
                        secndnum = j+k;
                    else
                        break;
                    end
                end
                newExp = evalString(str(firstnum:secndnum));                % then if it is evaluable, we evaluate it,
                str = [str(1:firstnum-1),...                                % making sure to add in an appropriate
                    blanks(((secndnum+1)-(firstnum-1))-length(newExp)),...  % number of spaces such that the string
                    newExp, str(secndnum+1:end)];                           % stays the same length
            end
        end
    end
    str = strrep(str,' ','');                                               % then we get rid of all of the spaces
end

%% handles *0, 0*, and 0/
% these strings nullify whole expressions, so we can scan to see how long
% they propogate. In general, they go until there is a term that is added
% or subtracted, though that's not how the scanning works

% runs while any '*0' is left in the string
while(any(strfind(str,'*0')))
pos = strfind(str,'*0');
pos = pos(length(pos));
start = pos-1;
while(true) % scans backwards for end of expression nullified
    if(start == 0)% exits at start of string
        start = 1;
        break;
    end
    % keep going if find any of these characters
    if(any(str(start)=='1234567890x*'))
        start = start-1;
        continue;
    % scan backwards to the matching open paren
    elseif(str(start) == ')')
        level = 1;
        while(level > 0)
            start = start-1;
            if(str(start) == ')')
                level = level + 1;
            elseif(str(start) == '(')
                level = level - 1;
            end
        end
        start = start-1;
        continue;
    else
        start = start+1; %move forward if character not valid
    end
    break;    
end
% removes scanned portion from string
str = [str(1:start-1),str(pos+1:length(str))];
end

% keeps running if any '0*' or '0/' are in the string
while(any(strfind(str,'0*'))|| any(strfind(str,'0/')))
pos = [strfind(str,'0*'),strfind(str,'0/')];
pos = pos(length(pos));
ending = pos+1;
while(true)
    if(ending == length(str)+1) % ends selection if at end of string
        ending = length(str);
        break;
    end
    % continues past any of these characters
    if(any(str(ending)=='1234567890x*/')) 
        ending = ending+1;
        continue;
    % scan backwards to the matching close paren
    elseif(str(ending) == '(')
        level = 1;
        while(level > 0)
            ending = ending+1;
            if(str(ending) == '(')
                level = level + 1;
            elseif(str(ending) == ')')
                level = level - 1;
            end
        end
        ending = ending+1;
        continue;
    else
        %unsuccessful, so goes back one
        ending = ending-1; 
    end
    break;    
end
% removes scanned selection from string
str = [str(1:pos),str(ending+1:length(str))];
end

%% removes identity statements
% identity statements such as +0, *1, and ^1 clutter up the expression
% unnecessarily. this portion of code removes them with a series of simple
% strrep statements. It runs twice in case evaluating one identity
% statement brings about another

for j = 1:2
    str = strrep(str,'*1','');
    str = strrep(str,'1*','');
    str = strrep(str,'^{1}','');   % note that this is in brackets. this is to make latexify easier for Ben.
    str = strrep(str,'+0','');
    str = strrep(str,'0+','');
    str = strrep(str,'0-','-');
    str = strrep(str,'-0','');
end

%% makes function names readable
% prep.m and derive.m use one letter to represent functions like sin, cos,
% ln, and square root. in order to make this readable to the user, we must
% change them back to their normal forms. luckily, this is very easy - it
% is simply a series of 'strrep' statements

str = strrep(str, 's', 'sin');
str = strrep(str, 'c', 'cos');
str = strrep(str, 't', 'tan');
str = strrep(str, 'S', 'sec');
str = strrep(str, 'C', 'csc');
str = strrep(str, 'T', 'cot');
str = strrep(str, 'L', 'ln');
str = strrep(str, 'g', 'log');
str = strrep(str, 'q', 'sqrt');
str = strrep(str, 'p', 'pi');

%% returns simplified function

strOut = str;