function [s,i] = spk_DeleteStartTrials(s,opt,par)

% removes trials from the beginning of the file
% opt ... 1) 'TRIALNUM' 2) 'TIME'
% par ... 1) number of trials 2) time 

nTr = spk_numtrials(s);

switch upper(opt)
    case 'TRIALNUM' 
        i = 1:par;
    case 'TIME'
        [TimeWin,AlignTimes] = spk_TrialEventLimit(s);
        TimeWin = TimeWin+[AlignTimes AlignTimes];
        StartTime = min(TimeWin(:));
        i = ~((TimeWin(:,1)-StartTime)>par);    
end

s = spk_cuttrials(s,i);
