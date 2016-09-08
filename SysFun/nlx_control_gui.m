function varargout = nlx_control_gui(varargin)
% NLX_CONTROL_GUI M-file for nlx_control_gui.fig
%      NLX_CONTROL_GUI, by itself, creates a new NLX_CONTROL_GUI or raises the existing
%      singleton*.
%
%      H = NLX_CONTROL_GUI returns the handle to a new NLX_CONTROL_GUI or the handle to
%      the existing singleton*.
%
%      NLX_CONTROL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NLX_CONTROL_GUI.M with the given input arguments.
%
%      NLX_CONTROL_GUI('Property','Value',...) creates a new NLX_CONTROL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before nlx_control_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to nlx_control_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help nlx_control_gui

% Last Modified by GUIDE v2.5 18-Jan-2006 12:18:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @nlx_control_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @nlx_control_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before nlx_control_gui is made visible.
function nlx_control_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to nlx_control_gui (see VARARGIN)

% Choose default command line output for nlx_control_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes nlx_control_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

global NLX_CONTROL_SETTINGS
NLX_CONTROL_SETTINGS = [];
set(hObject,'color','k','name','NLX CONTROL - NO SETTINGS LOADED !');

% --- Outputs from this function are returned to the command line.
function varargout = nlx_control_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function DataAcq_Callback(hObject, eventdata, handles)
% hObject    handle to DataAcq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function DataAcqOn_Callback(hObject, eventdata, handles)
% hObject    handle to DataAcqOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NLX_CONTROL_GET_CHEETAH
global NLX_CONTROL_SETTINGS
set(hObject,'checked','on');
set(findobj('tag','DataAcqOff'),'checked','off');
NLX_CONTROL_GET_CHEETAH = 1;
fprintf(1,'\n');
if isempty(NLX_CONTROL_SETTINGS)
    settings_load_Callback;
end
nlx_control_cheetah;

% --------------------------------------------------------------------
function DataAcqOff_Callback(hObject, eventdata, handles)
% hObject    handle to DataAcqOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global NLX_CONTROL_GET_CHEETAH
set(hObject,'checked','on');
set(findobj('tag','DataAcqOn'),'checked','off');
NLX_CONTROL_GET_CHEETAH = 0;


% --------------------------------------------------------------------
function spkObject_Callback(hObject, eventdata, handles)
% hObject    handle to DataAcq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function spkObjectLoad_Callback(hObject, eventdata, handles)
% hObject    handle to spkObjectLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global NLX_CONTROL_SETTINGS
global SPK;

SPK = spk_loadstruct(al_spk);
if isempty(SPK);return;end
if isempty(NLX_CONTROL_SETTINGS)
    settings_load_Callback;
end
nlx_control_callAnalyse(nlx_control_getSelectedAnalyses,0,[]);

% --------------------------------------------------------------------
function spkObjectSave_Callback(hObject, eventdata, handles)
% hObject    handle to spkObjectSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SPK
if isa(SPK,'al_spk');
    spk_savestruct(SPK,[nlx_control_getDataDir '\']); 
end

% --- Executes during object deletion, before destroying properties.
function nlx_control_gui_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to nlx_control_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function functions_Callback(hObject, eventdata, handles)
% hObject    handle to functions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Plots_Callback(hObject, eventdata, handles)
% hObject    handle to Plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function tomatlab_Callback(hObject, eventdata, handles)
% hObject    handle to tomatlab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SPK
assignin('base','SPK',SPK);


% --------------------------------------------------------------------
function spkobjectstructure_Callback(hObject, eventdata, handles)
% hObject    handle to spkobjectstructure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SPK
if isa(SPK,'al_spk'); SPK = struct(SPK); end
assignin('base','SPK',SPK);


% --------------------------------------------------------------------
function Settings_Callback(hObject, eventdata, handles)
% hObject    handle to Settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function settings_clear_Callback(hObject, eventdata, handles)
% hObject    handle to settings_clear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global NLX_CONTROL_SETTINGS
NLX_CONTROL_SETTINGS = [];
set(findobj('tag','nlx_control_gui','type','figure'),'name','NLX CONTROL - NO SETTINGS LOADED !');
% --------------------------------------------------------------------
function settings_load_Callback(hObject, eventdata, handles)
% hObject    handle to settings_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global NLX_CONTROL_SETTINGS
[SettingsFileName,SettingsFileDir] = uigetfile('*.m','LOAD settings structure via *.m file',nlx_control_getSettingsDir);
if SettingsFileName==0;return;end
[SettingsFileDir,SettingsFileName,SettingsFileExt] = fileparts(fullfile(SettingsFileDir,SettingsFileName));
oldCD = cd;
cd(SettingsFileDir);
NLX_CONTROL_SETTINGS = feval(SettingsFileName);
cd(oldCD);
disp(NLX_CONTROL_SETTINGS);
set(nlx_control_getMainWindowHandle,'name',['NLX CONTROL - ' SettingsFileName]);


% --------------------------------------------------------------------
function nlx_control_gui_loadLOG_Callback(hObject, eventdata, handles)
% hObject    handle to nlx_control_gui_loadLOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global NLX_CONTROL_SETTINGS
SPK = nlx_control_gui_LOG2SPK(NLX_CONTROL_SETTINGS);
SPK = al_spk(SPK);
set(nlx_control_getMainWindowHandle,'userdata',SPK);




