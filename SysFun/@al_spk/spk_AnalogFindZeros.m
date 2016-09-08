function [zeroT,zeroV,zeroB] = spk_AnalogFindZeros(s,TW,ChanName)

% finds zero bins
% [zeroT,zeroV,zeroB] = spk_AnalogFindZeros(s,TW,ChanName)
%
%


%% get the channel index
iChan = spk_findAnalog(s,ChanName);
s.currentanalog = iChan;

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
nTr = length(s.currenttrials);

%% get window
tVec = spk_AnalogTimeVec(s);
if ~isempty(TW)
    BW = find(tVec>=TW(1)&tVec<=TW(2));
else
    BW = 1:length(tVec);
end

%% find zeros
Y = s.analog{iChan}(s.currenttrials,BW);
PreZeroBins = (Y(:,1:end-1)<0 & Y(:,2:end)>0) | (Y(:,1:end-1)>0 & Y(:,2:end)<0);
ZeroBins = Y==0;

for iTr=1:nTr
    zeroB{iTr} = [];
    if any(PreZeroBins(iTr,:))
        zeroB{iTr}(:,1) = find(PreZeroBins(iTr,:))';
        zeroB{iTr}(:,2) = zeroB{iTr}(:,1)+1;
    end
        
    if any(ZeroBins(iTr,:))
        zeroB{iTr} = cat(1,zeroB{iTr},[find(ZeroBins(iTr,:))' find(ZeroBins(iTr,:))']);
    end
        
    zeroB{iTr} = zeroB{iTr}+BW(1)-1;
    zeroT{iTr} = tVec(zeroB{iTr});
    if isempty(zeroB{iTr})
        zeroV{iTr} = [];
    else
        zeroV{iTr} = [s.analog{iChan}(s.currenttrials(iTr),zeroB{iTr}(:,1))' s.analog{iChan}(s.currenttrials(iTr),zeroB{iTr}(:,2))'];
    end
end

