function [evCells,EvOrder] = spk_EventSorting(s,eventlabel)

% [EvOrder,evCells] = spk_EventSorting(s,eventlabel)
%
% eventlabel ... cell array

[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(currenttrials);
nEv = length(eventlabel);
[EvFound,EvNr] = ismember(eventlabel,s.eventlabel);
evCells = s.events(EvNr,currenttrials);
EvCnt = cellfun('length',evCells);
if any(EvCnt(:)>1)
    error('No multiple events allowed!')
end
evCells(EvCnt==0) = {[NaN]};
EvTimes = cat(1,evCells{:});
EvTimes = reshape(EvTimes,nEv,nTr);
[EvTimes,EvOrder] = sort(EvTimes,1,'ascend');
nonEvents = isnan(EvTimes);
evCells = num2cell(EvTimes);
evCells(nonEvents) = {[]};

