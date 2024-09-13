function varargout = Unified_GUI(varargin)
% UNIFIED_GUI M-file for Unified_GUI.fig
%      UNIFIED_GUI, by itself, creates a new UNIFIED_GUI or raises the existing
%      singleton*.
%
%      H = UNIFIED_GUI returns the handle to a new UNIFIED_GUI or the handle to
%      the existing singleton*.
%
%      UNIFIED_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UNIFIED_GUI.M with the given input arguments.
%
%      UNIFIED_GUI('Property','Value',...) creates a new UNIFIED_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Unified_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Unified_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Unified_GUI

% Last Modified by GUIDE v2.5 11-Jan-2019 11:38:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Unified_GUI_OpeningFcn, ...
    'gui_OutputFcn',  @Unified_GUI_OutputFcn, ...
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


% --- Executes just before Unified_GUI is made visible.
function Unified_GUI_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Unified_GUI (see VARARGIN)

% Choose default command line output for Unified_GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Unified_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Unified_GUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_path_Callback(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_path as text
%        str2double(get(hObject,'String')) returns contents of edit_path as a double


% --- Executes during object creation, after setting all properties.
function edit_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Browse_path.
function Browse_path_Callback(hObject, eventdata, handles)
% hObject    handle to Browse_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set( handles.edit_path,'String',uigetdir());



function editEpochSize_Callback(hObject, eventdata, handles)
% hObject    handle to editEpochSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEpochSize as text
%        str2double(get(hObject,'String')) returns contents of editEpochSize as a double


% --- Executes during object creation, after setting all properties.
function editEpochSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEpochSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editUpTrashold_Callback(hObject, eventdata, handles)
% hObject    handle to editUpTrashold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editUpTrashold as text
%        str2double(get(hObject,'String')) returns contents of editUpTrashold as a double


% --- Executes during object creation, after setting all properties.
function editUpTrashold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editUpTrashold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLowTrashold_Callback(hObject, eventdata, handles)
% hObject    handle to editLowTrashold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLowTrashold as text
%        str2double(get(hObject,'String')) returns contents of editLowTrashold as a double


% --- Executes during object creation, after setting all properties.
function editLowTrashold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLowTrashold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in pushbutton_Execute.
function pushbutton_Execute_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Execute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text_ready_busy,'String','Busy');
handle_msgbox = msgbox('Calculating');

path = strcat(get(handles.edit_path,'String'),'\');
format=get(handles.FormatPnl,'SelectedObject');
format=get(format,'String');

epochs = strcat(path,'events.txt');

EpochSize = str2double( get(handles.editEpochSize,'String') );
upthresh= str2num( get(handles.editUpTrashold,'String') );    %upper threshold
lowthresh= str2num( get(handles.editLowTrashold,'String') );   %lower threshold
lowFreq= str2num( get(handles.lFreq,'String') );
higFreq= str2num( get(handles.hFreq,'String') );

sampling_rate = str2num( get(handles.edit_sampling_rate,'String'));

name=strcat(path,['*.' format]);
d=dir(name);   %load files
folder = 'netlab\';
mkdir(path, folder);
path2 = strcat(path,folder);
fpRe=fopen([strcat(path,folder)+"report"+date+".csv"],"wt");
fprintf(fpRe,"EpochSize=%g\n",EpochSize);
fprintf(fpRe,"upthresh=%g\n",upthresh);
fprintf(fpRe,"lowthresh=%g\n",lowthresh);
fprintf(fpRe,"lowFreq=%g\n",lowFreq);
fprintf(fpRe,"higFreq=%g\n",higFreq);

fprintf(fpRe,"File\tDeleted\ttotal\tdiff\ttime\n");


for j=1:length(d)
    
    j
    f=d(j).name;
    
    load([path f],'Power_per_epoch','time_per_epoch');
    
    size(Power_per_epoch,2);
    
    EpochsRange=  size(Power_per_epoch,2);
    Power_per_epoch;
    TotalNumberOfEvents=  size(Power_per_epoch,2);
    count_removed=0;
    for i=1:EpochsRange
        EventStart=Power_per_epoch(:,i);
        TimeStart=time_per_epoch(:,i);
        
        if  Power_per_epoch(i) < upthresh && Power_per_epoch(i) > lowthresh
            fprintf(fpRe,"%s\t%g\t%g\t%g\t%s\n",f,0,1,EventStart-TimeStart);
        else
            fprintf(fpRe,"%s\t%g\t%g\t%g\t%s\n",f,1,0,EventStart-TimeStart);
            count_removed = count_removed +1;
        end
        
    end
end


fclose(fpRe);
delete(handle_msgbox);
set(handles.text_ready_busy,'String','Ready');