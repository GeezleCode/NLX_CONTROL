function ChannelMenu = nlx_control_gui_ChannelMenu

% creates the cluster menu for the main fig

MainDir = nlx_control_getMainDir;
MainWin = nlx_control_getMainWindowHandle;

ChannelMenu = uimenu('parent',MainWin,'label','Channel','tag','ChannelMenu');
for iEl = 1:32
    
    % default functions
    SepFlag = 'on';
    for iCl = 0:0
        uimenu('parent',ChannelMenu,'separator',SepFlag, ...
            'label',sprintf('SE%1.0f.%1.0f',iEl,iCl), ...
            'tag',sprintf('SE%1.0f.%1.0f',iEl,iCl), ...
            'callback','switch get(gcbo,''checked'');case ''on''; set(gcbo,''checked'',''off'');case ''off''; set(gcbo,''checked'',''on'');end');
        SepFlag = 'off';
    end
end

