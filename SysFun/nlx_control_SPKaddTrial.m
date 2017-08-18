function [s,ci] = nlx_control_SPKaddTrial(s,ClusterName,SEObj,SE,Ev,CTX,acqwin,aligntime)

global NLX_CONTROL_SETTINGS

nEl = length(SEObj);
nCh = length(ClusterName);

%% change times to milliseconds
Ev.TimeStamp = Ev.TimeStamp.*0.001;
acqwin = acqwin.*0.001;
aligntime = aligntime.*0.001;
for i=1:nEl
    SE{i}.TimeStamp = SE{i}.TimeStamp.*0.001;
end

%% get SPK data
SPKNumTrials = spk_TrialNum(s);
trialcodelabel = spk_get(s,'trialcodelabel');
trialcodelabel_n = length(trialcodelabel);
Evlabel = spk_get(s,'eventlabel');
Evlabel_n = length(Evlabel);
channel = spk_get(s,'channel');

spk_CTXtrialIDind = strmatch('TrialID',trialcodelabel,'exact');
spk_CortexBlockInd = strmatch('CortexBlock',trialcodelabel,'exact');
spk_CortexConditionInd = strmatch('CortexCondition',trialcodelabel,'exact');
spk_CortexPresentationNrInd = strmatch('CortexPresentationNr',trialcodelabel,'exact');
spk_StimulusCodeInd = zeros(1,NLX_CONTROL_SETTINGS.SendConditionPresentParNum);
for i=1:NLX_CONTROL_SETTINGS.SendConditionPresentParNum
    spk_StimulusCodeInd(i) = strmatch(NLX_CONTROL_SETTINGS.SendConditionPresentParName{i},trialcodelabel,'exact');
end

    
%% trialcodes
if NLX_CONTROL_SETTINGS.CutCortexTrial == 0
    TRIALCODE = zeros(trialcodelabel_n,1).*NaN;
    TRIALCODE(spk_CTXtrialIDind) = CTX.TrialID(CTX.Pointer);
    TRIALCODE(spk_CortexBlockInd) = CTX.Block(CTX.Pointer);
    TRIALCODE(spk_CortexConditionInd) = CTX.Condition(CTX.Pointer);
    TRIALCODE(spk_StimulusCodeInd) = CTX.StimulusCodes(CTX.Pointer,1);
    TRIALCODE(spk_CortexPresentationNrInd) = NaN;
elseif NLX_CONTROL_SETTINGS.CutCortexTrial == 1
    TRIALCODE = zeros(trialcodelabel_n,NLX_CONTROL_SETTINGS.PresentationNum).*NaN;
    TRIALCODE(spk_CTXtrialIDind,:) = CTX.TrialID(CTX.Pointer);
    TRIALCODE(spk_CortexBlockInd,:) = CTX.Block(CTX.Pointer);
    TRIALCODE(spk_CortexConditionInd,:) = CTX.Condition(CTX.Pointer);        
    TRIALCODE(spk_CortexPresentationNrInd,:) = 1:NLX_CONTROL_SETTINGS.PresentationNum;
    TRIALCODE(spk_StimulusCodeInd,:) = CTX.StimulusCodes(CTX.Pointer,:,:);
end
    
%% every trial in data structure has ALL the Evs of a
nPresentNum = size(acqwin,1);

% CTX trial
EVENTS = cell(Evlabel_n,nPresentNum);
% loop through the events found in SPK object
for j=1:Evlabel_n
    % find the current event in NLX_CONTROL_SETTINGS 
    currEventInd = strmatch(Evlabel{j},NLX_CONTROL_SETTINGS.EventName,'exact');
    if isempty(currEventInd)
        EVENTS(j,:) = {[]};
    else
        for i=1:nPresentNum
            iEv = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.EventCode(currEventInd),acqwin(i,:),0);
            if ~isempty(iEv)
                EVENTS{j,i} = Ev.TimeStamp(iEv)' - aligntime(i);
            else
                EVENTS{j,i} = [];
            end
        end
    end
end

% SEs
SPK = cell(nCh,nPresentNum);
for k = 1:nCh
    SPKindex = strmatch(ClusterName{k},channel);
    cEl = strtok(ClusterName{k},'.');
    ClusterNr = sscanf(ClusterName{k},[cEl '.%d']);
    ElNr = strmatch(cEl,SEObj,'exact');
    for j=1:nPresentNum
        SPK{SPKindex,j} = SE{ElNr}.TimeStamp(SE_findSpike(SE{ElNr},acqwin(j,:),ClusterNr)) - aligntime(j);
        SPK{SPKindex,j} = SPK{SPKindex,j}(:);
    end
end

%% push to SPK
ci = repmat(SPKNumTrials,1,nPresentNum);
for j=1:nPresentNum
    ci(j) = ci(j)+j;
    s = spk_addTrialData(s,ci(j), ...
        'trialcode',TRIALCODE(:,j), ...
        'events',EVENTS(:,j), ...
        'spk',SPK(:,j), ...
        'align',aligntime(j), ...
        'stimulus',CTX.ParamArray(CTX.Pointer), ...
        'analog',{[]});
end
