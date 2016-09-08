function h = nlx_control_getMainWindowHandle
% returns handle of NLX_CONTROL_GUI
h = findobj('tag','nlx_control','type','figure');