function nlx_control_rvco_STrf(t,varargin)

global SPK
global NLX_CONTROL_SETTINGS;

p = NLX_CONTROL_SETTINGS;
% check for existing channels in object
[ChannelName,activeEl] = nlx_control_gui_getSelectedChannel;
ChanIndex = spk_findSpikeChan(SPK,ChannelName);
ChanIndex(isnan(ChanIndex)) = [];
ChanIndexNum = length(ChanIndex);
ChanColor = NLX_CONTROL_SETTINGS.SpikeChanColor(1:ChanIndexNum,:);
SPK = spk_set(SPK,'currenttrials',[],'currentchan',ChanIndex);

ChanName = spk_get(SPK,'channel');

numTau = length(p.RVCOTau);


%++++++++++++++++++++++++++ make axes +++++++++++++++++++++++++++++++
% plot axes if there no axes in the main figure
for j = 1:ChanIndexNum
	if isempty(findobj('type','figure','tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}]))
     
		%******************************************************************************************************
		% prepare data structure
		% disentangle parameter
		DS(j).StimNum = size(p.RVCOStimArray,2);
		DS(j).Ori = p.RVCOStimArray(1,:);
		DS(j).Ori(DS(j).Ori>90) = 0-(180-DS(j).Ori(DS(j).Ori>90));
		DS(j).SF = p.RVCOStimArray(2,:);
		DS(j).Phase = p.RVCOStimArray(3,:);
		DS(j).uniOri = unique(DS(j).Ori);
		DS(j).uniSF = unique(DS(j).SF);
		DS(j).uniPhase = unique(DS(j).Phase);
		DS(j).SEQNum = DS(j).StimNum/p.Cndnum;
		DS(j).StimCnd = rem([0:DS(j).StimNum-1],p.Cndnum)+1;
		DS(j).TrialCount = zeros(1,DS(j).StimNum); %(X,Y,C)
		DS(j).SpikeCount = zeros(1,DS(j).StimNum,numTau); %(X,Y,C,Tau)
		DS(j).SpikeCountBase = zeros(1,DS(j).StimNum,1); %(X,Y,C,Tau)
        
        DS(j).Tau = p.RVCOTau;
        DS(j).TauBase = p.RVCOTauBase;
        DS(j).Win = p.RVCOWin;

		%******************************************************************************************************

		RVCOFigHandle(j) = figure( ...
			'tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}], ...
			'color','k', ...
			'numbertitle','off', ...
			'name',['nlx_control_rvco Channel ''' ChanName{ChanIndex(j)} ''''], ...
			'menubar','none');

        colormap(p.RVCOColormap);
        
		mapAx = subaxes(RVCOFigHandle(j),[length(DS(j).uniPhase) numTau],[],[0.1 0.05],[0.05,0.15,0.05,0.05]);
		set(mapAx, ...
			'units','normalized', ...
			'color',[0 0 0], ...
			'fontsize',8, ...
			'xcolor',[1 1 1], ...
			'ycolor',[1 1 1]);

		% 4 columns of maps
		for i=1:numTau
			for k=1:length(DS(j).uniPhase)
                axes(mapAx(k,i));
				set(gca,'tag',[num2str(DS(j).uniPhase(k)) ' ' num2str(p.RVCOTau(i))],'CLimMode','auto');
				surfaceprops = { ...
						'linestyle','none', ...
						'edgecolor','none', ...
						'facecolor','interp', ...
						'facelighting','phong', ...
						'cdatamapping','scaled'};
				surface(surfaceprops{:});
                
                line(NaN,NaN,'linestyle','none','marker','o','markeredgecolor','b','markerfacecolor','none','markersize',10,'tag',[num2str(DS(j).uniPhase(k)) ' ' num2str(p.RVCOTau(i))]);
			end
		end
		
        cMapAx = subaxes(RVCOFigHandle(j),[1 1],[],[0 0],[0.88,0.07,0.05,0.55]);
        set(cMapAx,'tag','colormap');

        % set userdata to data structure
		set(RVCOFigHandle(j),'userdata',DS(j));
		
	else
		RVCOFigHandle(j) = findobj('type','figure','tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}]);
	end
end

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% check trials in object
total = spk_TrialNum(SPK);
NumChan = spk_SpikeChanNum(SPK);
cndCodes = spk_getTrialcode(SPK,'CortexCondition');
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
% prepare/get Grid Histogram Data
% for j = 1:ChanIndexNum
% 	DS(j) = get(findobj('tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}],'type','figure'),'userdata');
% 	% process the sequence of presented dots for every trial
% 	for ct = t
% 		if length(t)>1;disp([num2str(ct) '/' num2str(t(end))]);end
%         
%         % get stimulus times
% 		SPK = spk_set(SPK,'currenttrials',ct,'currentchan',ChanIndex(j));
% 		CurrTrialStimOn = spk_getevents(SPK,'NLX_STIM_ON');
% 		CurrTrialStimOff = spk_getevents(SPK,'NLX_STIM_OFF');
% 		if length(CurrTrialStimOff{1})~=1;error('check stim off events');end;
% 		CurrRvcoWins = [CurrTrialStimOn{1}' [CurrTrialStimOn{1}(2:end) CurrTrialStimOff{1}]'];
% 		CurrRvcoWins = [CurrTrialStimOn{1}'+DS(j).Win(1) CurrTrialStimOn{1}'+DS(j).Win(2)];
%         
%         % get the valid stimulus sequence
%         ValidStimIndex = [StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2) : StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2)+StimParam{ct}(p.RFStimSeqIndex_ValidSEQNum,2)-1];
%         ValidParamIndex = [p.RFStimSeqIndex_SEQStart+(StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,2))-1 : StimParam{ct}(StimParamIndex_TotalNum,2)];
% 		
%         % get the SPIKES for last trial
%         CurrTrialRVCO = spk_revcorrtemp(SPK,{CurrRvcoWins(ValidStimIndex,:)},p.RVCOTau);%(num. of trials,num. of  stim.,temporal shifts,channel)
% 
%         % RESORT the stimulus sequence
% 		[sortSEQ,sortSEQindex] = sort(StimParam{ct}(ValidParamIndex,2)');
% 		currStimIndex = find(DS(j).StimCnd==cndCodes(ct));
% 		if length(sortSEQ)~=length(currStimIndex)
% 			error('presentation sequence error!');
% 		end
% 		
% 		% add data to Grid Histogram Data
% 		DS(j).TrialCount(currStimIndex) = DS(j).TrialCount(currStimIndex) + 1;
%         % BUG (fixed 10/04/2006) DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO;
%         DS(j).SpikeCount(1,currStimIndex,:) = DS(j).SpikeCount(1,currStimIndex,:) + CurrTrialRVCO(:,sortSEQindex,:);
%         
% 	end
% 	set(findobj('tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}],'type','figure'),'userdata',DS(j));
% end
for j = 1:ChanIndexNum
	DS(j) = get(findobj('tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}],'type','figure'),'userdata');
	% process the sequence of presented dots for every trial
	for ct = t
		if length(t)>1;disp([num2str(ct) '/' num2str(t(end))]);end
        
        % get stimulus times
		SPK = spk_set(SPK,'currenttrials',ct,'currentchan',ChanIndex(j));
		CurrTrialStimOn = spk_getEvents(SPK,'NLX_STIM_ON');
		CurrTrialStimOff = spk_getEvents(SPK,'NLX_STIM_OFF');
		if length(CurrTrialStimOff{1})~=1;error('check stim off events');end;
% 		CurrRvcoWins = [CurrTrialStimOn{1}' [CurrTrialStimOn{1}(2:end) CurrTrialStimOff{1}]'];
		CurrRvcoWins = [CurrTrialStimOn{1}'+DS(j).Win(1) CurrTrialStimOn{1}'+DS(j).Win(2)];
        
		switch p.RFStimSeqDecodingMethod
			case 1 %Index of current sequence;
		        % get index for stimulus events (ValidStimIndex) and for the stimulus parameter (ValidParamIndex)
		        ValidStimIndex = [StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,1) : StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,1)+StimParam{ct}(p.RFStimSeqIndex_ValidSEQNum,1)-1];
		        ValidParamIndex = [p.RFStimSeqIndex_SEQStart+(StimParam{ct}(p.RFStimSeqIndex_FirstValidNr,1))-1 : StimParam{ct}(p.RFStimSeqIndex_TotalNum,1)];
				ValidSEQ = StimParam{ct}(ValidParamIndex,1)';
                
                if size(CurrRvcoWins,1)<max(ValidStimIndex)
                    ValidStimWins = ones(length(ValidStimIndex),2).*NaN;
                else
                    ValidStimWins = CurrRvcoWins(ValidStimIndex,:);
                end
				
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
	set(findobj('tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}],'type','figure'),'userdata',DS(j));
end

% analyse data
for j = 1:ChanIndexNum
	
	DS(j).TrialCount(DS(j).TrialCount==0) = NaN;
	DS(j).SpikeCount = DS(j).SpikeCount./repmat(DS(j).TrialCount,[1 1 numTau]);% mean spikes over trials
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
%     clim(j,:) = [MinSpikes(j) MaxSpikes(j)];
%     if any(isnan(clim(j,:))) | length(clim(j,:))<2;clim(j,:)=[0 1];end
end

%--------------------------------------------------------------------------
% prepare plot

for j = 1:ChanIndexNum
	xtick = DS(j).uniOri;
	ytick = DS(j).uniSF;
	
	xlim = [xtick(1)-(xtick(end)-xtick(1))*0.05 xtick(end)+(xtick(end)-xtick(1))*0.05];
	ylim = [ytick(1)-(ytick(end)-ytick(1))*0.05 ytick(end)+(ytick(end)-ytick(1))*0.05];
	textX = xlim(1);
	textY = ylim(2);

	% plot map
	for TTT = 1:numTau
		for k=1:length(DS(j).uniPhase)
            maxSF = [];
            maxOri = [];
			[XDATA,YDATA] = meshgrid(DS(j).uniOri,DS(j).uniSF);
			ZDATA = zeros(length(DS(j).uniSF),length(DS(j).uniOri));
			for m=1:length(DS(j).uniOri)
				for n=1:length(DS(j).uniSF)
					x = find(DS(j).Ori==DS(j).uniOri(m) & DS(j).SF==DS(j).uniSF(n) & DS(j).Phase==DS(j).uniPhase(k));
					ZDATA(n,m) = DS(j).SpikeCount(1,x,TTT);
                    if (DS(j).SpikeCount(1,x,TTT)==MaxSpikes(j))
                        maxSF = cat(2,maxSF,DS(j).uniSF(n));
                        maxOri = cat(2,maxOri,DS(j).uniOri(m));
                    end
				end
			end
			
			axes(findobj('tag',[num2str(DS(j).uniPhase(k)) ' ' num2str(p.RVCOTau(TTT))],'parent',findobj('tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}],'type','figure')));
			title([num2str(DS(j).uniPhase(k)) ' ' num2str(p.RVCOTau(TTT))],'fontsize',8);
			text(textX,textY, ...
				['P=' num2str(DS(j).uniPhase(k)/pi) '*pi T=-' num2str(p.RVCOTau(TTT)) 'ms'], ...
				'fontsize',12,'horizontalalignment','left','verticalalignment','bottom','color','w');
					
			set(findobj('parent',gca,'type','surface'), ...
				'xdata',XDATA,...
				'ydata',YDATA, ...
				'zdata',ZDATA, ...
				'cdata',ZDATA);
			set(gca, ...
                'fontsize',6, ...
                'clim',[0 1], ...
				'xlim',xlim,'xtick',xtick,'xticklabel',DS(j).uniOri, ...
				'ylim',ylim,'ytick',ytick,'yticklabel',DS(j).uniSF);
            
            if isempty(p.RFMapCLim)
                clim = [MinSpikes(j) MaxSpikes(j)];
            else
                clim = p.RFMapCLim;
            end
            if any(isnan(clim)) || any(isinf(clim))
                clim = [0 1];
            end
            set(gca,'clim',clim);

            set(findobj('tag',[num2str(DS(j).uniPhase(k)) ' ' num2str(p.RVCOTau(TTT))],'parent',gca), ...
                'xdata',maxOri, ...
                'ydata',maxSF, ...
                'zdata',ones(1,length(maxSF))*(MaxSpikes(j)+MaxSpikes(j)*0.01));
		end
    end
    
    cColMap = findobj('tag','colormap','type','axes','parent',findobj('tag',['nlx_control_rvco_STrf ' ChanName{ChanIndex(j)}],'type','figure'));
    if ~isempty(cColMap)
        axes(cColMap);
        cla;
        set(cColMap,'clim',clim);
        cMapAx = coloraxes(cColMap,[],'v',3,[],'%1.1f',0,{'color','w'});
        set(cMapAx,'xcolor','w','ycolor','w','tag','colormap');
    end

end
