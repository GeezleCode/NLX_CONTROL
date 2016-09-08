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
spk_StimulusCodeInd = strmatch('StimulusCode',trialcodelabel,'exact');

%% add trials
ci = SPKNumTrials+1;
    
%% trialcodes
TRIALCODE = zeros(trialcodelabel_n,1).*NaN;
TRIALCODE(spk_CTXtrialIDind) = CTX.TrialID(CTX.Pointer);
TRIALCODE(spk_CortexBlockInd) = CTX.Block(CTX.Pointer);
TRIALCODE(spk_CortexConditionInd) = CTX.Condition(CTX.Pointer);
% if NLX_CONTROL_SETTINGS.CutCortexTrial == 0
    TRIALCODE(spk_StimulusCodeInd) = CTX.StimulusCodes(CTX.Pointer,1);
    TRIALCODE(spk_CortexPresentationNrInd) = NaN;
% elseif NLX_CONTROL_SETTINGS.CutCortexTrial == 1
%     TRIALCODE(spk_StimulusCodeInd) = CTX.StimulusCodes(i);
%     TRIALCODE(spk_CortexPresentationNrInd) = i;
% end
    
%% every trial in data structure has ALL the Evs of a
% CTX trial
EVENTS = cell(Evlabel_n,1);
for j=1:Evlabel_n
    currEventInd = strmatch(Evlabel{j},NLX_CONTROL_SETTINGS.EventName,'exact');
    if isempty(currEventInd)
        EVENTS{j} = [];
    else
        iEv = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.EventCode(currEventInd),acqwin,0);
        if ~isempty(iEv)
            EVENTS{j} = Ev.TimeStamp(iEv)' - aligntime;
        else
            EVENTS{j} = [];
        end
    end
end
    
% SEs
SPK = cell(nCh,1);
for k = 1:nCh
    SPKindex = strmatch(ClusterName{k},channel);
    cEl = strtok(ClusterName{k},'.');
    ClusterNr = sscanf(ClusterName{k},[cEl '.%d']);
    ElNr = strmatch(cEl,SEObj,'exact');
    SPK{SPKindex} = SE{ElNr}.TimeStamp(SE_findSpike(SE{ElNr},acqwin,ClusterNr))' - aligntime;
end

%% push to SPK
s = spk_addTrialData(s,ci, ...
    'trialcode',TRIALCODE, ...
    'events',EVENTS, ...
    'spk',SPK, ...
    'align',aligntime, ...
    'stimulus',CTX.ParamArray(CTX.Pointer), ...
    'analog',{[]});

