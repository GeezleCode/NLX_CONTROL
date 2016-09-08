function [TrialCodes,TrialCodeLabelIndex] = spk_getTrialcode(s,TrialCodeLabel)

% returns the trial codes; omit input for info
% [TrialCodes,TrialCodeLabelIndex] = spk_getTrialcodes(s,TrialCodeLabel)

%% show trialcode info
[nTc,nTr] = size(s.trialcode);
if nargin<2
    fprintf(1,'Used trialcodes:\n');
    for i=1:nTc
        fprintf(1,'%25s\t',s.trialcodelabel{i});
        fprintf(1,'%1.1f ',unique(s.trialcode(i,:)));
        fprintf(1,'\n');
    end
    return;
end

if isempty(s.currenttrials)
	s.currenttrials = 1:nTr;
else
    nTr = length(s.currenttrials);
end
   
%% check input
if iscell(TrialCodeLabel)
    nTCL = length(TrialCodeLabel);
    TrialCodes = zeros(nTCL,nTr).*NaN;
    for i=1:nTCL
        cTrialCodeLabelIndex = find(strcmp(TrialCodeLabel{i},s.trialcodelabel));
        if isempty(cTrialCodeLabelIndex)
            TrialCodeLabelIndex(i) = NaN;
        else
            TrialCodeLabelIndex(i) = cTrialCodeLabelIndex;
            TrialCodes(i,:) = s.trialcode(TrialCodeLabelIndex(i),s.currenttrials);
        end
    end
else
    TrialCodeLabelIndex = find(strcmp(TrialCodeLabel,s.trialcodelabel));
    if size(s.trialcode,1)<TrialCodeLabelIndex
        TrialCodes = [];
    else
        TrialCodes = s.trialcode(TrialCodeLabelIndex,s.currenttrials);
    end
end
