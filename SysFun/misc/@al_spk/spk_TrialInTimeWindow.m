function i = spk_TrialInTimeWindow(s,TW,TWMode)

% returns a subsample of trials that are within a given time window
% (in units of current object time, see s.timeorder)
% Time window nans are neglected.
%
% TW ....... [nx2] time windows
% TWMode ... 'ABS' absolute time (e.g. Neuralynx time)
%            'REL' time relative to beginning of first trial
%            'TIMEPROPORTIONAL' [0-1] time proportion
%            'TRIALPROPORTIONAL' [0-1] e.g. [0 .5] slects first half of
%            trials
%
% i ........ logical array [n timewindows x n trials]

[TimeWin,AlignTimes,s] = spk_TrialEventLimit(s);
nTW = size(TW,1);
nTr = spk_TrialNum(s);
i = false(nTW,nTr);

switch TWMode
    case 'ABS'
        TrialStartTime = TimeWin(:,1)+AlignTimes;
    case 'REL'
        TrialStartTime = TimeWin(:,1)+AlignTimes;
        TrialStartTime = TrialStartTime-TrialStartTime(1);
    case 'TIMEPROPORTIONAL'
        TrialStartTime = TimeWin(:,1)+AlignTimes;
        TrialStartTime = TrialStartTime-TrialStartTime(1);
        TrialStartTime = TrialStartTime./TrialStartTime(end);
    case 'TRIALPROPORTIONAL'
        TrialStartTime = [1:nTr]'./nTr;
end

for iTW = 1:nTW
    isLater = true(1,nTr);
    isEarlier = true(1,nTr);
    if ~isnan(TW(iTW,1))
        isLater(TrialStartTime'<TW(iTW,1)) = false;
    end
    if ~isnan(TW(iTW,2))
        isEarlier(TrialStartTime'>=TW(iTW,2)) = false;
    end
    i(iTW,:) =  isLater & isEarlier;
end

        