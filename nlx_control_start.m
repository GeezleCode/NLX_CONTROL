function nlx_control_start

% starts the NLX_CONTROL environment

MainDir = fileparts(which('nlx_control_start'));

%% puts subdirectories on the matlab path

addpath(MainDir);
addpath(fullfile(MainDir,'SysFun'));
addpath(nlx_control_getSettingsDir);
addpath(fullfile(MainDir,'SysFun','NetCom'));

addpath(fullfile(MainDir,'SysFun','misc'));

al_spk_ObjPath = which('al_spk');
if isempty(al_spk_ObjPath)
    addpath(fullfile(MainDir,'SysFun','misc'));
else
    % assume that all necessary libraries are existent
    fprintf('Detected @al_spk in -> %s\n',fileparts(al_spk_ObjPath));
end


%% start the GUI
nlx_control_gui;

% set GUI menues
H = nlx_control_gui_AnalyseMenu;

ChannelNrs    = [1:16];
ChannelLabel  = {'e1SE' 'e2SE'};
ClusterNrs    = [0];

% ChannelNrs = [1:16];
% ChannelLabel  = {'e1SE' 'e2SE' 'e3SE'};
% ClusterNrs = [0];

% ChannelNrs = [1:2];
% ChannelLabel  = {'SE'};
% ClusterNrs = [0];


H = nlx_control_gui_SEChannelMenu(ChannelLabel,ChannelNrs,ClusterNrs);

