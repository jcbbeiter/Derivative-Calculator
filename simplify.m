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

complete = false;   % whether or not this process is complete
lvl = 0;            % level of the parentheses, this number is added to minchar to choose which char will
% replace this level of parentheses

while ~complete
    pars = strfind(str,char(minchar + lvl));        % finds all of the parentheses on this level
    nxtpars = strfind(str,char(minchar + lvl + 1)); % finds all of the parentheses on the next level
    if isempty(pars) && isempty(nxtpars)            % if there are none of either we must be done with this
        complete = true;                            % much simplification, at least
        continue;
    else                                            % otherwise, we need to do some stuff
        jmax = length(pars)/2;                      % every odd parenthesis on this level will be an open
        for j = 1:jmax                              % parenthesis, so we can jump through all of the
            start = pars(2*j-1) + 1;                % parentheses on this level by using 2*j-1 to get all of
            stop = pars(2*j) - 1;                   % the odd-numbered parentheses and 2*j to get the evens
            if isSimple(str(start:stop))            % tests to see if the string is evaluable mathematically
                str = [str(1:start-2), evalString(str(start:stop)),...  % (that is, it contains only numbers)
                    str(stop+2:end)];                                   % if it is, it evaluates it
                break;                              % since the string is a different length than it was at
                                                    % the beginning of the for loop, we need to break the
                                                    % for loop and take the length of the new string to continue
            end
        end
    end
    if isempty(j) || j >= jmax                      % if either the counter on the for loop is empty or if
        lvl = lvl + 1;                              % it is at its maximum value, we move on to the next
                                                    % level of parentheses
    end
end

%% removes unnecessary parentheses

for j = 0:lvl
    pars = strfind(str,char(minchar+j));
    for i = 1:length(pars)/2
        if pars(2*i-1) == 1
            if any(str(pars(2*i-1):pars(2*i)) == '/') && ~(pars(2*i) == length(str) || any(str(pars(2*i)+1) == '*+-/'))
                continue;
            else
                str(pars(2*i-1)) = '!';
                str(pars(2*i)) = '!';
            end
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

for l = 0:lvl
    pars = strfind(str,char(minchar+l));
    for i = 1:(length(pars)/2)
        start = pars(2*i - 1);
        stop = pars(2*i);
        str(start) = '(';
        str(stop) = ')';
    end
end
str = strrep(str,'[','(');
str = strrep(str,']',')');
str = strrep(str,'!','');

%% evaluates any unevaluated expressions

ops = '*/+-';

for i = 1:length(ops)
    for j = 1:length(str)
        if strcmp(str(j),ops(i))
            if isDigit(str(j-1)) && isDigit(str(j+1))
                firstnum = j-1;
                secndnum = j+1;
                for k = 2:j
                    if j-k <= 0 && j+k > length(str)
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
                newExp = evalString(str(firstnum:secndnum));
                str = [str(1:firstnum-1),...
                    blanks(((secndnum+1)-(firstnum-1))-length(newExp)),...
                    newExp, str(secndnum+1:end)];
            end
        end
    end
    str = strrep(str,' ','');
end

%% handles *0

tzs = strfind(str,'*0');

if ~isempty(tzs)
    plusses = strfind(str,'+');
    minuses = strfind(str,'-');
    pms = sort([plusses, minuses]);
    if isempty(pms)
        str = '0';
    else
        for j = 1:length(tzs)
            for k = 1:length(pms)
                if tzs(j) < pms(k) && k == 1
                    str = ['0',str(pms(k):end)];
                elseif tzs(j) > pms(k) && k == length(pms)
                    str = [str(1:pms(k)),'0'];
                elseif k ~= 1 && k ~= length(pms) && tzs(j) > pms(k-1) && tzs(j) < pms(k)
                    str = [str(1:pms(k-1)),'0',str(pms(k):end)];
                end
            end
        end
    end
end
                    
                

%% removes identity statements
% identity statements such as +0, *1, and ^1 clutter up the expression
% unnecessarily. this portion of code removes them

for j = 1:2
    str = strrep(str,'*1','');
    str = strrep(str,'1*','');
    str = strrep(str,'^1','');
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