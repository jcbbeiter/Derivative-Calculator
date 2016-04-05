function result = isDigit(str)
% A simple function that returns true if the passed character is a digit
% If a string of multiple characters is passed, only tests the first one
result = any(str == ['1','2','3','4','5','6','7','8','9','0']);