function nlx_control_start

% starts the NLX_CONTROL environment

%% puts subdirectories on the matlab path
MainDir = fileparts(which('nlx_control_start'));
addpath( ...
    MainDir, ...
    [MainDir '\SysFun'], ...
    [MainDir '\SysFun\misc'], ...
    [MainDir '\SysFun\NetCom']);
addpath(nlx_control_getSettingsDir);

%% start the GUI
nlx_control_gui;

% set GUI menues
H = nlx_control_gui_AnalyseMenu;
H = nlx_control_gui_SEChannelMenu;
H = nlx_control_gui_CSCChannelMenu;

