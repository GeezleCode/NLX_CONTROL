function s = spk_SpikeAdaptThreshold(s,FreqBounds,TimeWin,EchoFlag,LogFileID)

% Excludes trial using a threshold criterion.
% Waveform data needs to be loaded.
% Channel is selected by s = spk_set(s,'currentchan').
% FreqBounds work on trials set by s = spk_set(s,'currenttrials').
% Threshold adaptation works on all trials.
%
% s = spk_SpikeAdaptThreshold(s,FreqBounds,TimeWin)
%
% FreqBounds ... [Lo Hi] bounds of desired discharge rate in Hz  
% TimeWin ...... time window for rate adaptation
%                [1 x 2] time window with respect to current alignment of
%                        trials.
%                [n x 2] horizontal vectors time windows per trial
%                {'Event1' Event2'} Events define time window
%                {'Event1'[t1 t2]} Events+offset define time window

if nargin<5
    LogFileID = 1;
    if nargin<4
        EchoFlag = true;
    end;end;

%% prepare channels
if isempty(s.currentchan)
    error('No channels selected!!');
end
nChan = length(s.currentchan);

%% check current selection of trials
NumTrials = spk_TrialNum(s);
TrIndexThresh = 1:NumTrials;
if isempty(s.currenttrials)
	TrIndexRate = 1:NumTrials;
else
	TrIndexRate = s.currenttrials;
end
nTrRate = length(TrIndexRate);
nTrThresh = length(TrIndexThresh);

%% get event windows
if iscell(TimeWin)&&length(TimeWin)==2
    s.currenttrials = TrIndexRate;
    TimeWin = spk_getEventWindow(s,TimeWin{1},TimeWin{2});
elseif isnumeric(TimeWin)&&size(TimeWin,1)==nTrRate
elseif isnumeric(TimeWin)&&size(TimeWin,1)==1
    TimeWin = repmat(TimeWin,nTrRate,1);
end

%%

ReposT = cell(1,nTrThresh);
ReposW = cell(1,nTrThresh);

DoStaircase = true;
i = 0;
currStepDir = NaN;
NewThresholdValue = NaN;
iDecr = 1;
Step = NaN;
currStepDir = NaN;
lastStepDir = NaN;

while DoStaircase
    
    %% SpikeRate
    s.currenttrials = TrIndexRate;
    cSpikeRate = nanmean(spk_SpikeWinrate(s,TimeWin));
    
    %% Waveforms
    s.currenttrials = TrIndexThresh;
    WaveThreshValues = spk_getSpikeWavePar(s,s.spkwavealign(s.currentchan),[]);
    
    if i>1 && isempty(WaveThreshValues)% this is for the case that an iteration before put all spikes to the repository
        maxRepos = max(cat(1,ReposW{:}));
        minRepos = min(cat(1,ReposW{:}));
        if NegThresFlag% known from i's before
            WaveMin = maxRepos(s.spkwavealign(s.currentchan));
            WaveMax = minRepos(s.spkwavealign(s.currentchan));
        else
            WaveMin = minRepos(s.spkwavealign(s.currentchan));
            WaveMax = maxRepos(s.spkwavealign(s.currentchan));
        end
    else
        WaveMin = min(WaveThreshValues);
        WaveMax = max(WaveThreshValues);
    end
    
    if abs(WaveMax)<abs(WaveMin)
        NegThresFlag = true;
    else
        NegThresFlag = false;
    end
    
    if WaveMax==WaveMin
        break;
    end

    % change stepsize
    if i==0
        Step = 0.5*abs(diff([WaveMax WaveMin]));
    elseif i>0 && ((cSpikeRate < FreqBounds(2) && lastStepDir == -1) || (cSpikeRate > FreqBounds(1) && lastStepDir == 1))
        iDecr = iDecr+1;
        Step = Step .* (log(2)./log(iDecr+1));
    end
    
    if EchoFlag
        fprintf(LogFileID,'%1.0f %1.2fHz min=%1.0f max=%1.0f Step=%1.0f\n',i,cSpikeRate,WaveMin,WaveMax,Step);
    end
    
    % check rate
    if cSpikeRate >= FreqBounds(1) && cSpikeRate <= FreqBounds(2)
        DoStaircase = false;
        break;
    end
    
    % adapt threshold
    if cSpikeRate > FreqBounds(2)
        currStepDir = -1;
        if ~NegThresFlag
            NewThresholdValue = WaveMin+Step;
            
        else
            NewThresholdValue = WaveMax-Step;
        end
    elseif i>0 && (cSpikeRate < FreqBounds(1))
        currStepDir = +1;
        if ~NegThresFlag
            NewThresholdValue = WaveMin-Step;
        else
            NewThresholdValue = WaveMax+Step;
        end
    else
        break;
    end
    lastStepDir = currStepDir; 
    
    % move to/from repository spikes
    i = i+1;
    for iTr = 1:length(s.currenttrials)
%         fprintf(1,'%1.0f',min(spk_getSpikeWavePar(s,s.spkwavealign(s.currentchan),[],1,s.currenttrials(iTr))));
%         fprintf(1,' %1.0f',max(spk_getSpikeWavePar(s,s.spkwavealign(s.currentchan),[],1,s.currenttrials(iTr))));
        
        if isempty(s.spkwave{s.currentchan,s.currenttrials(iTr)})
            SPKIndex = false;
        else
            SPKIndex = NewThresholdValue > s.spkwave{s.currentchan,s.currenttrials(iTr)}(:,s.spkwavealign(s.currentchan));
        end
        if isempty(ReposW{1,iTr})
            ReposIndex= false;
        else
            ReposIndex = NewThresholdValue < ReposW{1,iTr}(:,s.spkwavealign(s.currentchan));
        end
        if any(SPKIndex) && currStepDir == -1;
            % move to repository
            ReposW{1,iTr} = cat(1,ReposW{1,iTr},s.spkwave{s.currentchan,s.currenttrials(iTr)}(SPKIndex,:));
            ReposT{1,iTr} = cat(1,ReposT{1,iTr}(:),s.spk{s.currentchan,s.currenttrials(iTr)}(SPKIndex));
            [ReposT{1,iTr},SortIndex] = sort(ReposT{1,iTr});
            ReposW{1,iTr} = ReposW{1,iTr}(SortIndex,:);
%             fprintf(1,'%1.0f ',s.spkwave{s.currentchan,s.currenttrials(iTr)}(SPKIndex,s.spkwavealign(s.currentchan)));
%             fprintf(1,'\n');
            s.spkwave{s.currentchan,s.currenttrials(iTr)}(SPKIndex,:) = [];
            s.spk{s.currentchan,s.currenttrials(iTr)}(SPKIndex) = [];
        elseif any(ReposIndex) && currStepDir == 1;
            % move from repository
            s.spkwave{s.currentchan,s.currenttrials(iTr)} = cat(1,s.spkwave{s.currentchan,s.currenttrials(iTr)},ReposW{1,iTr}(ReposIndex,:));
            s.spk{s.currentchan,s.currenttrials(iTr)} = cat(1,s.spk{s.currentchan,s.currenttrials(iTr)}(:),ReposT{1,iTr}(ReposIndex));
            [s.spk{s.currentchan,s.currenttrials(iTr)},SortIndex] = sort(s.spk{s.currentchan,s.currenttrials(iTr)});
            s.spkwave{s.currentchan,s.currenttrials(iTr)} = s.spkwave{s.currentchan,s.currenttrials(iTr)}(SortIndex,:);
            ReposW{1,iTr}(ReposIndex,:) = [];
            ReposT{1,iTr}(ReposIndex) = [];
        elseif ~any(ReposIndex) && currStepDir == 1;
%             warning('No spikes in repository!');
        end
%         fprintf(1,' %1.0f',min(spk_getSpikeWavePar(s,s.spkwavealign(s.currentchan),[],1,s.currenttrials(iTr))));
%         fprintf(1,' %1.0f',max(spk_getSpikeWavePar(s,s.spkwavealign(s.currentchan),[],1,s.currenttrials(iTr))));
%         fprintf(1,'\n');
    end
    
end

