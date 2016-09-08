function s = spk_deleteEvent(s,EventLabel)

% adds events
% s = spk_deleteEvent(s,EventLabel)

if ischar(EventLabel)
    EventLabel = {EventLabel};
end

for i=1:length(EventLabel)
    cEvi = strcmp(EventLabel{i},s.eventlabel);
    s.eventlabel(cEvi) = [];
    s.events(cEvi,:) = [];
end
