function s = spk_CORTEXread(s,CTXpath,par,ReadEyeDataFlag,ReadEPPFlag)

% read a cortex file into SPK structure
% s = spk_CORTEXread(s,CTXpath,par,ReadEyeDataFlag)
%
% par fields:
% Cndnum .................................
% Blocknum ...............................
% PresentationNum ........................
% CutCortexTrial .........................
% TrialParamN ............................
% TrialParamLabel{1} .....................
% StimParamN .............................
% EyeStartEventName ......................
% EyeStartEventCode ......................
% HeadLabelEyeRate .........................
% AlignEventName .........................
% AlignEventCode .........................
% EventCodes ............................. {n,1}=name {n,2}=code
% HeaderLabel ......................... {n}=name
% ResponseError ....................... {n,1}=name {n,2}=code

if nargin<5
    ReadEPPFlag = false;
    if nargin<4
        ReadEyeDataFlag = false;
    end;end

s.file = CTXpath;
s.timeorder = -3;% unit of time is msec
s.date = datestr(now);


%% read the file
[CtxEv,CtxEOG,CtxEPP,CtxHead] = ctx_read(CTXpath,[1 1 1]);
NumTr = length(CtxEv);
if NumTr==0
    return;
end

%% read header to trialcodes
nHd = size(CtxHead,1);
s.trialcodelabel = cell(nHd,1);
s.trialcode = zeros(nHd,NumTr).*NaN;
for iTC = 1:nHd
    s.trialcodelabel(iTC) = par.CTXHeaderLabel(iTC);
    for iTr = 1:NumTr
        s.trialcode(iTC,iTr) = CtxHead(iTC,iTr);
    end
end
nTC = size(s.trialcode,1);

% change Block and Condition from 0,...,n-1 to 1,...,n
s.trialcode(2,:) = s.trialcode(2,:)+1;%cond_no
s.trialcode(4,:) = s.trialcode(4,:)+1;%block_no

%% extract trial parameter
TrialParam = zeros(par.TrialParamN,NumTr).*NaN;
if par.TrialParamN>0
    for iTr = 1:NumTr
        if par.TrialParamWin(1)==par.TrialParamWin(2)
            TrialParamWin = find(CtxEv{iTr}(:,2)==par.TrialParamWin(1))';
            if length(TrialParamWin)~=2;
                error('Too many trial start events!!');
            end
        else 
            TrialParamWin(1) = find(CtxEv{iTr}(:,2)==par.TrialParamWin(1));
            TrialParamWin(2) = find(CtxEv{iTr}(:,2)==par.TrialParamWin(2));
        end
        cParArray = CtxEv{iTr}(TrialParamWin(1)+1:TrialParamWin(2)-1,2)-par.ParamBase;
       TrialParam(1:length(cParArray),iTr) = cParArray;
        % delete parameter from events
        CtxEv{iTr}(TrialParamWin(1):TrialParamWin(2),:) = [];
    end
    
    % import TrialParam as trialcode
    s.trialcodelabel(end+1:end+par.TrialParamN) = par.TrialParamLabel;
    s.trialcode(end+1:end+par.TrialParamN,:) = TrialParam;
    nTC = size(s.trialcode,1);
end

%% extract stim parameter
if par.StimParamN(1)>0
    for iTr = 1:NumTr
        StimParWin1 = find(CtxEv{iTr}(:,2)==par.StimParamWin(1));
        StimParWin2 = find(CtxEv{iTr}(:,2)==par.StimParamWin(2));
        nStim1 = length(StimParWin1);
        nStim2 = length(StimParWin2);
        StimParam{1,iTr} = zeros(par.StimParamN).*NaN;
        if nStim1~=nStim2;error('');end
        for iStim = 1:nStim1
            StimParam{iTr}(:,iStim) = CtxEv{iTr}(StimParWin1(iStim)+1:StimParWin2(iStim)-1,2)-par.ParamBase;
        end
    end
    
    % import StimParam as trialcode
    if ~isempty(par.StimParamToTrialcode)% StimParam have to be indicated by par.StimParamToTrialcode
        nTC = size(s.trialcode,1);
        for i = 1:length(par.StimParamToTrialcode)
            for j = 1:par.StimParamN(2)
                iTC = nTC+(i-1)*par.StimParamN(2)+j;
                s.trialcodelabel{iTC} = sprintf('%s#%1.0f',par.StimParamLabel{par.StimParamToTrialcode(i)},j);
                for iTr = 1:NumTr
                    s.trialcode(iTC,iTr) = StimParam{iTr}(par.StimParamToTrialcode(i),j);
                end
            end
        end
    end
    
    s.stimulus = StimParam;
end

%% check events 
UniEv = cat(1,CtxEv{:});
UniEv = unique(UniEv(:,2));
[TF,LOC] = ismember(UniEv,cat(1,par.EventCodes{:,2}));
s.eventlabel = par.EventCodes(LOC(TF),1);
eventcode = UniEv(TF);
nEv = length(s.eventlabel);
s.events = cell(nEv,NumTr);
if ~isempty(par.Align2NeuralynxEvent)
    s.alignevent = s.eventlabel{eventcode==par.Align2NeuralynxEvent};
end

%% get events and align
for iTr = 1:NumTr
    if ~isempty(par.Align2NeuralynxEvent)
        cAlignTime = CtxEv{iTr}(CtxEv{iTr}(:,2) == par.Align2NeuralynxEvent,1);
        if isempty(cAlignTime)
            s.align(iTr) = NaN;
        else
            s.align(iTr) = cAlignTime;
        end
    else
        s.align(iTr) = 0;
    end
    for iEv = 1:nEv
        s.events{iEv,iTr} = CtxEv{iTr}(CtxEv{iTr}(:,2)==eventcode(iEv),1) - s.align(iTr);
    end
end

%% EOG: add analog channel
if ReadEyeDataFlag && any(~cellfun('isempty',CtxEOG)) && any(CtxHead(strcmp('eog_size',par.CTXHeaderLabel),:)>0)
    par.HeadLabelEyeRate = 'eye_storage_rate';
    EyeSampRate = unique(s.trialcode(strcmp(par.HeadLabelEyeRate,s.trialcodelabel),:));
    nACh = length(s.analog);
    s.analogname{nACh+1} = 'EOGX';
    s.analogname{nACh+2} = 'EOGY';
    s.analogfreq(nACh+1) = 1000/EyeSampRate;
    s.analogfreq(nACh+2) = s.analogfreq(nACh+1);
    s.analogunits{nACh+1} = 'digital';
    s.analogunits{nACh+2} = 'digital';
    
    EOGX = cell(1,NumTr);
    EOGY = cell(1,NumTr);
    AlignBin = ones(1,NumTr);
    
    for iTr = 1:NumTr
        % the time between each element in the stored EOG array is
        % par.HeadLabelEyeRate/2
        n = length(CtxEOG{iTr})/2;
        EyeStartTime = CtxEv{iTr}(CtxEv{iTr}(:,2) == par.EyeStartEventCode,1);
        ReadStartTime = CtxEv{iTr}(CtxEv{iTr}(:,2) == par.ReadDataStartEventCode,1);
        
        if n ==0 || isempty(EyeStartTime) || isempty(ReadStartTime)
            EOGX{iTr} = NaN;
            EOGY{iTr} = NaN;
            AlignBin(iTr) = 1;
        else
            EOGX{iTr} = CtxEOG{iTr}(1:2:end-1);
            EOGY{iTr} = CtxEOG{iTr}(2:2:end);
            EOGX{iTr} = EOGX{iTr}(:)';
            EOGY{iTr} = EOGY{iTr}(:)';
            t = [0:EyeSampRate:(n-1)*EyeSampRate] + EyeStartTime;
            [dTReadStart,ReadStartBin] = min(abs(t - ReadStartTime - par.ReadDataOffset));
            EOGX{iTr} = EOGX{iTr}(:,ReadStartBin:end);
            EOGY{iTr} = EOGY{iTr}(:,ReadStartBin:end);
            t = t(ReadStartBin:end)-s.align(iTr);
            [dTalign,AlignBin(iTr)] = min(abs(t));
        end
    end
    
    % merge cells to matrix
    AlignArray = [ones(NumTr,1) AlignBin' ones(NumTr,1)];
    AlignDimension = 1;
    for iACh = 1:2
        switch iACh
            case 1; [s.analog{nACh+iACh},currAlignBin]  = mergearrays(EOGX,AlignDimension,AlignArray);
            case 2; [s.analog{nACh+iACh},currAlignBin]  = mergearrays(EOGY,AlignDimension,AlignArray);
        end
        s.analogalignbin(nACh+iACh) = currAlignBin(2);
        nBins = size(s.analog{nACh+iACh},2);
        s.analogtime{nACh+iACh} = (s.analogalignbin(nACh+iACh)-1)*(-1)*(1000/s.analogfreq(nACh+iACh)) : (1000/s.analogfreq(nACh+iACh)) : (nBins-s.analogalignbin(nACh+iACh))*(1000/s.analogfreq(nACh+iACh));
    end
end

%% read cortex EPP data
if ReadEPPFlag && any(~cellfun('isempty',CtxEPP)) && any(CtxHead(strcmp('epp_size',par.CTXHeaderLabel),:)>0)

    cSF = CtxHead(strcmp(par.CTXHeaderLabel,'kHz_resolution'),:);
    cSF = unique(cSF);
    
    nEppCh = 2;
    nACh = length(s.analog);
    for i=1:nEppCh
        s.analogname{nACh+i} = sprintf('EPP%1.0f',i);
        s.analogfreq(nACh+i) = cSF;
        s.analogunits{nACh+i} = 'digital';
    end

    EPP1 = cell(1,NumTr);
    EPP2 = cell(1,NumTr);
    AlignBin = ones(1,NumTr);
    cEPPSampPeriod = zeros(1,NumTr).*NaN;

    for iTr = 1:NumTr
        if isempty(CtxEPP{iTr});continue;end
        n = length(CtxEPP{iTr}(:,1))/nEppCh;
        EPPStartTime = CtxEv{iTr}(CtxEv{iTr}(:,2) == par.EPPStartEventCode,1);
        EPPStopTime = CtxEv{iTr}(CtxEv{iTr}(:,2) == par.EPPStopEventCode,1);       
        ReadStartTime = CtxEv{iTr}(CtxEv{iTr}(:,2) == par.ReadDataStartEventCode,1);
        
        if n ==0 || isempty(EPPStartTime) || isempty(ReadStartTime)
            EPP1{iTr} = NaN;
            EPP2{iTr} = NaN;
            AlignBin(iTr) = 1;
        else
            EPP1{iTr} = CtxEPP{iTr}(1:2:end-1,1);
            EPP2{iTr} = CtxEPP{iTr}(2:2:end,1);
            EPP1{iTr} = EPP1{iTr}(:)';
            EPP2{iTr} = EPP2{iTr}(:)';
            
            cEPPSampTime(iTr) = EPPStopTime-EPPStartTime;
            cEPPSampPeriod(iTr) = cEPPSampTime(iTr)/n;
            
            t = [0:cEPPSampPeriod(iTr):(n-1)*cEPPSampPeriod(iTr)] + EPPStartTime;
            [dTReadStart,ReadStartBin] = min(abs(t - ReadStartTime - par.ReadDataOffset));
            EPP1{iTr} = EPP1{iTr}(:,ReadStartBin:end);
            EPP2{iTr} = EPP2{iTr}(:,ReadStartBin:end);
            t = t(ReadStartBin:end)-s.align(iTr);
            [dTalign,AlignBin(iTr)] = min(abs(t));
        end
       
    
    end
    
    s.analogfreq(nACh+1) = 1000/nanmedian(cEPPSampPeriod);
    s.analogfreq(nACh+2) = 1000/nanmedian(cEPPSampPeriod);
    
    % merge cells to matrix
    AlignArray = [ones(NumTr,1) AlignBin' ones(NumTr,1)];
    AlignDimension = 1;
    for iACh = 1:2
        switch iACh
            case 1; [s.analog{nACh+iACh},currAlignBin]  = mergearrays(EPP1,AlignDimension,AlignArray);
            case 2; [s.analog{nACh+iACh},currAlignBin]  = mergearrays(EPP2,AlignDimension,AlignArray);
        end
        s.analogalignbin(nACh+iACh) = currAlignBin(2);
        nBins = size(s.analog{nACh+iACh},2);
        s.analogtime{nACh+iACh} = (s.analogalignbin(nACh+iACh)-1)*(-1)*(1000/s.analogfreq(nACh+iACh)) : (1000/s.analogfreq(nACh+iACh)) : (nBins-s.analogalignbin(nACh+iACh))*(1000/s.analogfreq(nACh+iACh));
    end


end

%%
s.settings.ctx_settings = par;

