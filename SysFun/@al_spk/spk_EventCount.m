function [c,cEventLabel] = spk_EventCount(s,EventName)

% counts occurences of particular events in each trial
% c = spk_EventCount(s,EventName)
% EventName is a cell array of strings (Event name).

[nEv,nTr] = size(s.events);

if nargin<2 || isempty(EventName)
    nEvCnt = nEv;
    iEv = 1:nEv;
else
    nEvCnt = length(EventName);
    iEv = spk_findEventlabel(s,EventName);
end

c = zeros(nEvCnt,nTr);
cEventLabel = s.eventlabel(iEv);


if iEv==0;return;end

for iTr = 1:nTr
    for iEvCnt = 1:nEvCnt
        if iEv(iEvCnt)==0 || isnan(iEv(iEvCnt))
            c(iEvCnt,iTr) = NaN;
        else
            c(iEvCnt,iTr) = sum(~isnan(s.events{iEv(iEvCnt),iTr}));
        end
    end
end
