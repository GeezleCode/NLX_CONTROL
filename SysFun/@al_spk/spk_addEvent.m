function [s,EvFoundIndex] = spk_addEvent(s,EventLabel,EventValue,TrialNr)

% adds events
% s = spk_addEvent(s,EventLabel,EventValue,TrialNr)
% EventLabel ... 
% EventValue ...
% TrialNr ......

numEventLabel = length(s.eventlabel);
numTrials =  size(s.events,2);
if nargin<4
    TrialNr = 1:numTrials;
end
if ischar(EventLabel)
    EventLabel = {EventLabel};
end

% get existing eventlabel
[EvFound,EvFoundIndex] = ismember(EventLabel,s.eventlabel);

% handle new events
EvFoundIndex(~EvFound) = numEventLabel + [1:sum(~EvFound)];% create new event indices
s.eventlabel(EvFoundIndex(~EvFound)) = EventLabel(~EvFound);% set new event label

% set values
s.events(EvFoundIndex,TrialNr) = EventValue(EvFound);

