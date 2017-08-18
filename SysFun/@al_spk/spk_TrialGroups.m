function [y,TrialCodes] = spk_TrialGroups(s,GroupTerm)

% group trials according to a trialcode label
% [y,TrialCodes] = spk_TrialGroups(s,GroupTerm)
% GroupTerm .... char , a trialcode label
% y ............ cell array containing trial indices
% TrialCodes ... trialcodes according to y

%% check GroupTerm
iGrp = strmatch(GroupTerm,s.trialcodelabel,'exact');
if isempty(iGrp)
    fprintf(1,['Did not find trialcodelabel called ' GroupTerm '!\n']);
    fprintf(1,['choose from:\n']);
    fprintf(1,['%s\n'],s.trialcodelabel{:});
    error('');
end

%% Get the trialcodes
TrialCodes = unique(s.trialcode(iGrp,:));
nTrCd = length(TrialCodes);
y = cell(1,nTrCd);
for iTrCd = 1:nTrCd
    y{iTrCd} = find(s.trialcode(iGrp,:)==TrialCodes(iTrCd));
end

