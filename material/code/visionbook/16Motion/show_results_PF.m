function varargout = show_results_PF(varargin)
% SHOW_RESULTS_PF M-file for show_results_PF.fig
%      SHOW_RESULTS_PF, by itself, creates a new SHOW_RESULTS_PF or raises the existing
%      singleton*.
%
%      H = SHOW_RESULTS_PF returns the handle to a new SHOW_RESULTS_PF or the handle to
%      the existing singleton*.
%
%      SHOW_RESULTS_PF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHOW_RESULTS_PF.M with the given input arguments.
%
%      SHOW_RESULTS_PF('Property','Value',...) creates a new SHOW_RESULTS_PF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before show_results_PF_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to show_results_PF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools File.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help show_results_PF

% Last Modified by GUIDE v2.5 20-Mar-2007 09:21:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @show_results_PF_OpeningFcn, ...
                   'gui_OutputFcn',  @show_results_PF_OutputFcn, ...
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


% --- Executes just before show_results_PF is made visible.
function show_results_PF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to show_results_PF (see VARARGIN)

% Choose default command line output for show_results_PF
handles.output = hObject;

% Input data to handles structure
if length(varargin) == 1
    handles.conf = varargin{1};
else
    error('One argument needed');
end

% Set the Max value and step values
set(handles.slider,'Max',handles.conf.steps);
set(handles.slider,'SliderStep',[1/(handles.conf.steps-1) 10/(handles.conf.steps-1)]);

% Create handle to imshow
img = imread([handles.conf.DIR_IMAGES sprintf('img%04d.png',1)]);
axes(handles.axes);
h = imshow(img);
set(handles.axes,'UserData',h);
set(handles.axes,'Visible','on');

% Initialize stop button
set(handles.pushbutton_stop,'UserData',0);

% Set default timing;
handles.timing = 0.05;

% Update handles structure
guidata(hObject, handles);

% Update view
update_view(handles);

% UIWAIT makes show_results_PF wait for user response (see UIRESUME)
% uiwait(handles.player);


% --- Outputs from this function are returned to the command line.
function varargout = show_results_PF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_prev.
function pushbutton_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

step = str2num(get(handles.edit_step,'String'));
if step > 1
    set(handles.edit_step,'String',num2str(step-1));
    set(handles.slider,'Value',step-1);
end
update_view(handles);


% --- Executes on button press in pushbutton_play.
function pushbutton_play_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Disable play button
set(hObject,'enable','inactive');
% Reset stop flag
set(handles.pushbutton_stop,'UserData',0);

% Draw and update edit_step and slider
for i = str2num(get(handles.edit_step,'String')):handles.conf.steps
    set(handles.edit_step,'String',int2str(i));
    set(handles.slider,'Value',i);
    update_view(handles);
    pause(handles.timing);
    % Check the stop flag
    if get(handles.pushbutton_stop,'UserData');
        break
    end
end

% At the end rewind to the start
if i == handles.conf.steps
    set(handles.edit_step,'String','1');
    set(handles.slider,'Value',1);
    update_view(handles);
end

set(hObject,'enable','on');


% --- Executes on button press in pushbutton_pause.
function pushbutton_pause_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if get(handles.pushbutton_stop,'UserData')
%     % Paused or stop
    set(handles.pushbutton_stop,'UserData',1);


% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.pushbutton_stop,'UserData',1);
set(handles.edit_step,'String','1');
set(handles.slider,'Value',1);
update_view(handles);


% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

step = str2num(get(handles.edit_step,'String'));
if step < handles.conf.steps
    set(handles.edit_step,'String',num2str(step+1));
    set(handles.slider,'Value',step+1);
end
update_view(handles);


% --- Executes on slider movement.
function slider_Callback(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(hObject,'Value',round(get(handles.slider,'Value')));
set(handles.edit_step,'String',num2str(get(handles.slider,'Value')));
update_view(handles);


% --- Executes during object creation, after setting all properties.
function slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function edit_step_Callback(hObject, eventdata, handles)
% hObject    handle to edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_step as text
%        str2double(get(hObject,'String')) returns contents of edit_step as a double

% Check the input and update view
step = str2num(get(hObject,'String'));
if isnumeric(step) && ~isempty(step)
    set(hObject,'String',num2str(round(step)));
else
    errordlg('Invalid input parameter, must be an integer','Bad Input');
    set(hObject,'String','1');
end
update_view(handles);

% --- Executes during object creation, after setting all properties.
function edit_step_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_step (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_view(handles)
% Update image in the axis with actual settings

step = str2num(get(handles.edit_step,'String'));

switch get(handles.popupmenu,'Value')
    case 1, % Input images
        img = imread([handles.conf.DIR_IMAGES sprintf('img%04d.png',step)]);
        set(get(handles.axes,'UserData'),'CDATA',img);
    case 2, % Samples
        load([handles.conf.DIR_RESULTS sprintf('step%04d',step)]);
        set(get(handles.axes,'UserData'),'XData',S.s(2,:));
        set(get(handles.axes,'UserData'),'YData',S.s(1,:));
    case 3, % Input images and samples
        img = imread([handles.conf.DIR_IMAGES sprintf('img%04d.png',step)]);
        load([handles.conf.DIR_RESULTS sprintf('step%04d',step)]);
        h = get(handles.axes,'UserData');
        set(h(1),'CDATA',img);
        set(h(2),'XData',S.s(2,:));
        set(h(2),'YData',S.s(1,:));
    case 4, % Probability and samples
        Prob_map = imread([handles.conf.DIR_RESULTS sprintf('prob_map%04d.png',step)]);
        load([handles.conf.DIR_RESULTS sprintf('step%04d',step)]);
        h = get(handles.axes,'UserData');
        set(h(1),'CDATA',Prob_map);
        set(h(2),'XData',S.s(2,:));
        set(h(2),'YData',S.s(1,:));
    case 5, % Probability
        Prob_map = imread([handles.conf.DIR_RESULTS sprintf('prob_map%04d.png',step)]);
        h = get(handles.axes,'UserData');
        set(h,'CDATA',Prob_map);
end

% --- Executes on selection change in popupmenu.
function popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu

step = str2num(get(handles.edit_step,'String'));

switch get(handles.popupmenu,'Value')
    case 1, % Input images
        img = imread([handles.conf.DIR_IMAGES sprintf('img%04d.png',step)]);
        h = imshow(img);
        set(handles.axes,'UserData',h);
        set(handles.axes,'Visible','on');
    case 2, % Samples
        load([handles.conf.DIR_RESULTS sprintf('step%04d',step)]);
        h = plot(S.s(2,:),S.s(1,:),'.','Color',[1 0 0]);
        set(handles.axes,'UserData',h);
        set(handles.axes,'YDir','reverse');
        set(handles.axes,'XLim',[0 handles.conf.img_y]);
        set(handles.axes,'XLimMode','manual');
        set(handles.axes,'YLim',[0 handles.conf.img_x]);
        set(handles.axes,'YLimMode','manual');
    case 3, % Input images and samples
        img = imread([handles.conf.DIR_IMAGES sprintf('img%04d.png',step)]);
        load([handles.conf.DIR_RESULTS sprintf('step%04d',step)]);
        set(handles.axes,'XLimMode','manual');
        set(handles.axes,'YLimMode','manual');
        h1 = imshow(img);
        set(handles.axes,'Visible','on');
        set(handles.axes,'NextPlot','add');
        h2 = plot(S.s(2,:),S.s(1,:),'o','Color',[1 1 1],'MarkerSize',3);
        set(handles.axes,'NextPlot','replace');
        set(handles.axes,'UserData',[h1 h2]);
    case 4, % Probability and samples
        Prob_map = imread([handles.conf.DIR_RESULTS sprintf('prob_map%04d.png',step)]);
        load([handles.conf.DIR_RESULTS sprintf('step%04d',step)]);
        set(handles.axes,'XLimMode','manual');
        set(handles.axes,'YLimMode','manual');
        h1 = imshow(Prob_map);
        set(handles.axes,'Visible','on');
        set(handles.axes,'NextPlot','add');
        h2 = plot(S.s(2,:),S.s(1,:),'o','Color',[1 1 1],'MarkerSize',3);
        set(handles.axes,'NextPlot','replace');
        set(handles.axes,'UserData',[h1 h2]);
        colormap(cool);
    case 5, % Probability
        Prob_map = imread([handles.conf.DIR_RESULTS sprintf('prob_map%04d.png',step)]);
        h = imshow(Prob_map);
        set(handles.axes,'Visible','on');
        set(handles.axes,'XLimMode','manual');
        set(handles.axes,'YLimMode','manual');
        set(handles.axes,'UserData',h);
        colormap(cool);
end

guidata(hObject, handles);
update_view(handles);

% --- Executes during object creation, after setting all properties.
function popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

delete(handles.player);


% --------------------------------------------------------------------
function conf_timing_Callback(hObject, eventdata, handles)
% hObject    handle to conf_timing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Ask for the time
DefAns{1} = num2str(handles.timing);
answer = inputdlg('Time between frames','Timing',1,DefAns);
timing = str2num(answer{1});
if isnumeric(timing) && ~isempty(timing)
    handles.timing = timing;
else
    errordlg('Invalid input parameter, using default 0.05','Bad Input');
    handles.timing = 0.05;
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function Configuration_Callback(hObject, eventdata, handles)
% hObject    handle to Configuration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

