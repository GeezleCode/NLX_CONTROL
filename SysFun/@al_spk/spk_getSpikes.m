function [spks,tWin,spkwave] = spk_getSpikes(s,tWin,Ev,AlignFlag)

% get the spikes within a time window
% spks = spk_getSpikes(s,tWin,Ev)
%
% tWin ........... relative event window
% Ev ............. char/numeric; if set tWin works as an offset to the event 

if nargin<4
    AlignFlag = false;
end

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
if nargin<3 || isempty(Ev)% no reference event
    tWin = repmat(tWin,[nTr,1]);
elseif ischar(Ev)%event is given as event string
    [tWin,EvTimes] = spk_getEventWindow(s,Ev,tWin);
elseif isnumeric(Ev)% event is given as time(s)
    if length(Ev)>1
        EvTimes = repmat(Ev,[1,2]);
        tWin = EvTimes + repmat(tWin,[nTr,1]);
    elseif length(Ev)==1
        EvTimes = repmat(Ev,[nTr,2]);
        tWin = EvTimes + repmat(tWin,[nTr,1]);
    end
    
end

%% alignment of spike times
Talign =zeros(nTr,1);
if AlignFlag && ~isempty(Ev)
     Talign = EvTimes;
end

%% get spikes
spks = s.spk(s.currentchan,s.currenttrials);
for iCh = 1:nChan
    for iTr = 1:nTr
        spks{iCh,iTr}(spks{iCh,iTr}<tWin(iTr,1)| spks{iCh,iTr}>tWin(iTr,2)) = [];
        spks{iCh,iTr} = spks{iCh,iTr}-Talign(iTr);
    end
end

%% get spike waveform
if nargout==3
    spkwave = s.spkwave(s.currentchan,s.currenttrials);
    for iCh = 1:nChan
        for iTr = 1:nTr
            if length(spkwave{iCh,iTr})~=length(s.spk{iCh,iTr})
                error('Inconsistency between spike and spike-waveform data!');
            end
            spkwave{iCh,iTr}(s.spk{iCh,iTr}<tWin(iTr,1)| s.spk{iCh,iTr}>tWin(iTr,2)) = [];
        end
    end
end
