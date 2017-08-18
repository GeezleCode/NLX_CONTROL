function [TrialCodes,TrialCodeLabelIndex] = spk_getTrialcode(s,TrialCodeLabel)

% returns the trial codes; omit input for info
% [TrialCodes,TrialCodeLabelIndex] = spk_getTrialcodes(s,TrialCodeLabel)

%% show trialcode info
if nargin<2
    [nTc,nTr] = size(s.trialcode);
    fprintf(1,'Used trialcodes:\n');
    for i=1:nTc
        fprintf(1,'%25s\t',s.trialcodelabel{i});
        fprintf(1,'%1.1f ',unique(s.trialcode(i,:)));
        fprintf(1,'\n');
    end
    return;
end
   
%% get the trialcodes
TrialCodeLabelIndex = strmatch(TrialCodeLabel,s.trialcodelabel,'exact');
if size(s.trialcode,1)<TrialCodeLabelIndex
    TrialCodes = [];
elseif isempty(s.currenttrials)
    TrialCodes = s.trialcode(TrialCodeLabelIndex,:);
else
    TrialCodes = s.trialcode(TrialCodeLabelIndex,s.currenttrials);
end