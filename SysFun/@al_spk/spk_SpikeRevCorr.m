function [r,c,n] = spk_SpikeRevCorr(s,OnsetEvent,Win,Tau,SeqIndex,SeqLength)

% count spikes related to reverse correlation stimulus
% Stimulus sequence should be in the field s.stimulus as 
% a nx2 vector [StimN x [t,StimIDNr]].
% [r,n] = spk_SPKRevCorr(s,OnsetEvent,Win,Tau,SeqIndex)
% OnsetEvent ...
% Win ..........
% Tau ..........
% SeqIndex .....
%
% r ... [PresNr,StimNr,ChNr,Tau] rate
% c ... [PresNr,StimNr,ChNr,Tau] spike count
% n ... [1,StimNr] number of presentations

nTau = length(Tau);

%% check trial number
nTotTr = spk_TrialNum(s);
[dummy,nRVTr] = size(s.stimulus);
if isempty(s.currenttrials)
    iTr = 1:nTotTr;
else
    iTr = s.currenttrials;
end
nTr = length(iTr);

%% get sequence
nSeq = cellfun('size',s.stimulus(iTr),1);
if length(unique(nSeq))>1
    warning('inconsistent length of revcorr sequence!');
    iTr(nSeq~=SeqLength) = [];
    nTr = length(iTr);
end

%% get event
EvNr = strmatch(OnsetEvent,s.eventlabel);

%% spike channel
if isempty(s.currentchan)
    s.currentchan = 1:size(s.spk,1);
end
nCh = length(s.currentchan);


%% loop trials
nStim = 1000;
nPres = 50;
r = zeros(nPres,1000,nCh,nTau).*NaN;
c = zeros(nPres,1000,nCh,nTau).*NaN;
n = zeros(1,1000);

for i = 1:nTr
    ID = s.stimulus{iTr(i)}(SeqIndex,2);
    t = s.events{EvNr,iTr(i)};
    if length(t)~=length(ID)
        error('Number of stimuli does not match number of onset events!');
    end
    for it = 1:length(t)
        n(ID(it)) = n(ID(it))+1;
        for iCh = 1:nCh
            for iTau = 1:nTau
                c(n(ID(it)),ID(it),iCh,iTau) = sum(s.spk{s.currentchan(iCh),iTr(i)} >= t(it)+Tau(iTau)+Win(1) & s.spk{s.currentchan(iCh),iTr(i)} < t(it)+Tau(iTau)+Win(2));
                r(n(ID(it)),ID(it),iCh,iTau) = c(n(ID(it)),ID(it),iCh,iTau) / diff(Win) *(10^(s.timeorder*(-1)));
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
