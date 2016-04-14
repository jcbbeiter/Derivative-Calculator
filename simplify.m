function sfunc = simplify(func)
% both func and sfunc should be strings
% sfunc is a simplified but mathematically equivalent version of func
complete = false;
while ~complete
    fEnd = length(func);                                    % because func will be changing size as we
    for iS = 1:fEnd                                         % iterate, we need to save this value to test
                                                            % for completeness
        if strcmp(func(iS),'(')                             % we want to find single sets of parentheses b/c
            if singlepars(func(iS:end))                     % they more than likely contain an easily
                par1 = iS;                                  % simplifiable mathematical expression
                par2 = iS + strfind(func(iS+1:end),')');
                if isSimple(func(par1+1:par2(1)-1))         % still, it could contain a variable, so we must
                    h = evalString(func(par1+1:par2(1)-1)); % check to make sure it is a simple expression
                    if ~strcmp(h(1),'-') && ~any(h == '/')
                        func = [func(1:par1-1), h,...
                            func(par2(1)+1:end)];
                        break;                              % each time func changes, we break the for
                    else                                    % loop b/c otherwise the indexes in the for
                        func = [func(1:par1), h,...         % loop exceed the dimensions of func
                            func(par2(1):end)];
                        break;
                    end
                elseif par2(1)-par1 == 2 && ~any(func(iS-1) == 'sctSCTLgq')
                    func = [func(1:par1-1),...
                        func(par1+1:par2(1)-1),...
                        func(par2(1)+1:end)];
                    break;
                end
            end
        end
        if length(func) - iS > 4
            if strcmp(func(iS:iS+3),'*(1/')
                if strcmp(func(iS-1),func(iS+4))
                    func = [func(1:iS-2),'(1',func(iS+5:end)];
                    break;
                end
            end    
        end
        if iS < length(func)
            if strcmp(func(iS:iS+1),'1*') && ~isDigit(iS-1) % if there is multiplication by one, addition
                if length(func) - iS >= 2                   % by zero, or raising to the power of one,
                    func = [func(1:iS-1),func(iS+2:end)];   % we can dismiss those expressions as they are
                else                                        % identity expressions, so we should simply
                    func = func(1:iS-1);                    % omit them from the final function
                end
                break;
            elseif strcmp(func(iS:iS+1),'+0')
                if length(func) - iS >= 2
                    func = [func(1:iS-1),func(iS+2:end)];
                else
                    func = func(1:iS-1);
                end
                break;
            elseif strcmp(func(iS:iS+1),'^1') && ~isDigit(iS+2)
                if length(func) - iS >= 2
                    func = [func(1:iS-1),func(iS+2:end)];
                else
                    func = func(1:iS-1);
                end
                break;
            elseif strcmp(func(iS:iS+1),'*1') && ~isDigit(iS+2)
                if length(func) - iS >= 2
                    func = [func(1:iS-1),func(iS+2:end)];
                else
                    func = func(1:iS-1);
                end
                break;
            elseif strcmp(func(iS:iS+1),'0+') && ~isDigit(iS+2)
                if length(func) - iS >= 2
                    func = [func(1:iS-1),func(iS+2:end)];
                else
                    func = func(1:iS-1);
                end
                break;
            end
        end
    end
    if iS == fEnd
        complete = true;
    end
end
func = strrep(func, 's', 'sin');
func = strrep(func, 'c', 'cos');
func = strrep(func, 't', 'tan');
func = strrep(func, 'S', 'sec');
func = strrep(func, 'C', 'csc');
func = strrep(func, 'T', 'cot');
func = strrep(func, 'L', 'ln');
func = strrep(func, 'g', 'log');
func = strrep(func, 'q', 'sqrt');
sfunc = func;