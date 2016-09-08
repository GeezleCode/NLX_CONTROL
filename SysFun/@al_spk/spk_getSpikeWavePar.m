function [p,t,a,sf] = spk_getSpikeWavePar(s,WavSampNr,TimeWin,ChanName,TrNr)

% gets parameter of spikewaveform
%
% [p,t,a,sf] = spk_getSpikeWavePar(s,WavSampNr,TimeWin,ChanName,TrNr)
%
% WavSampNr .... Sample Nr of Waveform, leave empty for all
% TimeWin ...... time window for rate adaptation
%                [] use all waveforms
%                [1 x 2] time window with respect to current alignment of
%                        trials.
%                [n x 2] horizontal vectors time windows per trial
%                {'Event1' Event2'} Events define time window
%                {'Event1'[t1 t2]} Events+offset define time window

if nargin<5
    TrNr = [];
    if nargin<4
        ChanName = '';
        if nargin<3
            TimeWin = [];
        end;end;end
nTr = spk_TrialNum(s);
nCh = spk_SpikeChanNum(s);

%% prepare trials
if nargin>=5 && ~isempty(TrNr)
    s.currenttrials = TrNr;
end
[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(s.currenttrials);

%% get event windows
if iscell(TimeWin)&&length(TimeWin)==2
    TimeWin = spk_getEventWindow(s,TimeWin{1},TimeWin{2});
elseif isnumeric(TimeWin)&&size(TimeWin,1)==nTr
elseif isnumeric(TimeWin)&&size(TimeWin,1)==1
    TimeWin = repmat(TimeWin,nTr,1);
end

%% prepare channels
if nargin>=4 && ~isempty(ChanName)
    if ischar(ChanName)||iscell(ChanName)
        s.currentchan = spk_findSpikeChan(s,ChanName);
    else
        s.currentchan = ChanName;
    end    
elseif isempty(s.currentchan)
    s.currentchan = 1;
end

%% get parameter
p = [];
t = [];
a = s.spkwavealign;
sf = s.spkwavefreq;
for iTr = 1:nTr
    
    nWFs = size(s.spkwave{s.currentchan,s.currenttrials(iTr)},1);
    nTSs = numel(s.spk{s.currentchan,s.currenttrials(iTr)});
    if nWFs~=nTSs
        error('Inconsistent spikewaveform information!!')
    end
    
    nspk = length(s.spk{s.currentchan,s.currenttrials(iTr)});
    if nspk==0;continue;end
    ispk = true(nspk,1);
    if ~isempty(TimeWin)
        ispk = s.spk{s.currentchan,s.currenttrials(iTr)}>=TimeWin(s.currenttrials(iTr),1) && s.spk{s.currentchan,s.currenttrials(iTr)}<=TimeWin(s.currenttrials(iTr),2);
    end
    
    if isempty(WavSampNr)
        p = cat(1,p,s.spkwave{s.currentchan,s.currenttrials(iTr)}(ispk,:));
    else
        p = cat(1,p,s.spkwave{s.currentchan,s.currenttrials(iTr)}(ispk,WavSampNr));
    end
    t = cat(1,t,s.spk{s.currentchan,s.currenttrials(iTr)}(ispk));
end