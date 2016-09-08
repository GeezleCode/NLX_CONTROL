function [r,c,n] = spk_SpikeRevCorr(s,OnsetEvent,Win,Tau,SeqStimIdx,SeqStimArray)

% count spikes related to reverse correlation stimulus
% Stimulus sequence should be in the field s.stimulus as 
% a nx2 vector [StimN x [t,StimIDNr]].
%
% [r,n] = spk_SPKRevCorr(s,OnsetEvent,Win,Tau,SeqStimIdx,SeqLength,StimID)
% 
% OnsetEvent .... defines the onset of reverse correlation stimuli
% Win ........... time window around Tau
% Tau ........... Tau sliding window delay, relativ to OnsetEvent
%
% SeqStimIdx .... stimulus index
% SeqStimArray .. if given, SeqStimIdx is index for SeqStimArray
%
% r ... [PresNr,StimNr,ChNr,Tau] rate
% c ... [PresNr,StimNr,ChNr,Tau] spike count
% n ... [1,StimNr] number of presentations

nTau = length(Tau);
if nargin<6
    SeqStimArray = [];
    if nargin<5
        SeqStimIdx = [];
    end;end

%% check trial number
[TrNr,s] = spk_CheckCurrentTrials(s,true);
nTr = length(TrNr);

%% time windows
EvNr = strmatch(OnsetEvent,s.eventlabel);
for iTr = 1:nTr
    t0(:,iTr) = s.events{EvNr,TrNr(iTr)}';
    tn(1,iTr) = length(s.events{EvNr,TrNr(iTr)});
    if isnan(Win)% windows are from onset(i) to onset(i+1)
        dt = median(diff(t0(:,iTr)));
        t1(:,iTr) = t0(:,iTr);
        t2(:,iTr) = t0(:,iTr);
        t2(1:end-1,iTr) = t0(2:end,iTr);
        t2(end,iTr) = t0(end,iTr)+dt;
    else
       t1(:,iTr) =  t0(:,iTr)+Win(1);
       t2(:,iTr) =  t0(:,iTr)+Win(2);
    end
end

% check events
tNum = unique(tn);
if length(tNum)>1
    error('Inconsistent number of onset events!');
end

%% get sequence
if isempty(SeqStimIdx) & isempty(SeqStimArray)
    ID = repmat([1:tNum]',1,nTr);
elseif ~isempty(SeqStimIdx) & isempty(SeqStimArray)
    ID = SeqStimIdx;
elseif ~isempty(SeqStimIdx) & ~isempty(SeqStimArray)
    ID = SeqStimArray(SeqStimIdx,:);
else
    ID = [];
end
[nSeq,nSeqTr] = size(ID);
if nSeq~=tNum || nSeqTr~=nTr
    error('inconsistent sequence information');
end

%% spike channel
if isempty(s.currentchan)
    s.currentchan = 1:size(s.spk,1);
end
nCh = length(s.currentchan);

%% allocate
nStim = 1000;
nPres = 50;
r = zeros(nPres,nStim,nCh,nTau).*NaN;
c = zeros(nPres,nStim,nCh,nTau).*NaN;
n = zeros(1,nStim);

%% loop trials
for iTr = 1:nTr
    % check matching of stimulus onsets and stimulus ID's
    if size(t0,1)~=size(ID,1)
        error('Number of stimuli does not match number of onset events!');
    end
    
    for it = 1:size(t0,1)
        if isnan(ID(it,iTr)) || ID(it,iTr)<1
            continue;%negelect NaN, zero or negative indices
        end
        n(ID(it,iTr)) = n(ID(it,iTr))+1;
        for iCh = 1:nCh
            dt = t2(it,iTr)-t1(it,iTr);
            for iTau = 1:nTau
                c(n(ID(it,iTr)),ID(it,iTr),iCh,iTau) = sum( ...
                    s.spk{s.currentchan(iCh),TrNr(iTr)} >= t1(it,iTr)+Tau(iTau) ...
                    & s.spk{s.currentchan(iCh),TrNr(iTr)} < t2(it,iTr)+Tau(iTau));
                r(n(ID(it,iTr)),ID(it,iTr),iCh,iTau) = c(n(ID(it,iTr)),ID(it,iTr),iCh,iTau) / dt *(10^(s.timeorder*(-1)));
            end
        end
    end
end

%% remove NaNs
r(:,n==0,:,:) = [];
c(:,n==0,:,:) = [];
n(n==0) = [];
r = r(1:max(n),:,:,:);
c = c(1:max(n),:,:,:);
