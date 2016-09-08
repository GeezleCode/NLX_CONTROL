function nlx_control_TRIALRASTER(t,varargin)

global SPK
global NLX_CONTROL_SETTINGS; 

if length(t)~=1
    return;
end

% plot this channels
[ChanNum,ChanLabel,EmptyChan,NumSpk] = spk_SpikeChanNum(SPK);
ChanIndex = 1:ChanNum;

% organise y dimension
RasterTicksScale = 0.8;
ylim = [-1 ChanNum];

%% prepare figure
CntrlFigH = findobj('type','figure','tag','nlx_control');
axesH = findobj('tag','raster0');
if isempty(axesH)
    figure(CntrlFigH);
    axesH = axes('tag','raster0', ...
        'units','normalized','position',[0.05 0.2 0.9 0.6]);
end
xlim = NLX_CONTROL_SETTINGS.CurrTrialTimeTicks([1 end]);
set(axesH, ...
    'color','k', ...
    'visible','on', ...
    'tickdir','out', ...
    'box','on', ...
    'xcolor',[.5 .5 .5],'xlim',xlim,'xtick',NLX_CONTROL_SETTINGS.CurrTrialTimeTicks,'XTickLabelMode','auto', ...
    'ycolor',[.5 .5 .5],'ylim',ylim,'yticklabel','');

%% activate axes
axes(axesH);cla;
line(xlim,[0 0],'linestyle','-','color',[.5 .5 .5],'linewidth',0.75,'clipping','off');

%% Events
currTrEvents = spk_getTrialData(SPK,'events',t);
currTrialAlignEventTime = currTrEvents{spk_findEventlabel(SPK,NLX_CONTROL_SETTINGS.CurrTrialAlignEventName)};
currEvTrain = sort(cat(2,currTrEvents{:}));
currEvTrain = currEvTrain - currTrialAlignEventTime;
currEvTrainNum = length(currEvTrain);

text(xlim(1),-0.5,'EV', ...
    'fontsize',8,'color',NLX_CONTROL_SETTINGS.EventColor(1,:),'fontname','arial','horizontalalignment','right','verticalalignment','middle');
line(repmat(currEvTrain,[2 1]),[ones(1,currEvTrainNum).*-1;zeros(1,currEvTrainNum)], ...
    'linestyle','-','color',NLX_CONTROL_SETTINGS.EventColor(1,:),'linewidth',1.5,'clipping','off');

%% plot SPIKE channels
currSpkTrain = [];
SPK = spk_set(SPK,'currenttrials',t,'currentchan',[]);
currTrspk = spk_getTrialData(SPK,'spk',t);
currTrAl = spk_getTrialData(SPK,'align',t);
for j=1:length(ChanIndex)
    text(xlim(1),-0.5+j,ChanLabel{j}, ...
        'fontsize',8,'color',NLX_CONTROL_SETTINGS.SpikeChanColor(ChanIndex(j),:), ...
        'fontname','arial','horizontalalignment','right','verticalalignment','middle');
    if isnan(ChanIndex(j))
        continue;
    else
        currSpkTrainNum = length(currTrspk{ChanIndex(j)});
        if currSpkTrainNum>0;
            line(repmat(currTrspk{ChanIndex(j)}-currTrialAlignEventTime,[1 2]), ...
                [ones(currSpkTrainNum,1).*-RasterTicksScale.*0.5 ones(currSpkTrainNum,1).*RasterTicksScale.*0.5]+j-0.5, ...
                'linestyle','-', ...
                'color',NLX_CONTROL_SETTINGS.SpikeChanColor(ChanIndex(j),:), ...
                'linewidth',1, ...
                'clipping','on');
        end
    end
end
