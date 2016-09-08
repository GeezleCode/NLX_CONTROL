function [Ev,EvNr] = spk_getEvents(s,eventlabel,EvNo)

% returns the events; omit input for info
% [evCells,EvNr] = spk_getevents(s,eventlabel)
%
% eventlabel ... string indicating the event name as in s.eventlabel
% EvNo ......... selects a single event in case of multiple per trial

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

%% prepare output
[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(currenttrials);
if ischar(eventlabel)
    eventlabel = {eventlabel};
end
nEv = length(eventlabel);
evCells = cell(nEv,nTr);

for iEv=1:nEv
    i = find(strcmp(eventlabel{iEv},s.eventlabel));
    if isempty(i)
        EvNr(iEv) = NaN;
        continue;
    else
        EvNr(iEv) = i;
    end
    evCells(iEv,:) = s.events(EvNr(iEv),s.currenttrials);
end

%% pick a specific event
if nargin>2
    evVec = zeros(size(evCells));
%     nEvPerTrcellfun('length',evCells);
    for iEv=1:nEv
        for i=1:length(evCells)
            EvCnt = length(evCells{iEv,i});
            if EvCnt==0 || EvCnt<EvNo
                evVec(iEv,i) = NaN;
            else
                evVec(iEv,i) = evCells{iEv,i}(EvNo);
            end
        end
    end
end

%% assign output
if nargin>2
    Ev = evVec;
else
    Ev = evCells;
end
    