function [b,tWin,tVec] = spk_AnalogEventWindow(s,Ev,EvOffset)

% returns start and end bins of a window defined by an event(s)
% [b,t] = spk_AnalogEventWindow(s,Ev,EvOffset)
%
% Ev ......... eventlabel or single/nTrial timestamp
% EvOffset ... eventlabel or a [nx2] matrix defining an offset to Ev
%
% b ...... window as bin nr
% tWin ... window as time
% tVec ... sample times of each analog channel

%% get trial numbers
nTrTotal = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTrTotal;
end
nTr = length(s.currenttrials);

%% get the event window
if isempty(Ev)
    Ev = 0;
end
if ischar(Ev)
    % Ev is eventlabel
    tWin = spk_getEventWindow(s,Ev,EvOffset);
elseif isnumeric(Ev)
    if length(Ev)>1
        % Ev is vector timestamp
        Ev = repmat(Ev,[1,2]);
    elseif length(Ev)==1
        % Ev is scalar timestamp
        Ev = repmat(Ev,[nTr,2]);
    end
    tWin = Ev+repmat(EvOffset,[nTr,1]);
end

%% loop thru channels and get bin window
nChan = length(s.currentanalog);
for iCh = 1:nChan
    ChNr = s.currentanalog(iCh);
    tVec{iCh} = spk_AnalogTimeVec(s,ChNr);
    
    for iTr = 1:nTr
        b(iTr,1,iCh) = find(tVec{iCh}>=tWin(iTr,1),1,'first');
        b(iTr,2,iCh) = find(tVec{iCh}<=tWin(iTr,2),1,'last');
    end

end