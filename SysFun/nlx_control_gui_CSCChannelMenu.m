function ChannelMenu = nlx_control_gui_CSCChannelMenu(ChannelLabel,ChannelNrs)

% creates the cluster menu for the main fig
if nargin<1
    ChannelNrs = [1 2];
    ChannelLabel  = 'CSC';
end

MainDir = nlx_control_getMainDir;
MainWin = nlx_control_getMainWindowHandle;

ChannelMenu = uimenu('parent',MainWin,'label',sprintf('%s-Channel',ChannelLabel),'tag',sprintf('%sChannelMenu',ChannelLabel));

for iEl = ChannelNrs
    
    % default functions
    SepFlag = 'on';
    uimenu('parent',ChannelMenu,'separator',SepFlag, ...
        'label',sprintf('%s%1.0f',ChannelLabel,iEl), ...
        'tag',sprintf('%s%1.0f',ChannelLabel,iEl), ...
        'callback','switch get(gcbo,''checked'');case ''on''; set(gcbo,''checked'',''off'');case ''off''; set(gcbo,''checked'',''on'');end');
    SepFlag = 'off';
end

