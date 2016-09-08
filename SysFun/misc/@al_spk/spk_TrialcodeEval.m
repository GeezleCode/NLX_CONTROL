function s = spk_TrialcodeEval(s,TrialCodeLabel,EvalTerm)

% computation on trialcode values according to an EvalTerm,
% e.g. 'x=x+1', where x are trialcode values of selected trialcodelabels

iTC = spk_findTrialcodelabel(s,TrialCodeLabel);
nTr = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end
x = s.trialcode(iTC,s.currenttrials);
eval(EvalTerm);
s.trialcode(iTC,s.currenttrials) = x;
