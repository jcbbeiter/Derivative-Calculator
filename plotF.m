function [] = plotF(handles,autoRange)
% Function to support DerivativeCalculatorTool
% handles all the plotting on the axes

%% Sets Parameters

% Gets domain from gui
xMin = str2num(handles.domainLowBox.String);
xMax = str2num(handles.domainHighBox.String);
Nx = 250; %number of x values
doLine = handles.xValueText.Value;

%% Creates and Evaluates Symbolic Functions
% creates symbolic variables - x, and the constants e and pi
syms x
syms e
e = exp(1);
syms p
p = pi;

% creates symbolic functions from the GUI strings
syms f(x)
syms g(x)
f(x) = handles.fText.String;
g(x) = handles.fPrimeText.String;

% Evaluates f and f prime. eval() is called on the result to evaluate any
% e's or pi's, and real() is called to ignore imaginary parts (for sqrts,
% etc)
xs = linspace(xMin,xMax,Nx);

% try/catch to catch for divide by zero error
try
fx = real(eval(f(xs)));
gx = real(eval(g(xs)));
catch
% divide by zero error only happens when there's a value exactly on the
% asymptote, so a not-so-great but functional fix is to shift everything by
% a very small amount (several times smaller than the x-step)
xs = xs + (xs(2)-xs(1))/100000;
fx = real(eval(f(xs)));
gx = real(eval(g(xs)));
end
% need to use eval() on the results of the expressions to evaluate any
% possible e's left over

%% Plots function(s)
% boolean string to test if we need to graph f and f'
doStr = ['',num2str(handles.functionCheckbox.Value),...
    num2str(handles.derivativeCheckbox.Value)];

switch doStr
    case '00' % nothing to graph - clear axes
        cla(handles.plotAxes);
        legend(handles.plotAxes,'hide');
        doLine = false;
    case '01' % graph only f'
        plot(handles.plotAxes,xs,gx,'r');
        xlabel(handles.plotAxes,'x');
        ylabel(handles.plotAxes,'y');
        if(handles.legendCheckbox.Value)
            legend(handles.plotAxes,'f''(x)','LOCATION','NORTHWEST');
        end
    case '10' % graph only f
        plot(handles.plotAxes,xs,fx,'b');
        xlabel(handles.plotAxes,'x');
        ylabel(handles.plotAxes,'y');
        if(handles.legendCheckbox.Value)
            legend(handles.plotAxes,'f(x)','LOCATION','NORTHWEST');
        end
    case '11' % graph both f and f'
        plot(handles.plotAxes,xs,fx,'b',xs,gx,'r');
        xlabel(handles.plotAxes,'x');
        ylabel(handles.plotAxes,'y');
        if(handles.legendCheckbox.Value)
            legend(handles.plotAxes,'f(x)','f''(x)','LOCATION','NORTHWEST');
        end
end
%% Sets Range
if(autoRange) % Automatically determines the range
    % high and low are two variables saved to the highest and lowest values of
    % the functions, respectively. They are extended slightly so
    % that the y axis can have a bit of space on the top and bottom of the
    % graphed functions
    high = max([fx,gx]);
    low = min([fx,gx]);

    % if the maximum and the minimum are the same (graphs are a flat line),
    % shifts one of the bounds to 0 for reference
    if(high == low)
        if(high > 0)
            low = 0;
        else
            high = 0;
        end
    end

    % If both bounds are zero, increases one so it can graph
    if(high == 0 && low == 0)
        high = .01;
    end

    % snaps to the x axis if reasonable
    if(min([fx,gx]) > 0 && low < 0)
        low = 0;
    end
    if(max([fx,gx]) < 0 && high < 0)
        high = 0;
    end

    % sets axes to determined y bounds
    axis(handles.plotAxes,[xMin xMax low high]);
    
    % sets display boxes to range values
    handles.rangeLowBox.String = num2str(low);
    handles.rangeLowText.String = num2str(low);
    handles.rangeHighText.String = num2str(high);
    handles.rangeHighBox.String = num2str(high);
else % user specified range
    low = str2num(handles.rangeLowBox.String);
    high = str2num(handles.rangeHighBox.String);
    axis(handles.plotAxes,[xMin xMax low high]);
end

%% Formats Plot
% hides the legend if it's not asked for
if(~handles.legendCheckbox.Value)
    legend(handles.plotAxes,'hide');
end

% displays grid if the checkbox is checked
if(handles.gridCheckbox.Value)
    grid(handles.plotAxes,'on');
else
    grid(handles.plotAxes,'off');
end

% displays x and y axes if the box is checked
if(handles.axesCheckbox.Value)
    xL = xlim(handles.plotAxes);
    yL = ylim(handles.plotAxes);
    line([0 0], yL,'Parent',handles.plotAxes,'Color','k');  %x-axis
    line(xL, [0 0],'Parent',handles.plotAxes,'Color','k');  %y-axis
end

% Plots vertical line to visualize found values, if doLine is true and the
% x value is within the domain of the graph
xValue = str2num(handles.xValueText.String);
if(doLine && (xValue > xMin) && (xValue < xMax))
    h = line([xValue xValue], ylim(handles.plotAxes),'Parent',handles.plotAxes,'Color','k');
    h.LineStyle = '--';
end
