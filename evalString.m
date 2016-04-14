function num = evalString(str)
% evaluates a simple mathematical expression in string form

plusses = strfind(str,'+');
minuses = strfind(str,'-');
times = strfind(str,'*');
divides = strfind(str,'/');
ops = [plusses, minuses, times, divides];

if isempty(plusses) && isempty(minuses) && isempty(times) && isempty(divides)
    num = str;
    return;
else
    digits(1) = str2double(str(1:ops(1)-1));
    digits(2) = str2double(str(ops(1)+1:end));
    if isempty(minuses) && isempty(times) && isempty(divides)
        num = num2str(digits(1) + digits(2));
    elseif isempty(plusses) && isempty(times) && isempty(divides)
        num = num2str(digits(1) - digits(2));
    elseif isempty(plusses) && isempty(minuses) && isempty(divides)
        num = num2str(digits(1) * digits(2));
    else
        if mod(digits(1),digits(2)) == 0
            num = num2str(digits(1) / digits(2));
        else
            num = str;
        end
    end
end