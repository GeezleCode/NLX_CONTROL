function nlx_control_RF_RVCO(t,varargin)

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

%++++++++++++++++++++++++++ make axes +++++++++++++++++++++++++++++++
% plot axes if there no axes in the main figure
for j = 1:ChanIndexNum
	if isempty(findobj('type','figure','tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}]))
     
		%******************************************************************************************************
		% prepare data structure
		% disentangle parameter
		DS(j).StimNum = size(p.RFDotPosX,2);
		
		DS(j).GridRowNr = p.RFMapRowNr;
		DS(j).GridColNr = p.RFMapColNr;
		DS(j).XPos = p.RFDotPosX;
		DS(j).YPos = p.RFDotPosY;
		DS(j).Lum = p.RFDotLum;

		DS(j).Tau = p.RVCOTau;
		DS(j).TauBase = p.RVCOTauBase;
		DS(j).Win = p.RVCOWin;

		DS(j).uniXPos = unique(DS(j).XPos);
		DS(j).uniYPos = unique(DS(j).YPos);
		DS(j).uniLum = unique(DS(j).Lum);

		DS(j).SEQNum = DS(j).StimNum/p.Cndnum;
		DS(j).StimCnd = rem([0:DS(j).StimNum-1],p.Cndnum)+1;% this is how the stimulus sequence is presented in CORTEX
		DS(j).TrialCount = zeros(1,DS(j).StimNum); %(X,Y,C)
		DS(j).SpikeCount = zeros(1,DS(j).StimNum,length(DS(j).Tau)); %(X,Y,C,Tau)
		DS(j).SpikeCountBase = zeros(1,DS(j).StimNum,1); %(X,Y,C,Tau)
		
		DS(j).FigColParam = DS(j).uniLum;
		DS(j).FigRowParam = DS(j).Tau;
		DS(j).xtick = [(p.RFMapImageResizeFactor+1)/2:p.RFMapImageResizeFactor:p.RFMapSize(2)*p.RFMapImageResizeFactor];
		DS(j).ytick = [(p.RFMapImageResizeFactor+1)/2:p.RFMapImageResizeFactor:p.RFMapSize(1)*p.RFMapImageResizeFactor];
        DS(j).xlim = [0.5 p.RFMapSize(2)*p.RFMapImageResizeFactor+0.5];
        DS(j).ylim = [0.5 p.RFMapSize(1)*p.RFMapImageResizeFactor+0.5];
%         [DS(j).XDATA,DS(j).YDATA] = meshgrid([1:p.RFMapSize(1)*p.RFMapImageResizeFactor],[1:p.RFMapSize(2)*p.RFMapImageResizeFactor]);


		%******************************************************************************************************
%% NON OPTO FIGS
		RVCOFigHandle(j) = figure( ...
			'tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}], ...
			'color','k', ...
			'numbertitle','off', ...
			'name',['nlx_control_RF_RVCO Channel ''' ChanName{ChanIndex(j)} ''''], ...
			'menubar','none');

        colormap(p.RFColormap);
        
        if length(DS(j).FigColParam)==1
            mapAx = subaxes(RVCOFigHandle(j), ...
                length(DS(j).FigRowParam),[], ...
                [0.1 0.05],[0.05,0.15,0.05,0.05]);
            mapAx = mapAx(:);
            
        else
            mapAx = subaxes(RVCOFigHandle(j), ...
                [length(DS(j).FigRowParam) length(DS(j).FigColParam)],[], ...
                [0.1 0.05],[0.05,0.15,0.05,0.05]);
        end
		
        set(mapAx, ...
			'units','normalized', ...
			'color',[0 0 0], ...
			'fontsize',6, ...
			'layer','top', ...
            'TickDir','out', ...
            'Box','on', ...
			'xcolor',[1 1 1], ...
			'ycolor',[1 1 1], ...
			'DataAspectRatio',[1 1 1], ...
            'CLimMode','auto', ...
            'xlim',DS(j).xlim,'xtick',DS(j).xtick,'xticklabel',DS(j).uniXPos, ...
            'ylim',DS(j).ylim,'ytick',DS(j).ytick,'yticklabel',fliplr(DS(j).uniYPos),'ydir','reverse');

		% 4 columns of maps
		for i=1:length(DS(j).FigColParam)
			for k=1:length(DS(j).FigRowParam)
                axes(mapAx(k,i));
 				set(gca,'tag',[num2str(DS(j).FigRowParam(k)) ' ' num2str(DS(j).FigColParam(i))]);
 				image( ...
 					'XData',[1:p.RFMapSize(2)*p.RFMapImageResizeFactor], ...
 					'YData',[1:p.RFMapSize(1)*p.RFMapImageResizeFactor], ...
 					'CData',ones(p.RFMapSize*p.RFMapImageResizeFactor), ...
 					'cdatamapping','scaled');
                line(NaN,NaN,'linestyle','none','marker','o','markeredgecolor','k','markerfacecolor','none','markersize',10,'tag','maxmarker');
% 				line([-0.1 0; 0.1 0],[0 -0.1;0 0.1],'linestyle','-','linewidth',1,'color','k','tag','crosshair');
			end
		end
		
        cMapAx = subaxes(RVCOFigHandle(j),[1 1],[],[0 0],[0.88,0.07,0.05,0.55]);
        set(cMapAx,'tag','colormap');

        % set userdata to data structure
		set(RVCOFigHandle(j),'userdata',DS(j));
		
	else
		RVCOFigHandle(j) = findobj('type','figure','tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}]);
   
    end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
  %% OPTO Figs      
  if isempty(findobj('type','figure','tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}]))
     
		%******************************************************************************************************
		% prepare data structure
		% disentangle parameter
		DS(j).StimNum = size(p.RFDotPosX,2);
		
		DS(j).GridRowNr = p.RFMapRowNr;
		DS(j).GridColNr = p.RFMapColNr;
		DS(j).XPos = p.RFDotPosX;
		DS(j).YPos = p.RFDotPosY;
		DS(j).Lum = p.RFDotLum;

		DS(j).Tau = p.RVCOTau;
		DS(j).TauBase = p.RVCOTauBase;
		DS(j).Win = p.RVCOWin;

		DS(j).uniXPos = unique(DS(j).XPos);
		DS(j).uniYPos = unique(DS(j).YPos);
		DS(j).uniLum = unique(DS(j).Lum);

		DS(j).SEQNum = DS(j).StimNum/p.Cndnum;
		DS(j).StimCnd = rem([0:DS(j).StimNum-1],p.Cndnum)+1;% this is how the stimulus sequence is presented in CORTEX
		DS(j).TrialCount = zeros(1,DS(j).StimNum); %(X,Y,C)
		DS(j).SpikeCount = zeros(1,DS(j).StimNum,length(DS(j).Tau)); %(X,Y,C,Tau)
		DS(j).SpikeCountBase = zeros(1,DS(j).StimNum,1); %(X,Y,C,Tau)
		
		DS(j).FigColParam = DS(j).uniLum;
		DS(j).FigRowParam = DS(j).Tau;
		DS(j).xtick = [(p.RFMapImageResizeFactor+1)/2:p.RFMapImageResizeFactor:p.RFMapSize(2)*p.RFMapImageResizeFactor];
		DS(j).ytick = [(p.RFMapImageResizeFactor+1)/2:p.RFMapImageResizeFactor:p.RFMapSize(1)*p.RFMapImageResizeFactor];
        DS(j).xlim = [0.5 p.RFMapSize(2)*p.RFMapImageResizeFactor+0.5];
        DS(j).ylim = [0.5 p.RFMapSize(1)*p.RFMapImageResizeFactor+0.5];
%         [DS(j).XDATA,DS(j).YDATA] = meshgrid([1:p.RFMapSize(1)*p.RFMapImageResizeFactor],[1:p.RFMapSize(2)*p.RFMapImageResizeFactor]);


		%******************************************************************************************************

		RVCOFigHandle2(j) = figure( ...
			'tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}], ...
			'color','k', ...
			'numbertitle','off', ...
			'name',['nlx_control_RF_RVCO_opto Channel ''' ChanName{ChanIndex(j)} ''''], ...
			'menubar','none');

        colormap(p.RFColormap);
        
        if length(DS(j).FigColParam)==1
            mapAx = subaxes(RVCOFigHandle2(j), ...
                length(DS(j).FigRowParam),[], ...
                [0.1 0.05],[0.05,0.15,0.05,0.05]);
            mapAx = mapAx(:);
            
        else
            mapAx = subaxes(RVCOFigHandle2(j), ...
                [length(DS(j).FigRowParam) length(DS(j).FigColParam)],[], ...
                [0.1 0.05],[0.05,0.15,0.05,0.05]);
        end
		
        set(mapAx, ...
			'units','normalized', ...
			'color',[0 0 0], ...
			'fontsize',6, ...
			'layer','top', ...
            'TickDir','out', ...
            'Box','on', ...
			'xcolor',[1 1 1], ...
			'ycolor',[1 1 1], ...
			'DataAspectRatio',[1 1 1], ...
            'CLimMode','auto', ...
            'xlim',DS(j).xlim,'xtick',DS(j).xtick,'xticklabel',DS(j).uniXPos, ...
            'ylim',DS(j).ylim,'ytick',DS(j).ytick,'yticklabel',fliplr(DS(j).uniYPos),'ydir','reverse');

		% 4 columns of maps
		for i=1:length(DS(j).FigColParam)
			for k=1:length(DS(j).FigRowParam)
                axes(mapAx(k,i));
 				set(gca,'tag',[num2str(DS(j).FigRowParam(k)) ' ' num2str(DS(j).FigColParam(i))]);
 				image( ...
 					'XData',[1:p.RFMapSize(2)*p.RFMapImageResizeFactor], ...
 					'YData',[1:p.RFMapSize(1)*p.RFMapImageResizeFactor], ...
 					'CData',ones(p.RFMapSize*p.RFMapImageResizeFactor), ...
 					'cdatamapping','scaled');
                line(NaN,NaN,'linestyle','none','marker','o','markeredgecolor','k','markerfacecolor','none','markersize',10,'tag','maxmarker');
% 				line([-0.1 0; 0.1 0],[0 -0.1;0 0.1],'linestyle','-','linewidth',1,'color','k','tag','crosshair');
			end
		end
		
        cMapAx = subaxes(RVCOFigHandle2(j),[1 1],[],[0 0],[0.88,0.07,0.05,0.55]);
        set(cMapAx,'tag','colormap');

        % set userdata to data structure
		set(RVCOFigHandle2(j),'userdata',DS(j));
		
	else
		RVCOFigHandle2(j) = findobj('type','figure','tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}]);
   
    end
    %% END OPTO FIGS
  
end

%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% check trials in object
total = spk_TrialNum(SPK);
NumChan = spk_SpikeChanNum(SPK);
cndCodes = spk_getTrialcode(SPK,'CortexCondition');
optoCodes = spk_getTrialcode(SPK,'StimulusCode');
cndtrials = unique(cndCodes);
if total==0;return;end % return if the object is empty
if isempty(t);t=1:total;end % set t to all the trials if it's empty

%--------------------------------------------------------------------------
%  get the trial sequence from object
StimParam = spk_get(SPK,'stimulus');

%  check consistency of sequence
StimParamNum = unique(cellfun('size',StimParam,1));
StimParamDim = unique(cellfun('size',StimParam,2));
if any([length(StimParamNum) length(StimParamDim)]>1)
    error('stimulus information in SPK object is inconsistent !')
end

%--------------------------------------------------------------------------
% prepare/get Grid Histogram Data NON OPTO

if optoCodes(length(optoCodes))==0
    
    for j = 1:ChanIndexNum
        DS(j) = get(findobj('tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}],'type','figure'),'userdata');
        % process the sequence of presented dots for every trial
        for ct = t
            if length(t)>1;disp([num2str(ct) '/' num2str(t(end))]);end

            % get stimulus times
            SPK = spk_set(SPK,'currenttrials',ct,'currentchan',ChanIndex(j));
            CurrTrialStimOn = spk_getevents(SPK,'NLX_STIM_ON');
            CurrTrialStimOff = spk_getevents(SPK,'NLX_STIM_OFF');
            if length(CurrTrialStimOff{1})~=1;error('check stim off events');end;
    % 		CurrRvcoWins = [CurrTrialStimOn{1}' [CurrTrialStimOn{1}(2:end) CurrTrialStimOff{1}]'];
            CurrRvcoWins = [CurrTrialStimOn{1}'+DS(j).Win(1) CurrTrialStimOn{1}'+DS(j).Win(2)];

            switch p.RFStimSeqDecodingMethod
                case 1 %Index of current sequence;
                    % get index for stimulus events (ValidStimIndex) and for the stimulus parameter (ValidParamIndex)
                    ValidStimIndex = [StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2) : StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2)+StimParam{ct}(p.RFStimSeqIndex_ValidSEQNum,2)-1];
                    ValidParamIndex = [p.RFStimSeqIndex_SEQStart+(StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2))-1 : StimParam{ct}(p.RFStimSeqIndex_TotalNum,2)];
                    ValidSEQ = StimParam{ct}(ValidParamIndex,2)';
                    ValidStimWins = CurrRvcoWins(ValidStimIndex,:);

                    % RESORT the stimulus sequence
                    [sortSEQ,sortSEQindex] = sort(ValidSEQ);
                    currStimIndex = find(DS(j).StimCnd==cndCodes(ct));
                    if length(sortSEQ)~=length(currStimIndex)
                        error('presentation sequence error!');
                    end

                    % get the SPIKES for last trial
                    CurrTrialRVCO = spk_revcorrtemp(SPK,{ValidStimWins},DS(j).Tau);%(num. of trials,num. of  stim.,temporal shifts,channel)
                    CurrBaseRVCO = spk_revcorrtemp(SPK,{ValidStimWins},DS(j).TauBase);%(num. of trials,num. of  stim.,temporal shifts,channel)

                    % add data to Grid Histogram Data
                    DS(j).TrialCount(currStimIndex) = DS(j).TrialCount(currStimIndex) + 1;
                    % BUG (fixed 10/04/2006) DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO;
                    DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO(:,sortSEQindex,:);
                    DS(j).SpikeCountBase(1,currStimIndex) = DS(j).SpikeCountBase(1,currStimIndex) + CurrBaseRVCO(:,sortSEQindex);

                case 2 %Index of all stimuli
                    currStimIndex = StimParam{ct}(p.RFStimSeqIndex_SEQStart:end,1);
                    % get the SPIKES for last trial
                    CurrTrialRVCO = spk_revcorrtemp(SPK,{CurrRvcoWins},DS(j).Tau);%(num. of trials,num. of  stim.,temporal shifts,channel)
                    CurrBaseRVCO = spk_revcorrtemp(SPK,{CurrRvcoWins},DS(j).TauBase);%(num. of trials,num. of  stim.,temporal shifts,channel)

                    DS(j).TrialCount(currStimIndex) = DS(j).TrialCount(currStimIndex) + 1;
                    DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO;
                    DS(j).SpikeCountBase(1,currStimIndex,:) = DS(j).SpikeCountBase(1,currStimIndex) + CurrBaseRVCO;
            end
        end
        set(findobj('tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}],'type','figure'),'userdata',DS(j));
    end

    % analyse data
    for j = 1:ChanIndexNum

        DS(j).TrialCount(DS(j).TrialCount==0) = NaN;
        DS(j).SpikeCount = DS(j).SpikeCount./repmat(DS(j).TrialCount,[1 1 length(DS(j).Tau)]);% mean spikes over trials
        DS(j).SpikeCountBase = DS(j).SpikeCountBase./DS(j).TrialCount;% mean spikes over trials
        DS(j).SpikeCount(isnan(DS(j).SpikeCount)) = 0;

        % convert to Z-Score
        if p.RFMapZScoreFlag
            NonZeroStims = ~isnan(DS(j).TrialCount);
            DS(j).SpikeCount = (DS(j).SpikeCount-mean(DS(j).SpikeCountBase(1,NonZeroStims)))./std(DS(j).SpikeCountBase(1,NonZeroStims));
        end

        MaxSpikes(j) = max(DS(j).SpikeCount(:));
        MinSpikes(j) = min(DS(j).SpikeCount(:));
        if MaxSpikes(j)<1;MaxSpikes(j) = 1;end
    end

    %--------------------------------------------------------------------------
    % prepare plot
    ColBarH = zeros(length(DS(j).FigColParam),length(DS(j).FigRowParam),ChanIndexNum);

    for j = 1:ChanIndexNum
        textX = DS(j).xlim(1);
        textY = DS(j).ylim(1);

        % plot map
        for cFigCol = 1:length(DS(j).FigColParam)
            for cFigRow = 1:length(DS(j).FigRowParam)

                ZDATAraw = zeros(p.RFMapSize);
                ZDATA = zeros(p.RFMapSize.*p.RFMapImageResizeFactor);
                cLumIndex = (DS(j).Lum==DS(j).FigColParam(cFigCol));
                cMapIndex = sub2ind(p.RFMapSize,DS(j).GridRowNr(cLumIndex),DS(j).GridColNr(cLumIndex));
                ZDATAraw(cMapIndex) = DS(j).SpikeCount(1,cLumIndex,cFigRow);
    % 			ZDATA = imresize(ZDATAraw,p.RFMapImageResizeFactor,p.RFMapImageResizeInterpolation,p.RFMapImageResizeFilterOrder);
                ZDATA = imresize_old(ZDATAraw,p.RFMapImageResizeFactor,p.RFMapImageResizeInterpolation,p.RFMapImageResizeFilterOrder);

                axes(findobj('tag',[num2str(DS(j).FigRowParam(cFigRow)) ' ' num2str(DS(j).FigColParam(cFigCol))],'parent',findobj('tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}],'type','figure')));


                set(findobj('parent',gca,'type','image'),'cdata',ZDATA);

                if isempty(p.RFMapCLim)
                    clim = [MinSpikes(j) MaxSpikes(j)];
                else
                    clim = p.RFMapCLim;
                end
                if any(isnan(clim)) || any(isinf(clim))
                    clim = [0 1];
                end
                set(gca,'clim',clim);

                ctitle = findobj('parent',gca,'tag','axestitle');
                if ~isempty(ctitle)
                    set(ctitle,'string',[num2str(DS(j).FigRowParam(cFigRow)) ' ' num2str(DS(j).FigColParam(cFigCol)) ' ' sprintf('Scale: %3.1f-%3.1f',MinSpikes(j),MaxSpikes(j))]);
                else
                    text(textX,textY, ...
                        [num2str(DS(j).FigRowParam(cFigRow)) ' ' num2str(DS(j).FigColParam(cFigCol)) ' ' sprintf('Scale: %3.1f-%3.1f',MinSpikes(j),MaxSpikes(j))], ...
                        'fontsize',10,'horizontalalignment','left','verticalalignment','bottom','color','w','tag','axestitle');
                end

    %             ColBarH(cFigCol,cFigRow,j) = coloraxes(cColMap,[1.1 0.10 0.1 0.8],'v');

    %             ColBarH = colorbar;

    %             set(ColBarH,'xcolor','w','ycolor','w');
    %             if p.RFMapZScoreFlag
    %                 set(get(ColBarH,'title'),'string','Z','visible','on','color','w');
    %             else
    %                 set(get(ColBarH,'title'),'string','Cnt','visible','on','color','w');
    %             end

            end
        end


        cColMap = findobj('tag','colormap','type','axes','parent',findobj('tag',['nlx_control_RF_RVCO ' ChanName{ChanIndex(j)}],'type','figure'));
        if ~isempty(cColMap)
            axes(cColMap);
            cla;
            set(cColMap,'clim',clim);
            cMapAx = coloraxes(cColMap,[],'v',3,[],'%1.1f',0,{'color','w'});
            set(cMapAx,'xcolor','w','ycolor','w','tag','colormap');
        end

    end
    
else

            for j = 1:ChanIndexNum
        DS(j) = get(findobj('tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}],'type','figure'),'userdata');
        % process the sequence of presented dots for every trial
        for ct = t
            if length(t)>1;disp([num2str(ct) '/' num2str(t(end))]);end

            % get stimulus times
            SPK = spk_set(SPK,'currenttrials',ct,'currentchan',ChanIndex(j));
            CurrTrialStimOn = spk_getevents(SPK,'NLX_STIM_ON');
            CurrTrialStimOff = spk_getevents(SPK,'NLX_STIM_OFF');
            if length(CurrTrialStimOff{1})~=1;error('check stim off events');end;
    % 		CurrRvcoWins = [CurrTrialStimOn{1}' [CurrTrialStimOn{1}(2:end) CurrTrialStimOff{1}]'];
            CurrRvcoWins = [CurrTrialStimOn{1}'+DS(j).Win(1) CurrTrialStimOn{1}'+DS(j).Win(2)];

            switch p.RFStimSeqDecodingMethod
                case 1 %Index of current sequence;
                    % get index for stimulus events (ValidStimIndex) and for the stimulus parameter (ValidParamIndex)
                    ValidStimIndex = [StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2) : StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2)+StimParam{ct}(p.RFStimSeqIndex_ValidSEQNum,2)-1];
                    ValidParamIndex = [p.RFStimSeqIndex_SEQStart+(StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2))-1 : StimParam{ct}(p.RFStimSeqIndex_TotalNum,2)];
                    ValidSEQ = StimParam{ct}(ValidParamIndex,2)';
                    ValidStimWins = CurrRvcoWins(ValidStimIndex,:);

                    % RESORT the stimulus sequence
                    [sortSEQ,sortSEQindex] = sort(ValidSEQ);
                    currStimIndex = find(DS(j).StimCnd==cndCodes(ct));
                    if length(sortSEQ)~=length(currStimIndex)
                        error('presentation sequence error!');
                    end

                    % get the SPIKES for last trial
                    CurrTrialRVCO = spk_revcorrtemp(SPK,{ValidStimWins},DS(j).Tau);%(num. of trials,num. of  stim.,temporal shifts,channel)
                    CurrBaseRVCO = spk_revcorrtemp(SPK,{ValidStimWins},DS(j).TauBase);%(num. of trials,num. of  stim.,temporal shifts,channel)

                    % add data to Grid Histogram Data
                    DS(j).TrialCount(currStimIndex) = DS(j).TrialCount(currStimIndex) + 1;
                    % BUG (fixed 10/04/2006) DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO;
                    DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO(:,sortSEQindex,:);
                    DS(j).SpikeCountBase(1,currStimIndex) = DS(j).SpikeCountBase(1,currStimIndex) + CurrBaseRVCO(:,sortSEQindex);

                case 2 %Index of all stimuli
                    currStimIndex = StimParam{ct}(p.RFStimSeqIndex_SEQStart:end,1);
                    % get the SPIKES for last trial
                    CurrTrialRVCO = spk_revcorrtemp(SPK,{CurrRvcoWins},DS(j).Tau);%(num. of trials,num. of  stim.,temporal shifts,channel)
                    CurrBaseRVCO = spk_revcorrtemp(SPK,{CurrRvcoWins},DS(j).TauBase);%(num. of trials,num. of  stim.,temporal shifts,channel)

                    DS(j).TrialCount(currStimIndex) = DS(j).TrialCount(currStimIndex) + 1;
                    DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO;
                    DS(j).SpikeCountBase(1,currStimIndex,:) = DS(j).SpikeCountBase(1,currStimIndex) + CurrBaseRVCO;
            end
        end
        set(findobj('tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}],'type','figure'),'userdata',DS(j));
    end

    % analyse data
    for j = 1:ChanIndexNum

        DS(j).TrialCount(DS(j).TrialCount==0) = NaN;
        DS(j).SpikeCount = DS(j).SpikeCount./repmat(DS(j).TrialCount,[1 1 length(DS(j).Tau)]);% mean spikes over trials
        DS(j).SpikeCountBase = DS(j).SpikeCountBase./DS(j).TrialCount;% mean spikes over trials
        DS(j).SpikeCount(isnan(DS(j).SpikeCount)) = 0;

        % convert to Z-Score
        if p.RFMapZScoreFlag
            NonZeroStims = ~isnan(DS(j).TrialCount);
            DS(j).SpikeCount = (DS(j).SpikeCount-mean(DS(j).SpikeCountBase(1,NonZeroStims)))./std(DS(j).SpikeCountBase(1,NonZeroStims));
        end

        MaxSpikes(j) = max(DS(j).SpikeCount(:));
        MinSpikes(j) = min(DS(j).SpikeCount(:));
        if MaxSpikes(j)<1;MaxSpikes(j) = 1;end
    end

    %--------------------------------------------------------------------------
    % prepare plot
    ColBarH = zeros(length(DS(j).FigColParam),length(DS(j).FigRowParam),ChanIndexNum);

    for j = 1:ChanIndexNum
        textX = DS(j).xlim(1);
        textY = DS(j).ylim(1);

        % plot map
        for cFigCol = 1:length(DS(j).FigColParam)
            for cFigRow = 1:length(DS(j).FigRowParam)

                ZDATAraw = zeros(p.RFMapSize);
                ZDATA = zeros(p.RFMapSize.*p.RFMapImageResizeFactor);
                cLumIndex = (DS(j).Lum==DS(j).FigColParam(cFigCol));
                cMapIndex = sub2ind(p.RFMapSize,DS(j).GridRowNr(cLumIndex),DS(j).GridColNr(cLumIndex));
                ZDATAraw(cMapIndex) = DS(j).SpikeCount(1,cLumIndex,cFigRow);
    % 			ZDATA = imresize(ZDATAraw,p.RFMapImageResizeFactor,p.RFMapImageResizeInterpolation,p.RFMapImageResizeFilterOrder);
                ZDATA = imresize_old(ZDATAraw,p.RFMapImageResizeFactor,p.RFMapImageResizeInterpolation,p.RFMapImageResizeFilterOrder);

                axes(findobj('tag',[num2str(DS(j).FigRowParam(cFigRow)) ' ' num2str(DS(j).FigColParam(cFigCol))],'parent',findobj('tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}],'type','figure')));


                set(findobj('parent',gca,'type','image'),'cdata',ZDATA);

                if isempty(p.RFMapCLim)
                    clim = [MinSpikes(j) MaxSpikes(j)];
                else
                    clim = p.RFMapCLim;
                end
                if any(isnan(clim)) || any(isinf(clim))
                    clim = [0 1];
                end
                set(gca,'clim',clim);

                ctitle = findobj('parent',gca,'tag','axestitle');
                if ~isempty(ctitle)
                    set(ctitle,'string',[num2str(DS(j).FigRowParam(cFigRow)) ' ' num2str(DS(j).FigColParam(cFigCol)) ' ' sprintf('Scale: %3.1f-%3.1f',MinSpikes(j),MaxSpikes(j))]);
                else
                    text(textX,textY, ...
                        [num2str(DS(j).FigRowParam(cFigRow)) ' ' num2str(DS(j).FigColParam(cFigCol)) ' ' sprintf('Scale: %3.1f-%3.1f',MinSpikes(j),MaxSpikes(j))], ...
                        'fontsize',10,'horizontalalignment','left','verticalalignment','bottom','color','w','tag','axestitle');
                end

    %             ColBarH(cFigCol,cFigRow,j) = coloraxes(cColMap,[1.1 0.10 0.1 0.8],'v');

    %             ColBarH = colorbar;

    %             set(ColBarH,'xcolor','w','ycolor','w');
    %             if p.RFMapZScoreFlag
    %                 set(get(ColBarH,'title'),'string','Z','visible','on','color','w');
    %             else
    %                 set(get(ColBarH,'title'),'string','Cnt','visible','on','color','w');
    %             end

            end
        end


        cColMap = findobj('tag','colormap','type','axes','parent',findobj('tag',['nlx_control_RF_RVCO_opto ' ChanName{ChanIndex(j)}],'type','figure'));
        if ~isempty(cColMap)
            axes(cColMap);
            cla;
            set(cColMap,'clim',clim);
            cMapAx = coloraxes(cColMap,[],'v',3,[],'%1.1f',0,{'color','w'});
            set(cMapAx,'xcolor','w','ycolor','w','tag','colormap');
        end
    
    end

end

end
