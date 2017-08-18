function [spks,tWin] = spk_getSpikes(s,tWin,Ev)

% get the spikes within a time window
% spks = spk_getSpikes(s,tWin,Ev)
%
% tWin ........... relative event window
% Ev ............. char/numeric; if set tWin works as an offset to the event 

%% check trial number
nTrTotal = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTrTotal;
end
nTr = length(s.currenttrials);

%% check channel number
nChanTotal = spk_SpikeChanNum(s);
if isempty(s.currentchan)
    s.currentchan = 1:nChanTotal;
end
nChan = length(s.currentchan);

%% make time windows
if nargin<3 || isempty(Ev)
    tWin = repmat(tWin,[nTr,1]);
elseif ischar(Ev)
    tWin = spk_getEventWindow(s,Ev,tWin);
elseif isnumeric(Ev)
    if length(Ev)>1
        Ev = repmat(Ev,[1,2]);
    elseif length(Ev)==1
        Ev = repmat(Ev,[nTr,2]);
    end
    tWin = Ev+repmat(tWin,[nTr,1]);
end

%% get spikes
spks = s.spk(s.currentchan,s.currenttrials);
for iCh = 1:nChan
    for iTr = 1:nTr
        spks{iCh,iTr}(spks{iCh,iTr}<tWin(iTr,1)| spks{iCh,iTr}>tWin(iTr,2)) = [];
    end
end
