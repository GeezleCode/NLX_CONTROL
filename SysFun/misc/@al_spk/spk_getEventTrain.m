function EvTrain = spk_getEventTrain(s,cTr)

% converts events to event trainz
% EvTrain = spk_getEventTrain(s)
%
% cTr ... set current trials

nTrTotal = spk_TrialNum(s);
if nargin>1
    s.currenttrials = cTr;
end
[cTr,s] = spk_CheckCurrentTrials(s);
nTr = length(s.currenttrials);
[nEvLabel,nTrTotal] = size(s.events);

EvNum = cellfun('length',s.events);
EvSum = sum(EvNum,1);

%%
EvTr = cell(1,nTr);
for iTr = 1:nTr
    EvTrain{iTr} = zeros(EvSum(cTr(iTr)),2);
    EvCnt = 0;
    for cEv = 1:nEvLabel
        if EvNum(cEv,cTr(iTr)) > 0
            EvTrain{iTr}(EvCnt+1:EvCnt+EvNum(cEv,cTr(iTr)),2) = cEv;
            EvTrain{iTr}(EvCnt+1:EvCnt+EvNum(cEv,cTr(iTr)),1) = s.events{cEv,cTr(iTr)};
        end
        EvCnt = EvCnt+EvNum(cEv,cTr(iTr));
    end
    [EvTrain{iTr}(:,1),srti] = sort(EvTrain{iTr}(:,1));
    EvTrain{iTr}(:,2) = EvTrain{iTr}(srti,2);
end
