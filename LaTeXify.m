function output = LaTeXify(expression)

syms x
expression = sym(expression);
expression = latex(expression);
output = ['$$ f''(x) = ',char(expression),' $$'];
