function c = spk_EventCount(s,EventName)

% counts occurences of particular events in each trial
% c = spk_EventCount(s,EventName)
% EventName is a cell array of strings (Event name).

nEvCnt = length(EventName);
[nEv,nTr] = size(s.events);
if nEvCnt==0
    c = zeros(1,nTr);
    return;
end

iEv = spk_findEventlabel(s,EventName);
c = zeros(nEvCnt,nTr);
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
