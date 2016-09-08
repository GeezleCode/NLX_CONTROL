function [Win,EvTimes] = spk_getEventWindow(s,Ev1,Ev2)

% returns start and end time of a window defined by an event(s)
% [Win,EvTimes] = spk_getEventWindow(s,Ev1,Ev2)
%
% Ev1 ... char: eventlabel
% Ev2 ... eventlabel or offset-window (two column vector)


nTrTotal = spk_TrialNum(s);
[cTr,s] = spk_CheckCurrentTrials(s);
nTr = length(s.currenttrials);

%% get time window
Win = ones(nTr,2).*NaN;

%% get event index
if ischar(Ev1) || iscell(Ev1)
    EvNr = spk_findEventlabel(s,Ev1);
elseif isnumeric(Ev1)
    EvNr = Ev1;
end
nEv = length(EvNr);

%% get event trials
if ~ischar(Ev1) || isempty(Ev1)
    error('Input Ev1 must be char array!');
else
    EvTimes = s.events(EvNr,cTr);
    if any(cellfun('length',EvTimes))>1
        error('More than 1 event in trial!');
    elseif any(cellfun('length',EvTimes))==0
        error('No event in trial!');
    end        
    EvTimes = cat(1,EvTimes{:});
end

%% combine with offset
if isempty(Ev2)
    Win = EvTimes;
    %Win = repmat(EvTimes,[1 2]);
elseif ischar(Ev2)
    [EvOffsetTimes,i] = spk_getEvents(s,Ev2);
    Win = [EvTimes cat(1,EvOffsetTimes{:})];
elseif isnumeric(Ev2)
    Win = repmat(EvTimes,[1 2]) + repmat(Ev2,[length(EvTimes) 1]);
end

