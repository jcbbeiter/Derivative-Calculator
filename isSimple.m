function bool = isSimple(func)
% returns whether something is a simple mathematical expression (SME) or not

simplechars = '0123456789*+-/';                 % char array of acceptable chars in an SME

for i = 1:length(func)                          % goes through the string and checks each char to make sure
    result(i) = any(func(i) == simplechars);    % all of them are acceptable chars
end
x = ones(1, length(func));                      % if all of the chars are acceptable, result should be an
if result == x                                  % array of ones and the expression is simple
    bool = true;
else
    bool = false;                               % otherwise, it is not an SME
end