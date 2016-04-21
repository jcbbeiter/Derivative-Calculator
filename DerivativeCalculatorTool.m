function varargout = DerivativeCalculatorTool(varargin)
% DERIVATIVECALCULATORTOOL MATLAB code for DerivativeCalculatorTool.fig
%      DERIVATIVECALCULATORTOOL, by itself, creates a new DERIVATIVECALCULATORTOOL or raises the existing
%      singleton*.
%
%      H = DERIVATIVECALCULATORTOOL returns the handle to a new DERIVATIVECALCULATORTOOL or the handle to
%      the existing singleton*
%
%      DERIVATIVECALCULATORTOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DERIVATIVECALCULATORTOOL.M with the given input arguments.
%
%      DERIVATIVECALCULATORTOOL('Property','Value',...) creates a new DERIVATIVECALCULATORTOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DerivativeCalculatorTool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DerivativeCalculatorTool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DerivativeCalculatorTool

% Last Modified by GUIDE v2.5 20-Apr-2016 15:17:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DerivativeCalculatorTool_OpeningFcn, ...
                   'gui_OutputFcn',  @DerivativeCalculatorTool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DerivativeCalculatorTool is made visible.
function DerivativeCalculatorTool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DerivativeCalculatorTool (see VARARGIN)

% Choose default command line output for DerivativeCalculatorTool
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DerivativeCalculatorTool wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% makes both Axes objects blank
plot(handles.latexAxes,0,0);
cla(handles.latexAxes);
set(handles.latexAxes,'xticklabel',[])
set(handles.latexAxes,'yticklabel',[])
set(handles.latexAxes,'xtick',[])
set(handles.latexAxes,'ytick',[])

plot(handles.plotAxes,0,0);
cla(handles.plotAxes);
set(handles.plotAxes,'xticklabel',[])
set(handles.plotAxes,'yticklabel',[])
set(handles.plotAxes,'xtick',[])
set(handles.plotAxes,'ytick',[])


% --- Outputs from this function are returned to the command line.
function varargout = DerivativeCalculatorTool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function inputText_Callback(hObject, eventdata, handles)
% hObject    handle to inputText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inputText as text
%        str2double(get(hObject,'String')) returns contents of inputText as a double


% --- Executes during object creation, after setting all properties.
function inputText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in deriveButton.
function deriveButton_Callback(hObject, eventdata, handles)
% hObject    handle to deriveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fString = prep(handles.inputText.String);

if(fString(1) == '&')
    handles.errorText.String = fString(2:length(fString));
    handles.errorText.Visible = 'on';
else
    handles.uibuttongroup1.Visible = 'on';
    handles.errorText.Visible = 'off';
    handles.fText.String = addFuncs(fString);
    handles.fPrimeText.String = addFuncs(derive(fString));
    handles.domainLowText.String = '-5';
    handles.domainHighText.String = '5';
    handles.domainLowBox.String = '-5';
    handles.domainHighBox.String = '5';
    handles.domainLowText.BackgroundColor = 'w';
    handles.domainHighText.BackgroundColor = 'w';
    handles.rangeHighText.BackgroundColor = 'w';
    handles.rangeLowText.BackgroundColor = 'w';
    handles.xValueText.BackgroundColor = 'w';
    handles.xValueText.Value = 0;
    handles.xValueText.String = '';
    handles.fValueText.String = '';
    handles.fPrimeValueText.String = '';
    plotF(handles,true);
    latexStr = LaTeXify(simplify(derive(fString)));
    cla(handles.latexAxes);
    text(.01,0.5,latexStr,'interpreter','LaTeX');
end

% --- Executes on button press in functionCheckbox.
function functionCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to functionCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of functionCheckbox
plotF(handles,false);

% --- Executes on button press in derivativeCheckbox.
function derivativeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to derivativeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of derivativeCheckbox
plotF(handles,false);

% --- Executes on button press in gridCheckbox.
function gridCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to gridCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of gridCheckbox
plotF(handles,false);


function xValueText_Callback(hObject, eventdata, handles)
% hObject    handle to xValueText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xValueText as text
%        str2double(get(hObject,'String')) returns contents of xValueText as a double
xValue = str2num(handles.xValueText.String);
if(isempty(xValue))                           % if the number isn't valid:
    handles.xValueText.BackgroundColor = 'r'; % turn the input box red
    handles.fValueText.String = '';           % and clear the output boxes
    handles.fPrimeValueText.String = '';
else % evaluate functions
    handles.xValueText.BackgroundColor = 'w';
    syms x
    syms f(x)
    syms g(x)
    syms e
    e = exp(1);
    f(x) = handles.fText.String;
    g(x) = handles.fPrimeText.String;
    handles.xValueText.Value = 1;
    plotF(handles,false);
    %try/Catch statements to catch divide by zero error and return infinity
    try
        handles.fValueText.String = num2str(eval(f(xValue)));
    catch
        handles.fValueText.String = 'Inf';
    end
    try
        handles.fPrimeValueText.String = num2str(eval(g(xValue)));
    catch
        handles.fPrimeValueText.String = 'Inf';
    end
    
end


% --- Executes during object creation, after setting all properties.
function xValueText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xValueText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in legendCheckbox.
function legendCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to legendCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of legendCheckbox
plotF(handles,false);


% --- Executes on button press in axesCheckbox.
function axesCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to axesCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of axesCheckbox
plotF(handles,false)



function domainLowText_Callback(hObject, eventdata, handles)
% hObject    handle to domainLowText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of domainLowText as text
%        str2double(get(hObject,'String')) returns contents of domainLowText as a double
low = str2num(handles.domainLowText.String);
high = str2num(handles.domainHighText.String);

if(isempty(low) || isempty(high) || (low >= high))
    handles.domainLowText.BackgroundColor = 'r';
    handles.domainHighText.BackgroundColor = 'r';
else
    handles.domainLowText.BackgroundColor = 'w';
    handles.domainHighText.BackgroundColor = 'w';
    handles.domainLowBox.String = handles.domainLowText.String;
    handles.domainHighBox.String = handles.domainHighText.String;
    handles.xValueText.Value = 0;
    plotF(handles,false);
end

% --- Executes during object creation, after setting all properties.
function domainLowText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domainLowText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function domainHighText_Callback(hObject, eventdata, handles)
% hObject    handle to domainHighText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of domainHighText as text
%        str2double(get(hObject,'String')) returns contents of domainHighText as a double
low = str2num(handles.domainLowText.String);
high = str2num(handles.domainHighText.String);

if(isempty(low) || isempty(high) || (low >= high))
    handles.domainLowText.BackgroundColor = 'r';
    handles.domainHighText.BackgroundColor = 'r';
else
    handles.domainLowText.BackgroundColor = 'w';
    handles.domainHighText.BackgroundColor = 'w';
    handles.domainLowBox.String = handles.domainLowText.String;
    handles.domainHighBox.String = handles.domainHighText.String;
    handles.xValueText.Value = 0;
    plotF(handles,false);
end

% --- Executes during object creation, after setting all properties.
function domainHighText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to domainHighText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in defaultDomainButton.
function defaultDomainButton_Callback(hObject, eventdata, handles)
% hObject    handle to defaultDomainButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.domainLowText.String = '-5';
handles.domainHighText.String = '5';
handles.domainLowBox.String = '-5';
handles.domainHighBox.String = '5';
handles.domainLowText.BackgroundColor = 'w';
handles.domainHighText.BackgroundColor = 'w';
handles.xValueText.Value = 0;
plotF(handles,false);



function rangeLowText_Callback(hObject, eventdata, handles)
% hObject    handle to rangeLowText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rangeLowText as text
%        str2double(get(hObject,'String')) returns contents of rangeLowText as a double
low = str2num(handles.rangeLowText.String);
high = str2num(handles.rangeHighText.String);

if(isempty(low) || isempty(high) || (low >= high))
    handles.rangeLowText.BackgroundColor = 'r';
    handles.rangeHighText.BackgroundColor = 'r';
else
    handles.rangeLowText.BackgroundColor = 'w';
    handles.rangeHighText.BackgroundColor = 'w';
    handles.rangeLowBox.String = handles.rangeLowText.String;
    handles.rangeHighBox.String = handles.rangeHighText.String;
    plotF(handles,false);
end

% --- Executes during object creation, after setting all properties.
function rangeLowText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangeLowText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rangeHighText_Callback(hObject, eventdata, handles)
% hObject    handle to rangeHighText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rangeHighText as text
%        str2double(get(hObject,'String')) returns contents of rangeHighText as a double
low = str2num(handles.rangeLowText.String);
high = str2num(handles.rangeHighText.String);

if(isempty(low) || isempty(high) || (low >= high))
    handles.rangeLowText.BackgroundColor = 'r';
    handles.rangeHighText.BackgroundColor = 'r';
else
    handles.rangeLowText.BackgroundColor = 'w';
    handles.rangeHighText.BackgroundColor = 'w';
    handles.rangeLowBox.String = handles.rangeLowText.String;
    handles.rangeHighBox.String = handles.rangeHighText.String;
    plotF(handles,false);
end

% --- Executes during object creation, after setting all properties.
function rangeHighText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rangeHighText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until 5after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in defaultRangeButton.
function defaultRangeButton_Callback(hObject, eventdata, handles)
% hObject    handle to defaultRangeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.rangeLowText.String = '-5';
handles.rangeHighText.String = '5';
handles.rangeLowBox.String = '-5';
handles.rangeHighBox.String = '5';
handles.rangeLowText.BackgroundColor = 'w';
handles.rangeHighText.BackgroundColor = 'w';
plotF(handles,true);
