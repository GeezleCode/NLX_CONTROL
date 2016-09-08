function nlx_control_raster(t,varargin)

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
ChanIndex = spk_findchannel(SPK,ChannelName);
ChanIndexNum = length(ChanIndex);
ChanColor = NLX_CONTROL_SETTINGS.SpikeChanColor(1:ChanIndexNum,:);
SPK = spk_set(SPK,'currenttrials',[]);

[PlotRowNum,PlotColNum] = size(p.StimCodeGrid);
PlotTotalNum = PlotRowNum * PlotColNum;

%++++++++++++++++++++++++++ make axes +++++++++++++++++++++++++++++++
RasterFigHandle = findobj('type','figure','tag','nlx_control_raster');
% plot axes if there no axes in the main figure
if isempty(RasterFigHandle)
    H.SpikeRasterLine = [];
    H.EventRasterLine = [];
    RasterFigHandle = figure( ...
        'tag','nlx_control_raster', ...
        'color','k', ...
        'numbertitle','off', ...
        'name','nlx_control_raster', ...
        'menubar','none', ...
        'userdata',H);
    
    CndAx = subaxes(RasterFigHandle,[PlotRowNum,PlotColNum],[],[0.01 0.01],[0.01,0.01,0.01,0.01]);
    
    for i = 1:PlotRowNum
        for j = 1:PlotColNum

            axes(CndAx(i,j));
            set(gca,'tag',['raster' num2str(p.StimCodeGrid(i,j))], ...
                'color','k','visible','off', ...
                'xcolor',[1 1 1],'xticklabel','','xlim',p.RasterTimeLim, ...
                'ycolor',[1 1 1],'yticklabel','','ylim',[0 ChanIndexNum*(p.RasterTrialNum+1)]);
            if isnan(p.StimCodeGrid(i,j)) | p.StimCodeGrid(i,j)==0;continue;end
            for k = 1:p.RasterTrialNum
                for m = 1:ChanIndexNum
                    H.SpikeRasterLine(p.StimCodeGrid(i,j),m,k) = line(NaN,NaN, ...
                        'tag',['spikeraster#' num2str(p.StimCodeGrid(i,j)) '#' num2str(m) '#' num2str(k)], ...
                        'linestyle','none', ...
                        'marker','o','markeredgecolor','none','markerfacecolor',ChanColor(m,:),'markersize',p.RasterDotSize, ...
                        'clipping','on');
                    H.EventRasterLine(p.StimCodeGrid(i,j),m,k) = line(NaN,NaN, ...
                        'tag',['eventraster#' num2str(p.StimCodeGrid(i,j)) '#' num2str(m) '#' num2str(k)], ...
                        'linestyle','none', ...
                        'marker','o','markeredgecolor','none','markerfacecolor',p.EventColor(1,:),'markersize',p.RasterDotSize, ...
                        'clipping','on');
                end
            end
            ylim = get(gca,'ylim');
%             text(p.RasterTimeLim(1)+(p.RasterTimeLim(2)-p.RasterTimeLim(1)).*0.5,ylim(1)+(ylim(2)-ylim(1)).*0.75, ...
            text(p.RasterTimeLim(1),ylim(2), ...
                [num2str(p.StimCodeGrid(i,j))], ...
                'tag',['cnd' num2str(p.StimCodeGrid(i,j)) 'title'],'fontsize',10,'color',[1 1 1],'horizontalalignment','left','verticalalignment','middle');
           
        end
    end
    set(RasterFigHandle,'userdata',H);
    H=[];
end

%++++++++++++++++++++++++++ plot the data +++++++++++++++++++++++++++++++
H = get(RasterFigHandle,'userdata');
total = spk_numtrials(SPK);
NumChan = spk_numchan(SPK);
if total==0;return;end % return if the object is empty
if isempty(t);t=1:total;end % set t to all the trials if it's empty

% trial identifiers
blockCodes = spk_gettrialcodes(SPK,'CortexBlock');
cndCodes = spk_gettrialcodes(SPK,'CortexCondition');
stimCodes = spk_gettrialcodes(SPK,'StimulusCode');
if all(isnan(stimCodes))
    stimCodes = (blockCodes-1).*p.Cndnum+cndCodes;
end

if ~all(ismember(cndCodes(t),p.StimCodeGrid)) | cndCodes(t)<1
    error('Simulus code is not found in StimCodeGrid in settings!');
end

%######################################################3
% align timestamps to p.RasterAlignEvent
SPK = spk_set(SPK,'currenttrials',[]);
CortexPresentationNr = spk_gettrialcodes(SPK,'CortexPresentationNr');
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
    Spikes = spk_gettrialdata(SPK,'spk');
    Events = spk_gettrialdata(SPK,'events');
    NumEvents = sum(cellfun('length',Events),1);
    for j = 1:ChanIndexNum
        NumSpikes = length(Spikes{ChanIndex(j)});
        
        % shift raster trials downwards
        if currStimCodeTrialNr>p.RasterTrialNum
            for k=1:p.RasterTrialNum-1
                % assign raster data from raster line above the current one
                % (k+1)
                set(H.SpikeRasterLine(stimCodes(t(i)),j,k), ...
                    'xdata',get(H.SpikeRasterLine(stimCodes(t(i)),j,k+1),'xdata'), ...
                    'ydata',get(H.SpikeRasterLine(stimCodes(t(i)),j,k+1),'ydata')-1);
                set(H.EventRasterLine(stimCodes(t(i)),j,k), ...
                    'xdata',get(H.EventRasterLine(stimCodes(t(i)),j,k+1),'xdata'), ...
                    'ydata',get(H.EventRasterLine(stimCodes(t(i)),j,k+1),'ydata')-1);
            end
            % clear the top raster lne
            set(H.SpikeRasterLine(stimCodes(t(i)),j,currTrialRasterTrialNr), ...
                'xdata',NaN, ...
                'ydata',NaN);
            set(H.EventRasterLine(stimCodes(t(i)),j,currTrialRasterTrialNr), ...
                'xdata',NaN, ...
                'ydata',NaN);
        end
        % plot the current trial
        if NumSpikes>0 
            set(H.SpikeRasterLine(stimCodes(t(i)),j,currTrialRasterTrialNr), ...
                'xdata',Spikes{ChanIndex(j)}, ...
                'ydata',repmat(((j-1)*(p.RasterTrialNum+1)+currTrialRasterTrialNr),NumSpikes,1));
        end
        set(H.EventRasterLine(stimCodes(t(i)),j,currTrialRasterTrialNr), ...
            'xdata',cat(2,Events{:}), ...
            'ydata',repmat(((j-1)*(p.RasterTrialNum+1)+currTrialRasterTrialNr),NumEvents,1));
    end
    
    % set condition title
    set(findobj('tag',['cnd' num2str(stimCodes(t(i))) 'title']),'string',[num2str(blockCodes(t(i))) '/' num2str(cndCodes(t(i))) '/' num2str(stimCodes(t(i))) ' #' num2str(numCurrStimCodeTrials)]);
    
end