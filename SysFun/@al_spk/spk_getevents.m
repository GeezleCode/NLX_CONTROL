function [evCells,i] = spk_getEvents(s,eventlabel)

% returns the events; omit input for info
% [evCells,i] = spk_getevents(s,eventlabel,trialNr)
%
% eventlabel ... string indicating the event name as in s.eventlabel

%% show event info
if nargin<2
    [nEv,nTr] = size(s.events);
    fprintf(1,'occured events:\n');
    for i=1:nEv
        fprintf(1,'%25s\t',s.eventlabel{i});
        fprintf(1,'total: %1.0f\t',sum(cellfun('length',s.events(i,:))));
        fprintf(1,'trial: %1.0f',sum(cellfun('length',s.events(i,:))>0));
        fprintf(1,'\n');
    end
    return;
end

%% get events
i = strmatch(upper(eventlabel),upper(s.eventlabel),'exact');
if size(s.events,1)<i
    evCells = {};
elseif isempty(s.currenttrials)
    evCells = s.events(i,:);
else
    evCells = s.events(i,s.currenttrials);
end