function [TrWin,Trialcode,EpWin] = spk_TrialcodeEpochs(s,TrialcodeLabel,EventWin)

% Gets time windows of epochs of trials with same trialcode
% [TrWin,Trialcode,EpWin] = spk_TrialcodeEpochs(s,TrialcodeLabel,EventWin)

iTC = spk_findTrialcodelabel(s,TrialcodeLabel);
nTr = spk_TrialNum(s);
TrWin(:,1) = [1 find(diff(s.trialcode(iTC,:))~=0)+1]';
TrWin(:,2) = [find(diff(s.trialcode(iTC,:))~=0)+1 nTr]';
nEp = size(TrWin,1);
Trialcode = s.trialcode(iTC,TrWin(:,1));

if nargout<3;
    return;
end

%% get event times
s.currenttrials = [];
if nargin<3 || isempty(EventWin)
    tWin = spk_TrialEventLimit(s);
else
    tWin = spk_TrialEventWindow(s,EventWin{1},EventWin{2});
end
EpWin(:,1) = tWin(TrWin(:,1),1);
EpWin(:,2) = tWin(TrWin(:,2),2);


