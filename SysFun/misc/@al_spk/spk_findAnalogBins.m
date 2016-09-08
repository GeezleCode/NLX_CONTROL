function [i,t] = spk_findAnalogBins(s,ChanName,Win)

% returns analog time bins for given windows
% [i,t] = spk_findAnalogBins(s,ChanName,Win)
%
% i ... mat [nWin x 2 x nChan] start and stop bin indices
% t ... cell [nChan] time stamps of bins

nWin = size(Win,1);

%% get the channel index
if nargin<2 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_findAnalog(s,ChanName);
end
nChan = length(iChan);


%% get time vector for this channel
i = ones(nWin,2,nChan).*NaN;
for iCh = 1:nChan
    s.currentanalog = iChan(iCh);
    t{iCh} = spk_AnalogTimeVec(s);
    for iWin = 1:nWin
        iBins = t{iCh}>=Win(iWin,1) & t{iCh}<=Win(iWin,2);
        i(iWin,1,iCh) = find(iBins,1,'first');
        i(iWin,2,iCh) = find(iBins,1,'last');
    end
end
