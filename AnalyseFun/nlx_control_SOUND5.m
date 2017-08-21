function nlx_control_SOUND5(newTrials,varargin)

global SPK % the spike data
global NLX_CONTROL_SETTINGS; % connect to the global settings file (loaded from nlx_control_settings_RFRC.m)

% check for existing channels in object
ChannelName     = nlx_control_gui_getSelectedChannel; % get the selected spike channels 
ChanIndex       = spk_findSpikeChan(SPK,ChannelName);
ChanIndexNum    = length(ChanIndex);
ChanName        = spk_get(SPK,'channel');

%++++++++++++++++++++++++++ make axes +++++++++++++++++++++++++++++++
% plot axes if there no axes in the main figure
if isempty(findobj('type','figure','tag','nlx_control_SOUND5'))
        
    % to save time make all graphics objects in advance so that we only need to update
    % the data  and not recreate the graphics objects.
    d.respTrialCount  = zeros(NLX_CONTROL_SETTINGS.analyse.CndParamNum);
    d.respRates       = zeros([NLX_CONTROL_SETTINGS.analyse.trialInit ChanIndexNum NLX_CONTROL_SETTINGS.analyse.CndParamNum]).*NaN;
    d.spontTrialCount = 0;
    d.spontRates      = zeros(NLX_CONTROL_SETTINGS.analyse.trialInit*prod(NLX_CONTROL_SETTINGS.analyse.CndParamNum), ChanIndexNum).*NaN;
    
    % note: param#1 is on x-axis, hence along columns of the map 
    d.mapData = zeros([NLX_CONTROL_SETTINGS.analyse.CndParamNum(2) NLX_CONTROL_SETTINGS.analyse.CndParamNum(1), ChanIndexNum]);
    
    % make figure
    figH = figure( ...
        'tag','nlx_control_SOUND5', ...
        'color','k', ...
        'numbertitle','off', ...
        'name','nlx_control_SOUND5', ...
        'menubar','none', ...
        'position', [100,100,900,900]);
    
    colormap(NLX_CONTROL_SETTINGS.analyse.colormap);

    % make axes
    allAxH  = subaxes(figH, [ChanIndexNum 1], [], [0.1 0.05],[0.05,0.15,0.05,0.05]);
    d.mapAxH  = allAxH(:,1);

    set(d.mapAxH, ...
        'units','normalized', ...
        'color',[0 0 0], ...
        'fontsize',6, ...
        'layer','top', ...
        'TickDir','out', ...
        'Box','on', ...
        'xcolor',[1 1 1], ...
        'ycolor',[1 1 1], ... 'DataAspectRatio',[1 1 1], ...
        'CLimMode','auto', ...
        'xlim',[0.5 NLX_CONTROL_SETTINGS.analyse.CndParamNum(1)+0.5],'xtick',[1:NLX_CONTROL_SETTINGS.analyse.CndParamNum(1)],'xticklabel',[], ...
        'ylim',[0.5 NLX_CONTROL_SETTINGS.analyse.CndParamNum(2)+0.5],'ytick',[1:NLX_CONTROL_SETTINGS.analyse.CndParamNum(2)],'yticklabel',[],'ydir','reverse');

    % make images
    for iChan = 1:ChanIndexNum
        set(d.mapAxH(iChan),'tag',['mapChan#' num2str(ChanIndexNum)]);
        d.mapImageH(iChan) = image( ...
            'XData',[1:NLX_CONTROL_SETTINGS.analyse.CndParamNum(1)], ...
            'YData',[1:NLX_CONTROL_SETTINGS.analyse.CndParamNum(2)], ...
            'CData',zeros(NLX_CONTROL_SETTINGS.analyse.CndParamNum(2),NLX_CONTROL_SETTINGS.analyse.CndParamNum(1)), ...
            'cdatamapping','scaled', ...
            'parent',d.mapAxH(iChan));
        colorbar('peer',d.mapAxH(iChan),'EastOutside');
    end
    
    set(figH,'userdata',d);
else
    figH = findobj('type','figure','tag','nlx_control_SOUND5');
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% check trials in object
trialTotal = spk_TrialNum(SPK);
if trialTotal==0
    % return if the object is empty
    return;
end 

% check new trials
if isempty(newTrials)
    % this is for offline analysis, when loading an existing SPK object
    % set newTrials to all the trials if it's empty
    newTrials=1:trialTotal;
end 
trialNum = length(newTrials);

% setting the trials and channels that we are interested in
SPK      = spk_set(SPK,'currenttrials',newTrials,'currentchan',ChanIndex);

% compute rates
% R is a matrix with [chan,trial,ith win]
R = spk_SpikeWinrate(SPK,cat(3,NLX_CONTROL_SETTINGS.analyse.spontWin,NLX_CONTROL_SETTINGS.analyse.respWin));

cndCodes    = spk_getTrialcode(SPK,'CortexCondition');
cndIndex    = cndCodes;
cndSubIndex = cell(1,length(NLX_CONTROL_SETTINGS.analyse.CndParam));

d = get(figH,'userdata');

% it might be safer to just loop the trials here in case we have repeated
% conditions in multiple trials
for iTrial=1:trialNum
    [cndSubIndex{:}] = ind2sub(NLX_CONTROL_SETTINGS.analyse.CndParamNum,cndCodes(iTrial));
    
    d.spontTrialCount                  = d.spontTrialCount + 1;
    d.spontRates(d.spontTrialCount, :) = permute(R(:,iTrial,1),[2,1,3]);
    
    d.respTrialCount(cndIndex(iTrial))                               = d.respTrialCount(cndIndex(iTrial)) + 1;
    d.respRates(d.respTrialCount(cndIndex(iTrial)),:,cndSubIndex{:}) = permute(R(:,iTrial,2),[2,1,3]);
    
%     fprintf('ch#1 spont %5.2f ch#2 spont %5.2f\n',R(1,iTrial,1),R(2,iTrial,1));
%     fprintf('ch#1 resp  %5.2f ch#2 resp  %5.2f\n',R(1,iTrial,2),R(2,iTrial,2));
end

% compute z-score map and update plots
for iChan = 1:ChanIndexNum
    meanSpontMap = repmat(nanmean(d.spontRates(:,iChan)),size(d.mapData,1),size(d.mapData,2));
    stdSpontMap  = repmat(nanstd(d.spontRates(:,iChan)),size(d.mapData,1),size(d.mapData,2));
    meanRespMap  = permute(nanmean(d.respRates(:,iChan,:,:)),[4,3,2,1]);
    d.mapData(:,:,iChan) = (meanRespMap - meanSpontMap) ./ stdSpontMap;
    d.mapData(~isfinite(d.mapData)) = 0;
    cLim = [-1 1] .* max(max(abs(d.mapData(:,:,iChan))));
    if any(isnan(cLim)) || diff(cLim)<=0;cLim = [-3 3];end
    set(d.mapImageH(iChan),'CData',d.mapData(:,:,iChan));
    set(d.mapAxH(iChan),'clim',cLim);
    
end

% update userdat
set(figH,'userdata',d);


