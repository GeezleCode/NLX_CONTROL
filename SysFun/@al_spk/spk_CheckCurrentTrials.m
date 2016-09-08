function [currenttrials,s] = spk_CheckCurrentTrials(s,SetAllIfEmpty)

% returns s.currenttrials, if empty it sets all trials
% [currenttrials,s] = spk_CheckCurrentTrials(s,SetAllIfEmpty)
% SetAllIfEmpty ... sets s.currenttrials to all trials, default is true if
%                   omitted

if nargin<2
    SetAllIfEmpty = true;
end

if isempty(s.currenttrials) && SetAllIfEmpty
	NumTrials = spk_TrialNum(s);
    s.currenttrials = [1:NumTrials];
end

currenttrials = s.currenttrials;