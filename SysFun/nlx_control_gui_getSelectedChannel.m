function [activeCh,activeEl] = nlx_control_gui_getSelectedChannel

% returns the ticked spike channels
% [activeCh,activeEl] = nlx_control_gui_getSelectedChannel
%
% activeCh ... names of channels/clusters e.g. 'Sc1.0'
% activeEl ... names of electrodes/recording entities 'Sc1'

%% get the list of channels 
ChMenuHdl = findobj('parent',nlx_control_getMainWindowHandle,'type','uimenu','tag','NSELabelMenu');
ChItemHdl = get(ChMenuHdl,'children');
ChannelList = get(flipud(ChItemHdl),'label');
nTotal = length(ChannelList);

%% get electrodes
ElList = cell(nTotal,1);
for i=1:nTotal
    ElList{i} = strtok(ChannelList{i},'.');
end
ElList = unique(ElList);

%% get list of active channels
isactiveCh = ismember(get(flipud(ChItemHdl),'checked'),'on');
nActCh = sum(isactiveCh);
activeCh = ChannelList(isactiveCh);

%% get list of active electrodes
activeEl = {};
for i=1:length(activeCh)
    for k=1:length(activeCh)
        if ~any(strcmp(strtok(activeCh{k},'.'),activeEl))
            activeEl = cat(1,activeEl,strtok(activeCh{k},'.'));
        end
    end
end

