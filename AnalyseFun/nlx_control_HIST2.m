function nlx_control_hist(t,varargin)

% plots a grid of histograms and raster plot depending on the settings
% given in nlx_control_settings.m
%
% t .... trials to plot in this run, if t is left empty all trials are
%           plotted.

global SPK
global NLX_CONTROL_SETTINGS;

p = NLX_CONTROL_SETTINGS;
% check for existing channels in object
[ChannelName,activeEl] = nlx_control_gui_getSelectedChannel;
ChanIndex = spk_findSpikeChan(SPK,ChannelName);
ChanIndexNum = length(ChanIndex);
ChanColor = NLX_CONTROL_SETTINGS.SpikeChanColor(1:ChanIndexNum,:);
SPK = spk_set(SPK,'currenttrials',[]);
ChanName = spk_get(SPK,'channel');

[PlotRowNum,PlotColNum] = size(p.Hist2Grid);
PlotTotalNum = PlotRowNum * PlotColNum;

StimCodeIndex = [];
for i = 1:size(p.Hist2Grid,1)
    for j = 1:size(p.Hist2Grid,2)
        StimCodeIndex(p.Hist2Grid{i,j},1) = [1:length(p.Hist2Grid{i,j})]';
    end
end
            

%++++++++++++++++++++++++++ make axes +++++++++++++++++++++++++++++++
for iCh = 1:ChanIndexNum
    cFig = findobj('type','figure','tag',['nlx_control_hist ' ChannelName{ChanIndex(iCh)}]);
    % plot axes if there no axes in the main figure
    if isempty(cFig)
        HistFigHandle(iCh) = figure( ...
            'tag',['nlx_control_hist ' ChannelName{ChanIndex(iCh)}], ...
            'color','k', ...
            'numbertitle','off', ...
            'name',['Hist ' ChannelName{ChanIndex(iCh)}], ...
            'menubar','none');
        
        CndAx = subaxes(HistFigHandle(iCh),[PlotRowNum,PlotColNum],[],[0.01 0.01],[0.01,0.01,0.01,0.01]);
        H = struct;
        for i = 1:PlotRowNum
            for j = 1:PlotColNum
                
                set(CndAx(i,j),'units','normalized');
                cH = insertaxes(CndAx(i,j),[0 0 1 0.5]);
                set(cH,'tag',['hist' ChannelName{ChanIndex(iCh)} ' ' num2str(i) ' ' num2str(j)], ...
                    'color','k','box','off', ...
                    'layer','bottom','tickdir','out', ...
                    'xcolor',[1 1 1],'xticklabel','','xlim',p.RasterTimeLim,'xtick',p.RasterTimeTicks, ...
                    'ycolor',[1 1 1],'yticklabel','','ylim',p.HistYLim);
                H.HistAx(p.Hist2Grid{i,j}) = cH;
                H.HistColor(p.Hist2Grid{i,j},:) = p.Hist2Color;
                
                cH = insertaxes(CndAx(i,j),[0 0.55 1 0.4]);
                axes(cH);
                set(gca,'tag',['raster' ChannelName{ChanIndex(iCh)} ' ' num2str(i) ' ' num2str(j)], ...
                    'color','k','visible','off', ...
                    'xcolor',[1 1 1],'xticklabel','','xlim',p.RasterTimeLim, ...
                    'ycolor',[1 1 1],'yticklabel','','ylim',[0 length(p.Hist2Grid{i,j})*(p.RasterTrialNum+1)]);
                if all(isnan(p.Hist2Grid{i,j}) | p.Hist2Grid{i,j}==0);continue;end
                for k = 1:p.RasterTrialNum
                    for m = 1:length(p.Hist2Grid{i,j})
                        H.SpikeRasterLine(p.Hist2Grid{i,j}(m),k) = line(NaN,NaN, ...
                            'tag',['spikeraster#' num2str(iCh) '#' num2str(p.Hist2Grid{i,j}(m)) '#' num2str(k)], ...
                            'linestyle','none', ...
                            'marker','o','markeredgecolor','none','markerfacecolor',p.Hist2Color(m,:),'markersize',p.RasterDotSize, ...
                            'clipping','on');
                        H.EventRasterLine(p.Hist2Grid{i,j}(m),k) = line(NaN,NaN, ...
                            'tag',['eventraster#' num2str(iCh) '#' num2str(p.Hist2Grid{i,j}(m)) '#' num2str(k)], ...
                            'linestyle','none', ...
                            'marker','v','markeredgecolor','none','markerfacecolor',p.EventColor(1,:),'markersize',p.RasterEventSize, ...
                            'clipping','on');
                    end
                end
                ylim = get(gca,'ylim');
                %             text(p.RasterTimeLim(1)+(p.RasterTimeLim(2)-p.RasterTimeLim(1)).*0.5,ylim(1)+(ylim(2)-ylim(1)).*0.75, ...
                text(p.RasterTimeLim(1),ylim(2), ...
                    [num2str(p.Hist2Grid{i,j})], ...
                    'tag',['cnd' num2str(p.StimCodeGrid(i,j)) 'title'],'fontsize',10,'color',[1 1 1],'horizontalalignment','left','verticalalignment','middle');
                
            end
        end
        delete(CndAx);
        set(HistFigHandle(iCh),'userdata',H);
        clear H;;
    else
        HistFigHandle(iCh) = cFig;
        
    end
    

end

%++++++++++++++++++++++++++ plot the data +++++++++++++++++++++++++++++++
for i=1:ChanIndexNum
    H(i) = get(HistFigHandle(i),'userdata');
end
total = spk_TrialNum(SPK);
NumChan = spk_SpikeChanNum(SPK);
if total==0;return;end % return if the object is empty
if isempty(t);t=1:total;end % set t to all the trials if it's empty

% trial identifiers
blockCodes = spk_getTrialcode(SPK,'CortexBlock');
cndCodes = spk_getTrialcode(SPK,'CortexCondition');
stimCodes = spk_getTrialcode(SPK,'StimulusCode');
if all(isnan(stimCodes))
    stimCodes = (blockCodes-1).*p.Cndnum+cndCodes;
end

if ~all(ismember(cndCodes(t),p.StimCodeGrid)) | cndCodes(t)<1
    error('Simulus code is not found in StimCodeGrid in settings!');
end

%######################################################3
% align timestamps to p.RasterAlignEvent
SPK = spk_set(SPK,'currenttrials',[]);
CortexPresentationNr = spk_getTrialcode(SPK,'CortexPresentationNr');
AlignTime = spk_getevents(SPK,p.RasterAlignEventName);
if any(cellfun('length',AlignTime)>1) % might happen for severeal STIM_ONS!!!
    for i = 1:length(AlignTime)
        if  isnan(CortexPresentationNr(i))
            AlignTime{i} = AlignTime{i}(1);
        else
            AlignTime{i} = AlignTime{i}(CortexPresentationNr(i));
        end
    end
end
AlignTime = cat(2,AlignTime{:}) + p.RasterAlignOffset;
SPK = spk_align(SPK,AlignTime,0);
%########################################################

for i = 1:length(t)
    currStimCode = stimCodes(t(i));
    currStimCodeTrials = find(stimCodes==currStimCode);
    numCurrStimCodeTrials = length(currStimCodeTrials);
    currStimCodeTrialNr = find(currStimCodeTrials==t(i));
    
    currRasterTrials = currStimCodeTrialNr-(p.RasterTrialNum-1):currStimCodeTrialNr;
    currRasterTrials(currRasterTrials<=0)=[];
    
    currTrialRasterTrialNr = find(currRasterTrials==currStimCodeTrialNr);
    if isempty(currTrialRasterTrialNr);continue;end % plot only if current trial is in range of current trials of raster 
    
    
   
    % set data of rasterlines
    SPK = spk_set(SPK,'currenttrials',t(i));
    Spikes = spk_gettrialdata(SPK,t,'spk');
    Events = spk_gettrialdata(SPK,t,'events');
    NumEvents = sum(cellfun('length',Events)==1);
    for j = 1:ChanIndexNum
        NumSpikes = length(Spikes{ChanIndex(j)});
        
        % shift raster trials downwards
        if currStimCodeTrialNr>p.RasterTrialNum
            for k=1:p.RasterTrialNum-1
                % assign raster data from raster line above the current one
                % (k+1)
                set(H(j).SpikeRasterLine(stimCodes(t(i)),k), ...
                    'xdata',get(H(j).SpikeRasterLine(stimCodes(t(i)),k+1),'xdata'), ...
                    'ydata',get(H(j).SpikeRasterLine(stimCodes(t(i)),k+1),'ydata')-1);
                set(H(j).EventRasterLine(stimCodes(t(i)),k), ...
                    'xdata',get(H(j).EventRasterLine(stimCodes(t(i)),k+1),'xdata'), ...
                    'ydata',get(H(j).EventRasterLine(stimCodes(t(i)),k+1),'ydata')-1);
            end
            % clear the top raster lne
            set(H(j).SpikeRasterLine(stimCodes(t(i)),currTrialRasterTrialNr), ...
                'xdata',NaN, ...
                'ydata',NaN);
            set(H(j).EventRasterLine(stimCodes(t(i)),currTrialRasterTrialNr), ...
                'xdata',NaN, ...
                'ydata',NaN);
        end
        % plot the current trial
        if NumSpikes>0 
            set(H(j).SpikeRasterLine(stimCodes(t(i)),currTrialRasterTrialNr), ...
                'xdata',Spikes{ChanIndex(j)}, ...
                'ydata',repmat(((StimCodeIndex(currStimCode)-1)*(p.RasterTrialNum+1)+currTrialRasterTrialNr),NumSpikes,1));
        end
        cEvXData = zeros(1,NumEvents).*NaN;
        cEvXData = cat(2,Events{cellfun('length',Events)==1});
        set(H(j).EventRasterLine(stimCodes(t(i)),currTrialRasterTrialNr), ...
            'xdata',cEvXData, ...
            'ydata',repmat(((StimCodeIndex(currStimCode)-1)*(p.RasterTrialNum+1)+currTrialRasterTrialNr),NumEvents,1));
        
        
        % plot histogram
        axes(H(j).HistAx(currStimCode))
        delete(findobj('parent',gca,'tag',['HistLine ' num2str(j) ' ' currStimCode]));
        SPK = spk_set(SPK, ...
            'currenttrials',currStimCodeTrials, ...
            'currentchan',ChanIndex(j));
        spk_histogram(SPK,p.RasterTimeLim,p.HistBinWidth,p.HistMode,'line', ...
            'tag',['HistLine ' num2str(j) ' ' currStimCode],'linewidth',0.25,'clipping','off','color',H(j).HistColor(currStimCode,:));
    
        % plot 0 ms
        line(0,0,'linestyle','none','marker','^','markerfacecolor','m','markeredgecolor','none','markersize',6);
        
        % set condition title
        set(findobj('tag',['cnd' num2str(stimCodes(t(i))) 'title']),'string',[num2str(blockCodes(t(i))) '/' num2str(cndCodes(t(i))) '/' num2str(stimCodes(t(i))) ' #' num2str(numCurrStimCodeTrials)]);
    end
    
end

% set YLim of histograms

for j = 1:ChanIndexNum
    NN = prod(size(p.Hist2Grid));
    cAx = unique(H(j).HistAx(:));
    NN = length(cAx);
    if p.HistYLimMode==1
        totMAX = repmat(p.HistYLim(2),NN);
    elseif p.HistYLimMode==2 | p.HistYLimMode==3
        totMAX = zeros(1,NN);
        for i = 1:NN
            currLine = findobj('type','line','parent',cAx(i));
            cndMAX = [];
            for k = currLine'
                cndMAX = cat(2,cndMAX,max(get(k,'ydata')));
            end
            cndMAX = max(cndMAX);
            if ~isempty(cndMAX) & cndMAX>0
                totMAX(i) = cndMAX;
            end
        end
    end
    for i = 1:NN
        axes(cAx(i));
        if p.HistYLimMode==1 & totMAX(i)~=0
            set(gca,'ylim',[0 totMAX(i)],'ytick',totMAX(i),'yticklabel',sprintf('%5.1f',totMAX(i)),'fontsize',8);
        elseif p.HistYLimMode==2 & totMAX(i)~=0
            set(gca,'ylim',[0 totMAX(i)],'ytick',totMAX(i),'yticklabel',sprintf('%5.1f',totMAX(i)),'fontsize',8);
        elseif p.HistYLimMode==3 & max(totMAX)~=0
            set(gca,'ylim',[0 max(totMAX)],'ytick',max(totMAX),'yticklabel',sprintf('%5.1f',max(totMAX)),'fontsize',8);
        end
    end
end