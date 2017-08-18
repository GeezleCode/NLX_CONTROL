function s = spk_addTrialcode(s,TrialcodeLabel,TrialcodeValue,TrialNr)

numTrialcodeLabel =  size(s.trialcodelabel,2);
numTrials =  size(s.trialcode,2);

TrialcodeLabelIndex = strmatch(upper(TrialcodeLabel),upper(s.trialcodelabel),'exact');
if isempty(TrialcodeLabelIndex)
    TrialcodeLabelIndex = numTrialcodeLabel + 1;
    s.trialcodelabel{TrialcodeLabelIndex} = TrialcodeLabel;
    if numTrials>0
        s.trialcode{TrialcodeLabelIndex,1:numTrials} = ones(1,numTrials).*NaN;
    end
end
    
% set values of trialcode
if nargin>2
    s.trialcode(TrialcodeLabelIndex,TrialNr) = TrialcodeValue;
end
