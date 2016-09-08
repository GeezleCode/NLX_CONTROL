function [y,TrialCodes] = spk_TrialGrouping(s,GroupTerm)

% Automatic grouping of trials according to a trialcode label
% [y,TrialCodes] = spk_TrialGroups(s,GroupTerm)
% GroupTerm .... char , a trialcode label
% y ............ cell array containing trial indices
% TrialCodes ... trialcodes according to y

if ischar(GroupTerm)
    iGrp = strcmp(GroupTerm,s.trialcodelabel);
elseif iscell(GroupTerm)
    iGrp = ismember(s.trialcodelabel,GroupTerm);
end

%% check GroupTerm
if ~any(iGrp)
    fprintf(1,['Did not find trialcodelabel called ' GroupTerm '!\n']);
    fprintf(1,['choose from:\n']);
    fprintf(1,['%s\n'],s.trialcodelabel{:});
    error('');
end

%% Get the trialcodes
TrialcodeLabel = s.trialcodelabel(iGrp);
[TrialCodes,Idx1,Idx2] = unique(s.trialcode(iGrp,:)','rows');
nGrps = size(TrialCodes,1);
y = cell(1,nGrps);
for iGrp = 1:nGrps
    y{iGrp} = find(Idx2==iGrp);
end

