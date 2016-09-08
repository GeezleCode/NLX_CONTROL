function uniTC = spk_TrialcodeUnique(s,TrialcodeLabel,RoundIndex)

% unique combinations of trialcode

i = spk_findTrialcodelabel(s,TrialcodeLabel);
[currenttrials,s] = spk_CheckCurrentTrials(s,true);
TC = s.trialcode(i,currenttrials)';

if nargin<3 || isempty(RoundIndex)
    RoundIndex = false(size(TrialcodeLabel));
end
TC(:,RoundIndex) = round(TC(:,RoundIndex));

uniTC = unique(TC,'rows'); 