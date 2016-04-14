function bool = singlepars(func)
% tests whether a given open parentheses is the start of a single set of
% parentheses. useful for simplifying statements withing single parentheses

nxtopen = strfind(func(2:end),'(');     % the only strings passed to this function should be strings that
nxtclose = strfind(func(2:end), ')');   % begin with a '('
if isempty(nxtopen)
    bool = true;                        % we should never see an open parenthesis with no closed parenthesis
elseif nxtclose(1) < nxtopen(1)         % if the next parenthesis in the function is an open parenthesis,
    bool = true;                        % the starting open parenthesis must not be the start of a single
else                                    % set of parentheses
    bool = false;
end