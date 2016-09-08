function ChannelMenu = nlx_control_gui_SEChannelMenu(ChannelLabel,ChannelNrs,ClusterNrs)

% creates the cluster menu for the main fig
if nargin<1
    ChannelNrs = [1 2];
    ChannelLabel  = 'SE';
    ClusterNrs = [0 1 2];
end
if ischar(ChannelLabel)
    ChannelLabel = {ChannelLabel};
end

MainDir = nlx_control_getMainDir;
MainWin = nlx_control_getMainWindowHandle;

ChannelMenu = uimenu('parent',MainWin,'label','*.nse label','tag','NSELabelMenu');

for iCh = ChannelLabel
    SepFlag = 'on';
    for iEl = ChannelNrs
        
        % default functions
        
        for iCl = ClusterNrs
            uimenu('parent',ChannelMenu,'separator',SepFlag, ...
                'label',sprintf('%s%1.0f.%1.0f',char(iCh),iEl,iCl), ...
                'tag',sprintf('%s%1.0f.%1.0f',char(iCh),iEl,iCl), ...
                'callback','switch get(gcbo,''checked'');case ''on''; set(gcbo,''checked'',''off'');case ''off''; set(gcbo,''checked'',''on'');end');
            SepFlag = 'off';
        end
    end
end
