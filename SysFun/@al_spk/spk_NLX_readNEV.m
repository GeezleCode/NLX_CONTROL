function [s,UserEv] = spk_NLX_readNEV(s,NEVpath,NLXTimeWin,par)

% Constructs trials from a neuralynx events file into a al_spk structure
% uses NLX_NEV2Trials.m from neuralynx tools collection
%
% s = spk_NLX_readNEV(s,NEVpath,NLXTimeWin,par)
%
% NEVpath ...... full path to file
% NLXTimeWin ... time window in neuralynx time
% par .......... settings structure with fields
%               TrialStartEvent                8-bit Eventcode
%               TrialEndEvent                  8-bit Eventcode
%               SendConditionStart             Sequence of 8-bit Eventcode
%               SendConditionEnd               Sequence of 8-bit Eventcode
%               SendParamStart                 Sequence of 8-bit Eventcode
%               SendParamEnd                   Sequence of 8-bit Eventcode
%               EventName{1-n}                 char Eventname              
%               EventCode[1-n]                 Sequence of 8-bit Eventcode
%               Align2CortexEvent              Sequence of 8-bit Eventcode
%               PresentationNum                Number of trials within trial
%               SendConditionTag{1-n}          e.g. 'block' 'condition' 'stimcode1' 'stimcode2' ... 'stimcodeN'
%               CurrTrialAlignEventName        char EventName to align to
%               ReadDataEvent                  8-bit Eventcode

s.file = NEVpath;
s.date = datestr(now);

%% read the NEV file and extract trial events 
[Events,ConditionData,ParamData,UserEv] = NLX_NEV2Trials( ...
	NEVpath, ...
	NLXTimeWin, ...
	{[par.TrialStartEvent] [par.TrialEndEvent]}, ...
	{[par.SendConditionStart] [par.SendConditionEnd]}, ...
	{[par.SendParamStart] [par.SendParamEnd;par.SendParamEnd]});

%% detect/remove conditions that do not match par.SendConditionTag
nCndData = length(par.SendConditionTag);
falseCndind = find(cellfun('size',ConditionData,1) ~= nCndData);
Events(falseCndind) = [];
ConditionData(falseCndind) = [];
ParamData(falseCndind) = [];
nTr = size(Events,2);

%% convert time units
s.timeorder = -3;
for iTr = 1:nTr
    Events{iTr}(:,1) = Events{iTr}(:,1).*10^(-6-s.timeorder);
end

%% create event arrays
UniEv = cat(1,Events{:});
UniEv = unique(UniEv(:,2));
[TF,LOC] = ismember(UniEv,par.EventCode);

EvLabelName = par.EventName(LOC(TF));
EvLabelCode = num2cell(UniEv(TF));

EvLabelName(end+1) = {'unknown'};
EvLabelCode(end+1) = {UniEv(~TF)};

EvLabelCode = cat(1,EvLabelCode{1:end-1});
EvLabelCode(end+1) = NaN;

%% get event label
s.eventlabel = EvLabelName';
nEv = length(EvLabelCode);

%% get align event
if isfield(par,'Align2CortexEvent') && ~isempty(par.Align2CortexEvent)
    alignevent_i = EvLabelCode==par.Align2CortexEvent;
    if ~any(alignevent_i)
        error('Align-event is does not exist!');
    else
        s.alignevent = EvLabelName{alignevent_i};
    end
else
    % find event that occurs in every trial just once
    EvCnt = ones(nEv,nTr);
    for iTr = 1:nTr
        for iEv = 1:nEv
            EvCnt(iEv,iTr) = sum(Events{iTr}(:,2)==EvLabelCode(iEv));
        end
    end
    iEv = find(all(EvCnt==1,2));
    s.alignevent = EvLabelName{iEv(1)};
    par.Align2CortexEvent = EvLabelCode(iEv(1));
end    

%% get align times
s.align = ones(1,nTr).*NaN;
for iTr=1:nTr
    Idx = Events{iTr}(:,2) == par.Align2CortexEvent;
    if any(Idx) && sum(Idx)==1
        s.align(iTr) = Events{iTr}(Idx,1);
    end
end

%% get events
s.events = cell(nEv,nTr);
for iTr = 1:nTr
    for iEv = 1:nEv
        s.events{iEv,iTr} =  Events{iTr}(  Events{iTr}(:,2)==EvLabelCode(iEv)  ,1) - s.align(iTr);
    end
end

%% convert Condition data in trialcodes
s.trialcodelabel = cell(nCndData,1);
s.trialcode = zeros(nCndData,nTr).*NaN;
for iTC = 1:nCndData
    s.trialcodelabel(iTC) = par.SendConditionTag(iTC);
    for iTr = 1:nTr
        s.trialcode(iTC,iTr) = ConditionData{iTr}(iTC,2);
    end
end

%% ParamData
s.stimulus =  ParamData;

s.settings.nlx_settings = par;
