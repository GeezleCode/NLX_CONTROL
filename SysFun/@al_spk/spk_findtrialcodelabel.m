function i = spk_findtrialcodelabel(s,trialcodelabel)

% returns the index of a trialcodelabel
%
% i = spk_findtrialcodelabel(s,trialcodelabel)

i = strmatch(upper(trialcodelabel),upper(s.trialcodelabel),'exact');

