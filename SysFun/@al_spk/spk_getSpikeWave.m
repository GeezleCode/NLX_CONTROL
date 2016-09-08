function [WF,TS,iTS,WFalign,WFSF] = spk_getSpikeWave(s,WFSamples,TimeWin,WFNmax)

% extracts spike waveform data
% [WF,TS,iTS] = spk_getSpikeWave(s,WFAlign,WFSamples,WFNmax)
%
% WFSamples .... Sample indices to extract
% WFNmax ....... max number of Waveforms to extract, random if n>WFmax
% TimeWin ...... [] use all waveforms
%                [1 x 2] time window with respect to current alignment of
%                        trials.
%                [n x 2] horizontal vectors time windows per trial
%                {'Event1' Event2'} Events define time window
%                {'Event1'[t1 t2]} Events+offset define time window
% WF ........... Waveform data
% TS .......... timestamps
% iTS .......... spike index per trial
%
% Works s.currenttrials, s.currentchannel

nTr = spk_TrialNum(s);
[nCh,ChanLabel,EmptyChan,nSpk] = spk_SpikeChanNum(s);

%% prepare channels
if isempty(s.currentchan)
    s.currentchan = 1:nCh;
end
ChNum = length(s.currentchan);

%% get trials
if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end
TrNum = length(s.currenttrials);

%% get event windows
if isempty(TimeWin)
elseif iscell(TimeWin)&&length(TimeWin)==2
    TimeWin = spk_getEventWindow(s,TimeWin{1},TimeWin{2});
elseif isnumeric(TimeWin)&&size(TimeWin,1)==TrNum
elseif isnumeric(TimeWin)&&size(TimeWin,1)==1
    TimeWin = repmat(TimeWin,TrNum,1);
else
    error('Time-Window information is not consistent!');
end

%% allocate output
WF = cell(1,ChNum); 
TS = cell(1,ChNum); 
iTS = cell(1,ChNum);
WFalign = ones(1,ChNum).*NaN;
WFSF = ones(1,ChNum).*NaN;

%% loop cells
for iCh = 1:ChNum
    WFalign(1,iCh) = s.spkwavealign(1);%s.spkwavealign(s.currentchan(iCh)); 
    WFSF(1,iCh) = s.spkwavefreq(1);%s.spkwavefreq(s.currentchan(iCh));
    
    % get all waveforms
    cWF = [];
    cTS = [];
    for iTr = 1:TrNum
        if isempty(TimeWin)
            iSpks = true(nSpk(s.currentchan(iCh),s.currenttrials(iTr)),1);
        else
            iSpks = s.spk{s.currentchan(iCh),s.currenttrials(iTr)} >= TimeWin(iTr,1) & s.spk{s.currentchan(iCh),s.currenttrials(iTr)} <= TimeWin(iTr,2);
        end
        cTS = cat(1,cTS,s.spk{s.currentchan(iCh),s.currenttrials(iTr)}(iSpks));
        cWF = cat(1,cWF,s.spkwave{s.currentchan(iCh),s.currenttrials(iTr)}(iSpks,:));
    end
    [cSpkNum,cSampleNum] = size(cWF);
    
    % default waveform samples
    if isempty(WFSamples)
        WFSamples = 1:cSampleNum;
    end
    
    % select spikes
    if cSpkNum==0;% no spikes found
        WF{iCh} = [];
    elseif ~isempty(WFNmax) && WFNmax<cSpkNum% restrict number of spikes
        iTS{iCh} = randsample(cSpkNum,WFNmax);
        WF{iCh} = cWF(iTS{iCh},WFSamples);
        TS{iCh} = cTS(iTS{iCh});
    else
        iTS{iCh} = 1:cSpkNum;
        WF{iCh} = cWF(:,WFSamples);
        TS{iCh} = cTS;
    end
end

%% 
if ChNum==1
    WF = WF{1};
    TS = TS{1};
    iTS = iTS{1};
end



