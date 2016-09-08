function s = spk_NLX_reloadNSE(s,NSE,NLXClusterNr,SPKChanName,SPKUnitName,NLXWin,WinMode,ClearChannels)

% reads spike data from a NSE structure
%
% NSE ................ NSE structure, see Neuralynx Tools
% NLXClusterNr ....... select clusters to read in
% SPKChanName ........ Channel names for new clusters, must be same length like NLXClusterNr
% SPKUnitName ........ Unitnames for new clusters, must be same length like NLXClusterNr
% NLXWin ............. time window for every trial in NLX time (microsec), trials along rows.
% WinMode ............ 'REL' NLXWin times are relative. s.align is used to construct neuralynx times
%                      'ABS' NLXWin times are absolute neuralynx times s.align is substracted for alignment
% ClearChannels ...... clear all channels

TimeDimDiff = (-6) - s.timeorder;
numTrials = size(s.events,2);
nClust = length(NLXClusterNr);
if nClust~=length(SPKChanName) || nClust~=length(SPKUnitName)
    error('Number of clusters and channel names must be equal!');
end

%% reorganise channels
if nargin==8 && ClearChannels
    s.spk = cell(nClust,numTrials);
    s.channel = cell(1,nClust);
    s.unittype = cell(1,nClust);
    ChNr = 1:nClust;
else
    % replace existing ones 
    ChNr = 1:nClust;
    NumChan = spk_SpikeChanNum(s);
    [isExistChan,ReplaceIndex] = ismember(SPKChanName,s.channel);
    NumRepChan = sum(isExistChan);
    ChNr(isExistChan) = ReplaceIndex;   
    
    % add non existing ones
    NumAddChan = sum(~isExistChan);
    s.channel(NumChan+1:NumChan+NumAddChan) = {''};
    s.unittype(NumChan+1:NumChan+NumAddChan) = {''};
    AddChanNr = find(~isExistChan);
    for i = 1:NumAddChan
        ChNr(AddChanNr(i)) = NumChan+i;
    end
end

%% loop trials
hwait = waitbar(0,'Extract spikes from neuralynx NSE file ...');
for i = 1:numTrials
    for j = 1:nClust
		switch upper(WinMode)
			case 'REL'
				if size(NLXWin,1)>1
					s.spk{ChNr(j),i} =  NSE.TimeStamps(NSE.ClusterNr==NLXClusterNr(j) & NSE.TimeStamps>=(NLXWin(i,1)+s.align(i))./(10^TimeDimDiff) & NSE.TimeStamps<=(NLXWin(2)+s.align(i))./(10^TimeDimDiff)) .* (10^TimeDimDiff) - s.align(i);
				else
					s.spk{ChNr(j),i} =  NSE.TimeStamps(NSE.ClusterNr==NLXClusterNr(j) & NSE.TimeStamps>=(NLXWin(1)+s.align(i))./(10^TimeDimDiff) & NSE.TimeStamps<=(NLXWin(2)+s.align(i))./(10^TimeDimDiff)) .* (10^TimeDimDiff) - s.align(i);
				end
			case 'ABS'
				if size(NLXWin,1)>1
					s.spk{ChNr(j),i} =  NSE.TimeStamps(NSE.ClusterNr==NLXClusterNr(j) & NSE.TimeStamps>=NLXWin(i,1) & NSE.TimeStamps<=NLXWin(i,2)) .* (10^TimeDimDiff) - s.align(i);
				else
					error('');
				end
				
		end
    end
    waitbar(i/numTrials,hwait);
end
close(hwait);

    
    