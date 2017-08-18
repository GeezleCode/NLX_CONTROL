function [TrialCodes,TrialCodeLabelIndex] = spk_gettrialcodes(s,TrialCodeLabel)

% returns the trial codes trials trials given in s.currenttrials ; set by >>spk_set(s,'currentrials',[ ... ])
% [TrialCodes,TrialCodeLabelIndex] = spk_gettrialcodes(s,TrialCodeLabel)

TrialCodeLabelIndex = spk_findtrialcodelabel(s,TrialCodeLabel);

if size(s.trialcode,1)<TrialCodeLabelIndex
    TrialCodes = [];
elseif isempty(s.currenttrials)
    TrialCodes = s.trialcode(TrialCodeLabelIndex,:);
%     if strcmp(TrialCodeLabel,'StimulusCode')==1
% CndNum=s.trialcode(TrialCodeLabelIndex,:);
% BlkNm = s.trialcode(2,:);
% TrialCodes =36*(BlkNm-1)+CndNum;
% end

else
    TrialCodes = s.trialcode(TrialCodeLabelIndex,s.currenttrials);
%     if strcmp(TrialCodeLabel,'StimulusCode')==1
% CndNum=s.trialcode(TrialCodeLabelIndex,:);
% BlkNm = s.trialcode(2,:);
% TrialCodes =36*(BlkNm-1)+CndNum;
% end

end







