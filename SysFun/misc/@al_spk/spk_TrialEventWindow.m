function [TimeWin,AlignTimes,s] = spk_TrialEventWindow(s,LoEventLabel,HiEventLabel,EventNr)

% returns the time window between two specified events
% trials are give in s.currenttrials; set by >>spk_set(s,'currentrials',[ ... ])
% NOTE: if there multiple events of the LoEventLabel type HiEvent is
% defined as the next event in time after LoEvent(EventNr).
%
% [TimeWin,AlignTimes,s] = spk_TrialEventWindow(s,LoEventLabel,HiEventLabel,EventNr)
%
% INPUT
% LoEventLabel,HiEventLabel ..... event names as defined in
%                                 s.eventlabels
% EventNr ....................... number of event for each trial
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
if nargin<4
    EventNr = ones(CurrTrialNum,1);
end
if length(EventNr)~=CurrTrialNum
    error('EventNr array must be same size as s.currenttrials !!!');
end

LoEventLabelIndex = spk_findEventlabel(s,LoEventLabel);
HiEventLabelIndex = spk_findEventlabel(s,HiEventLabel);

for i = 1:CurrTrialNum
    AllEventTime = cat(1,s.events{:,s.currenttrials(i)});
    LoEventTime = s.events{LoEventLabelIndex,s.currenttrials(i)};
    HiEventTime = s.events{HiEventLabelIndex,s.currenttrials(i)};
    
    % check number of events of this particular type in this trial
    NumLoEvent = length(LoEventTime);
    NumHiEvent = length(HiEventTime);
    
    % check for multiple LO events 
    if NumLoEvent>1
        LoEventTime = LoEventTime(EventNr(i));
        if any(HiEventTime>LoEventTime)
            HiEventTime = HiEventTime(find(HiEventTime>LoEventTime));% take next of hi events
            HiEventTime = HiEventTime(1);
        else
            HiEventTime = cat(2,s.events{:,s.currenttrials(i)});
            if any(HiEventTime>LoEventTime)
                HiEventTime = HiEventTime(find(HiEventTime>LoEventTime));% take next of all other events
                HiEventTime = HiEventTime(1);
            else
                HiEventTime = LoEventTime;
            end
        end
    end
    
    if NumHiEvent>1
%         warning('multiple events in this trial');
        HiEventTime = max(HiEventTime);
    end
    
    TimeWin(i,1) = LoEventTime;
    TimeWin(i,2) = HiEventTime;
    AlignTimes(i,1) = s.align(s.currenttrials(i));
    
end
