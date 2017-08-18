function [out,s] = spk_CheckCurrentTrials(s,SetAllIfEmpty)
if isempty(s.currenttrials) & SetAllIfEmpty~=0
%     warning('''currentrials'' field is not set. Process all Trials!');
	NumTrials = spk_TrialNum(s);
    s.currenttrials = [1:NumTrials];
elseif isempty(s.currenttrials) & SetAllIfEmpty==0
%     warning('''currentrials'' field is not set!');
end
out = s.currenttrials;   