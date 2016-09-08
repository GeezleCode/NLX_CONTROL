function d = spk_EventDiff(s,ev1,ev2)

% calculates time differences of two types of events in the trials given in
% s.currenttrials. 
% d = spk_eventdiff(s,ev1,ev2)
%
% ev1,ev2 ... eventlabels, char

[nEv,nTr] = size(s.events);
[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(currenttrials);
ev1i = spk_findEventlabel(s,ev1);
ev2i = spk_findEventlabel(s,ev2);
n1 = cellfun('length',s.events(ev1i,s.currenttrials));
n2 = cellfun('length',s.events(ev2i,s.currenttrials));
nEv = max([n1(:);n2(:)]);
d = zeros(nEv,nTr).*NaN;
for iTr = 1:nTr
    if n1(iTr)>0 & n1(iTr) == n2(iTr)
        d(:,iTr) = sort(s.events{ev1i,s.currenttrials(iTr)}) - sort(s.events{ev2i,s.currenttrials(iTr)});
    end
end
