function [TimeWin,AlignTimes,s] = spk_TrialEventLimit(s)

% returns the time window between earliest and latest event of
% trials given in s.currenttrials; set by >>spk_set(s,'currentrials',[ ... ])
%
% [TimeWin,AlignTimes,s] = spk_TrialEventLimit(s)
%
% OUTPUT
% TimeWin ...... two column array, trials in rows
% AlignTimes ... column vector of align times for each trial

TrialNum = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:TrialNum;
end
CurrTrialNum = length(s.currenttrials);

TimeWin = ones(CurrTrialNum,2).*NaN;
AlignTimes = ones(CurrTrialNum,1).*NaN;
nEvTypes = size(s.events,1);

for i = 1:CurrTrialNum
    for iEvType = 1:nEvTypes
        if ~isempty(s.events{iEvType,i})
            
            currMax = max(squeeze(s.events{iEvType,i}));
            currMin = min(squeeze(s.events{iEvType,i}));
            
            if isnan(TimeWin(i,1)) || currMin<TimeWin(i,1)
                TimeWin(i,1) = currMin;
            end
            if isnan(TimeWin(i,2)) || currMax>TimeWin(i,2)
                TimeWin(i,2) = currMax;
            end
            
%             if currMin>0 && (isnan(TimeWin(i,1)) || currMin<TimeWin(i,1))
%                 TimeWin(i,1) = currMin;
%             end
%             if currMax>0 && (isnan(TimeWin(i,2)) || currMax>TimeWin(i,2))
%                 TimeWin(i,2) = currMax;
%             end
            
            
        end
    end
    AlignTimes(i,1) = s.align(s.currenttrials(i));
end
