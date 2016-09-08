function s = spk_addTrialcode(s,TrialcodeLabel,TrialcodeValue,TrialNr)

% adds trialcode to the object
% s = spk_addTrialcode(s,TrialcodeLabel,TrialcodeValue,TrialNr)
% TrialcodeLabel ... cell|char; add new trialcode category, trialcode values default
%                    to NaN
% TrialcodeValue ... trialcode values for trials given in TrialNr
% TrialNr .......... trial index, must match TrialcodeValue

%% check trials
numTrials =  size(s.trialcode,2);
if nargin<4 || isempty(TrialNr)
    TrialNr = 1:numTrials;
end

%% check trialcodelabel
if ischar(TrialcodeLabel);TrialcodeLabel = {TrialcodeLabel};end
iTrC = spk_findTrialcodelabel(s,TrialcodeLabel);
if any(~isnan(iTrC))
    error('TrialCodeLabel >>%s<< exists, replacing not implemented yet!',TrialcodeLabel{~isnan(iTrC)});
end
nTrCadd = length(TrialcodeLabel);
nTrC = length(s.trialcodelabel);

%% add trialcode
for i = 1:nTrCadd
    iTrC(i) = nTrC+i;
    
    if ~iscell(s.trialcodelabel)
        s.trialcodelabel = {s.trialcodelabel};
    end
    
    s.trialcodelabel(iTrC(i)) = TrialcodeLabel(i);
    
    % set values of trialcode
    if numTrials>0
        s.trialcode(iTrC(i),1:numTrials) = ones(1,numTrials).*NaN;
    end
    if nargin>2 && ~isempty(TrialcodeValue)
        s.trialcode(iTrC(i),TrialNr) = TrialcodeValue(i,:);
    end
end
    

