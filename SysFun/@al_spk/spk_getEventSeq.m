function Seq = spk_getEventSeq(s,Ev)

% Detects event sequence and returns timestamps
% Seq = spk_getEventSeq(s,Ev)
% Ev ......... sequence of events [event index] or {eventlabel}
% Seq ........ TimeStamps [nTrials x nSequence]
%
% e.g. Seq = spk_getEventSeq(s,{'NLX_STIM_ON' 'NLX_STIM_OFF' 'NLX_STIM_ON' 'NLX_STIM_OFF'})
%
% Seq =
% 
%   1.0e+003 *
% 
%     0.5097    1.2070    1.9043    2.6135
%     0.5106    1.2079    1.9052       NaN
%     0.5065    1.2038    1.9129    2.6102
%     0.5089    1.2061    1.9035    2.6126 ...

nTrTotal = spk_TrialNum(s);
[cTr,s] = spk_CheckCurrentTrials(s);
nTr = length(cTr);

%% get event index
if ischar(Ev) || iscell(Ev)
    EvNr = spk_findEventlabel(s,Ev);
elseif isnumeric(Ev)
    EvNr = Ev;
end
nEv = length(EvNr);

%% convert to event trains
EvTrain = spk_getEventTrain(s);

%% get time window
Seq = ones(nTr,nEv).*NaN;

for iTr = 1:nTr   
    for iEv = 1:nEv
        cEvIdx = [];
        if iEv==1
            % get the first event
            cEvIdx = find(EvTrain{iTr}(:,2)==EvNr(iEv)    ,1,'first');
        elseif ~isnan(Seq(iTr,iEv-1))
            % make sure this event is later than previous event in sequence
            cEvIdx = find(EvTrain{iTr}(:,1)>Seq(iTr,iEv-1) &  EvTrain{iTr}(:,2)==EvNr(iEv)   ,1,'first');
        end
        if ~isempty(cEvIdx)
            Seq(iTr,iEv) = EvTrain{iTr}(cEvIdx,1);
        end
    end
end
