function s = spk_addEvent(s,EventLabel,EventValue,TrialNr)

EventLabelIndex = strmatch(upper(EventLabel),upper(s.eventlabel),'exact');
numEventLabel =  size(s.eventlabel,2);
numTrials =  size(s.events,2);

% add eventlabel if non existing
if isempty(EventLabelIndex)
    EventLabelIndex = numEventLabel+1;
    s.eventlabel{EventLabelIndex} = EventLabel;
    if numTrials>0
        s.events{EventLabelIndex,1:numTrials} = [];
    end
end

% set values of events
if nargin>2
    s.events(EventLabelIndex,TrialNr) = EventValue;
end
    
