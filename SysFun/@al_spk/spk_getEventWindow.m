function [Win,EvTimes] = spk_getEventWindow(s,Ev,EvOffset)

% returns start and end time of a window defined by an event(s)
% [Win,EvTimes] = spk_getEventWindow(s,Ev,EvOffset)
%
% Ev ......... eventlabel
% EvOffset ... eventlabel or a [nx2] matrix defining an offset to Ev

nTrTotal = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTrTotal;
end
nTr = length(s.currenttrials);

%% get time window
Win = ones(nTr,2).*NaN;

if isempty(Ev)
    EvTimes = zeros(nTr,1);
else
    [EvTimes,i] = spk_getEvents(s,Ev);
    EvTimes = cat(1,EvTimes{:});
end

if isempty(EvOffset)
    Win = repmat(EvTimes,[1 2]);
elseif ischar(EvOffset)
    [EvOffsetTimes,i] = spk_getEvents(s,EvOffset);
    Win = [EvTimes cat(1,EvOffsetTimes{:})];
elseif isnumeric(EvOffset)
    Win = repmat(EvTimes,[1 2]) + repmat(EvOffset,[length(EvTimes) 1]);
end

