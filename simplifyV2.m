function strOut = simplifyV2(str)
% simplifies an expression returned by prep.m and derive.m by evaluating
% simple mathematical equations found in the expression, removing indentity
% statements, removing unnecessary parentheses, and changing function names
% back to readable form
% author: Sam Berning
% version: 2.0

%% very specific thing we couldn't figure out otherwise

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

%% solves simple mathematical expressions
% 'simple mathematical expressions' in this context is defined as anything
% that is only composed of numbers and operators and can be easily
% evaluated by doing a simple operation

complete = false;   % whether or not this process is complete
lvl = 0;

while ~complete
    pars = strfind(str,char(minchar + lvl));
    nxtpars = strfind(str,char(minchar + lvl + 1));
    if isempty(pars) && isempty(nxtpars)
        complete = true;
        continue;
    else
        jmax = length(pars)/2;
        for j = 1:jmax
            start = pars(2*j-1) + 1;
            stop = pars(2*j) - 1;
            if isSimple(str(start:stop))
                str = [str(1:start-2), evalString(str(start:stop)),...
                    str(stop+2:end)];
                break;
            elseif j < jmax
                continue;
            else
                break;
            end
        end
    end
    lvl = lvl + 1;
end

%% removes identity statements
% identity statements such as +0, *1, and ^1 clutter up the expression
% unnecessarily. this portion of code removes them

str = strrep(str,'*1','');
str = strrep(str,'1*','');
str = strrep(str,'^1','');
str = strrep(str,'+0','');
str = strrep(str,'0+','');
str = strrep(str,'0-','');
str = strrep(str,'-0','');

%% removes unnecessary parentheses

complete = false;

for j = 0:lvl
    pars = strfind(str,char(minchar+j));
    for i = 1:length(pars)/2
        if pars(2*i-1) == 1
            str(pars(2*i-1)) = '!';
            str(pars(2*i)) = '!';
        elseif pars(2*i) - pars(2*i-1) < 3
            str(pars(2*i-1)) = '!';
            str(pars(2*i)) = '!';
        elseif any(str(pars(2*i-1):pars(2*i)) == '/')
            continue;
        elseif str(pars(2*i-1)-1) == '+'
            str(pars(2*i-1)) = '!';
            str(pars(2*i)) = '!';
        elseif any(str(pars(2*i-1):pars(2*i)) == '+')
            continue;
        elseif any(str(pars(2*i-1):pars(2*i)) == '-')
            continue;
        elseif any(str(pars(2*i-1)-1) == '*-')
            str(pars(2*i-1)) = '!';
            str(pars(2*i)) = '!';
        end
    end
end

%% turns characters back into parentheses

complete = false;
lvl = 0;

while ~complete
    pars = strfind(str,char(minchar + lvl));
    nxtpars = strfind(str,char(minchar + lvl + 1));
    if isempty(pars) && isempty(nxtpars)
        complete = true;
        continue;
    else
        for i = 1:(length(pars)/2)
            start = pars(2*i - 1);
            stop = pars(2*i);
            str(start) = '(';
            str(stop) = ')';
        end
    end
    lvl = lvl + 1;
end
str = strrep(str,'[','(');
str = strrep(str,']',')');
str = strrep(str,'!','');

%% evaluates any unevaluated expressions

ops = '*+-';
stilldigit = true;

for i = 1:length(ops)
    for j = 1:length(str)
        if strcmp(str(j),ops(i))
            if isDigit(str(j-1)) && isDigit(str(j+1))
                firstnum = j-1;
                secndnum = j+1;
                for k = 2:j
                    if j-k <= 0
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
                newExp = evalString(str(firstnum:secndnum));
                str = [str(1:firstnum-1),...
                    blanks(((secndnum+1)-(firstnum-1))-length(newExp)),...
                    newExp, str(secndnum+1:end)];
            end
        end
    end
    str = strrep(str,' ','');
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