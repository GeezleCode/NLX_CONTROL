function d = spk_eventdiff(s,ev1,ev2);

% calculates time differences of two types of events in the trials given in
% s.currenttrials. 
% d = spk_eventdiff(s,ev1,ev2)
%
% ev1,ev2 ... eventlabels, char

numTrials = size(s.events,2);

if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrTrials = length(s.currenttrials);

ev1i = spk_findeventlabel(s,ev1);
ev2i = spk_findeventlabel(s,ev2);

% check number of events
n1 = cellfun('length',s.events(ev1i,s.currenttrials));
n2 = cellfun('length',s.events(ev2i,s.currenttrials));
if any( (n2-n1)~=0 )
    error('Can''t substract event times, different number of events !');
end
ns = unique(n1);
if length(ns)>1
    error('Can''t substract event times, number of events different in trials!');
end
d = zeros(ns,numCurrTrials).*NaN;

for i=1:numCurrTrials
    if isempty(s.events{ev1i,s.currenttrials(i)}) | isempty(s.events{ev2i,s.currenttrials(i)})
        d(i) = NaN;
    else
        d(:,i) = [ s.events{ev1i,s.currenttrials(i)}-s.events{ev2i,s.currenttrials(i)} ]';
    end
end
