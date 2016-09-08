function r = spk_TrialSplit(s,TimeWin,AlignTime,TrialCode,TrialCodeLabel)

% Low level function to split trials.
% r = spk_TrialSplit(s,TimeWin,AlignTime,TrialCode,TrialCodeLabel)
% TimeWin [nTr x 2 x nSplit] 
% AlignTime [nTr X nSplit]
% TrialCode [nTr X nSplit]
% TrialCodeLabel char 

if nargin>3
    TrialCodeFlag = true;
    if nargin<5
        TrialCodeLabel = 'TrialSplitCode';
    end
else
    TrialCodeFlag = false;
end
    
%% get current trials
nTrTotal = spk_TrialNum(s);
[cTr,s] = spk_CheckCurrentTrials(s);
nTr = length(cTr);

%% check input
[TWnTr,TWnBnd,TWnSplit] = size(TimeWin);
% [TAnTr,TAnSplit] = size(AlignTime);
% [TCnTr,TCnSplit] = size(TrialCode);

nSp = TWnSplit;
nR = nSp*nTr;

%% prepare new object
r = s;
r.spk = [];
r.analog = {};
r.align = [];
r.events = cell(size(s.events,1),nR);
r.trialcode = [];

%% align
for iR = 1:nR
    [iSp,iTr] = ind2sub([nSp nTr],iR);
    r.align(1,iR) = s.align(cTr(iTr)) + AlignTime(iTr,iSp);
end

%% spike data
nCh = size(s.spk,1);
for iR = 1:nR
    [iSp,iTr] = ind2sub([nSp nTr],iR);
    for iCh = 1:nCh
        SpkIdx = s.spk{iCh,cTr(iTr)}>=TimeWin(iTr,1,iSp) & s.spk{iCh,cTr(iTr)}<=TimeWin(iTr,2,iSp);
        r.spk{iCh,iR} = s.spk{iCh,cTr(iTr)}(SpkIdx) - AlignTime(iTr,iSp);
        if ~isempty(s.spkwave)
            r.spkwave{iCh,iR} = s.spkwave{iCh,cTr(iTr)}(SpkIdx,:);
        end
    end
end
        
%% analog data
nACh = length(s.analog);
for iACh = 1:nACh
    AnaData = cell(1,nR);
    AnaAlign = zeros(nR,1);
    AnaTime = spk_AnalogTimeVec(s,iACh);
    for iR = 1:nR
        [iSp,iTr] = ind2sub([nSp nTr],iR);
        if any(isnan(TimeWin(iTr,:,iSp)))
            AnaAlign(iR) = 1;
            AnaData{iR} = NaN;
        else
            tidx = AnaTime>=TimeWin(iTr,1,iSp) & AnaTime<=TimeWin(iTr,2,iSp);
            [AlgnErr,AnaAlign(iR)] = min(abs(AnaTime(tidx)-AlignTime(iTr,iSp)));
            AnaData{iR} = s.analog{iACh}(cTr(iTr),tidx);
        end
    end
    [r.analog{iACh},mergealign] = mergearrays(AnaData,1,[ones(nR,1) AnaAlign ones(nR,1)]);
    r.analogalignbin(iACh) = mergealign(2);
    r.analogtime{iACh} = [];
end
    
%% event data
nEv = size(s.events,1);
r.eventlabel{nEv+1} = 'SplitTrialStart';
r.eventlabel{nEv+2} = 'SplitTrialEnd';
for iR = 1:nR
    [iSp,iTr] = ind2sub([nSp nTr],iR);
    for iEv = 1:nEv
        EvIdx = s.events{iEv,cTr(iTr)}>=TimeWin(iTr,1,iSp) & s.events{iEv,cTr(iTr)}<=TimeWin(iTr,2,iSp);
        r.events{iEv,iR} = s.events{iEv,cTr(iTr)}(EvIdx)-AlignTime(iTr,iSp);
    end
    r.events{nEv+1,iR} = TimeWin(iTr,1,iSp)-AlignTime(iTr,iSp);
    r.events{nEv+2,iR} = TimeWin(iTr,2,iSp)-AlignTime(iTr,iSp);
end

%% trialcode
nTC = size(s.trialcode,1);
r.trialcodelabel{nTC+1} = 'PreSplitIndex';
r.trialcodelabel{nTC+2} = 'SplitIndex';
if TrialCodeFlag
    r.trialcodelabel{nTC+3} = TrialCodeLabel;
end
for iR = 1:nR
    [iSp,iTr] = ind2sub([nSp nTr],iR);
    for iTC = 1:nTC
        r.trialcode(iTC,iR) = s.trialcode(iTC,cTr(iTr));
    end
    r.trialcode(nTC+1,iR) = cTr(iTr);
    r.trialcode(nTC+2,iR) = iSp;
    if TrialCodeFlag
        r.trialcode(iTC+3,iR) = TrialCode(iTr,iSp);
    end
end

%% stimulus data
for iR = 1:nR
    [iSp,iTr] = ind2sub([nSp nTr],iR);
    r.stimulus(1,iR) = s.stimulus(cTr(iTr));
end

