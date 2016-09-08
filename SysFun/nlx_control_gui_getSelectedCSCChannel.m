function [activeCh] = nlx_control_gui_getSelectedCSCChannel

% returns the ticked spike channels
% [activeCh,activeEl] = nlx_control_gui_getSelectedChannel
%
% activeCh ... names of channels/clusters e.g. 'Sc1.0'
% activeEl ... names of electrodes/recording entities 'Sc1'

%% get the list of channels
ChannelLabel = 'LFP';
ChMenuHdl = findobj('parent',nlx_control_getMainWindowHandle,'type','uimenu','tag',sprintf('%sChannelMenu',ChannelLabel));
ChItemHdl = get(ChMenuHdl,'children');
ChannelList = get(flipud(ChItemHdl),'label');
nTotal = length(ChannelList);

%% get list of active channels
isactiveCh = ismember(get(flipud(ChItemHdl),'checked'),'on');
nActCh = sum(isactiveCh);
activeCh = ChannelList(isactiveCh);

