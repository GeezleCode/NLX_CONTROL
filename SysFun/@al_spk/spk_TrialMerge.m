function y = spk_TrialMerge(s,MergeIndex,TrialCodeConversion)

% Merges trial data
% s = spk_TrialMerge(s,MergeIndex)
%
% MergeIndex ............ cell array with indices to merge
% TrialCodeConversion ... n X 2 cell array. First column gives the
%                         trialcodelabel to convert. Second column gives
%                         the new trialcodelabels. The value of each trial
%                         forms a value of new to which each of the old
%                         trialcodelabel get.
%                         e.g. {'oldTrialCode' {'newTrialCode1'
%                         'newTrialCode2'...}}
%                         TrialCodeLabel not in first column of 
%                         TrialCodeConversion all take the TrialCodeValue
%                         of the first trial in MergeIndex.

nM = length(MergeIndex);

%% prepare output
s = spk_Align(s,[],4);% recreate original timedata
y = s;

%% merge EVENT data
nEv = size(s.events,1);
y.events = cell(nEv,nM);
for iM = 1:nM
    nMergeTr = length(MergeIndex{iM});
    for iEv = 1:nEv
        y.events{iEv,iM} = cat(1,s.events{iEv,MergeIndex{iM}});
        y.events{iEv,iM} = unique(y.events{iEv,iM});% eradicate duplicates
    end
end

%% merge TRIALCODES
[nTC,nTr] = size(s.trialcode);
y.trialcode = ones(nTC,nM).*NaN;
% first use trialcodes of all the first trials
for iM = 1:nM
    for iTC = 1:nTC
        y.trialcode(iTC,iM) = s.trialcode(iTC,MergeIndex{iM}(1));
    end
end
% create new trialcodes and assign values
if ~isempty(TrialCodeConversion)
    [TCLabel2Convert,TCLabel2ConvertIndex] = ismember(s.trialcodelabel,TrialCodeConversion(:,1));
    TCLabel2Convert = find(TCLabel2Convert);
    nTCLabel2Convert = length(TCLabel2Convert);

    for i = 1:nTCLabel2Convert
        cTCNr = size(y.trialcode,1);
        NewTrialCodeLabel = TrialCodeConversion{TCLabel2ConvertIndex(TCLabel2Convert(i)),2};
        nNewTrialCodeLabel = length(NewTrialCodeLabel);
        NewTrialCodeLabelIndex = cTCNr+1:cTCNr+nNewTrialCodeLabel;
        y.trialcode(NewTrialCodeLabelIndex,:) = NaN;
        y.trialcodelabel(NewTrialCodeLabelIndex) = NewTrialCodeLabel;
        
        for iM = 1:nM
            y.trialcode(NewTrialCodeLabelIndex,iM) = s.trialcode(TCLabel2Convert(i),MergeIndex{iM});
        end
    end
end

%% merge SPIKE data
y.channel = {};
y.spk = {};

%% merge ANALOG data
y.analog = {}; 
y.analogtime = []; 
y.analogalignbin = [];

%% 
y.align = [];
y.alignevent = '';
