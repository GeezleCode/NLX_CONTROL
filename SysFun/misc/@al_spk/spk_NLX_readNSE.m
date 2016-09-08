function s = spk_NLX_readNSE(s,NSE,NLXWin,ElName,WinMode,AddChannelFlag,NLXClusterNr)

% reads spike data from a neuralynx *.nse file
%
% NSE ................ NSE structure, see Neuralynx Tools
% NLXWin ............. time window for every trial in NLX time (microsec), trials
%                           along rows.
% ElName ............. is only used to contruct the channel name
% WinMode ............ 'REL' NLXWin times are relative. s.align is
%                            used to construct neuralynx times
%                      'ABS' NLXWin times are absolute neuralynx times
%                            s.align is substracted for alignment
% AddChannelFlag ..... if true existing channels won't be deleted
% NLXClusterNr ....... select clusters to read in, replace if exist

if nargin<6
	AddChannelFlag = 0;
	if nargin<5
		WinMode = 'ABS';
		if nargin<4
			ElName = 'Sc1';
		end;end;end

TimeDimDiff = (-6) - s.timeorder;

%% check Neuralynx clusters
if nargin<7
    NLXClusterNr = unique(NSE.ClusterNr);
    if any(NLXClusterNr<0 | NLXClusterNr>100)
        NLXClusterNr(NLXClusterNr<0 || NLXClusterNr>100) = [];
    end
end
nNLXCluster = length(NLXClusterNr);   
for i=1:nNLXCluster
	NLXClusterNames{i} = sprintf('%s.%02.0f',ElName,NLXClusterNr(i));
end

%% clear object from spike data
numTrials = size(s.events,2);

if isempty(s.spk)
    s.spk = cell(0,0);
    s.channel = cell(0,0);
end
if AddChannelFlag
    % replace existing channels, add new channels
    NumChan = length(s.channel);
    NewNumChan = NumChan;
    NLXChanNr = zeros(1,nNLXCluster);
    for i = 1:nNLXCluster
        isExistChan =  strcmpi(NLXClusterNames{i},s.channel);
        if any(isExistChan)
            NLXChanNr(i) = find(isExistChan);
            s.spk(NLXChanNr(i),1:numTrials) = {[]};
        else
            NewNumChan = NewNumChan+1;
            NLXChanNr(i) = NewNumChan;
            s.spk(NLXChanNr(i),1:numTrials) = {[]};
            s.channel(NLXChanNr(i)) = NLXClusterNames(i);
        end
    end
else
	NumChan = 0;
	s.spk = cell(nNLXCluster,numTrials);
	s.channel = NLXClusterNames;
    s.unittype = {};
    NLXChanNr = [1:nNLXCluster];
end

%% loop trials
hwait = waitbar(0,'Extract spikes from neuralynx NSE file ...');
for i = 1:numTrials
    
	% load spike times into object
    for j = 1:nNLXCluster
		% load spikes
		% extract the ncs data
		switch upper(WinMode)
			case 'REL'
				if size(NLXWin,1)>1
					s.spk{NLXChanNr(j),i} =  NSE.TimeStamps(NSE.ClusterNr==NLXClusterNr(j) & NSE.TimeStamps>=(NLXWin(i,1)+s.align(i))./(10^TimeDimDiff) & NSE.TimeStamps<=(NLXWin(2)+s.align(i))./(10^TimeDimDiff)) .* (10^TimeDimDiff) - s.align(i);
				else
					s.spk{NLXChanNr(j),i} =  NSE.TimeStamps(NSE.ClusterNr==NLXClusterNr(j) & NSE.TimeStamps>=(NLXWin(1)+s.align(i))./(10^TimeDimDiff) & NSE.TimeStamps<=(NLXWin(2)+s.align(i))./(10^TimeDimDiff)) .* (10^TimeDimDiff) - s.align(i);
				end
			case 'ABS'
				if size(NLXWin,1)>1
					s.spk{NLXChanNr(j),i} =  NSE.TimeStamps(NSE.ClusterNr==NLXClusterNr(j) & NSE.TimeStamps>=NLXWin(i,1) & NSE.TimeStamps<=NLXWin(i,2)) .* (10^TimeDimDiff) - s.align(i);
				else
					error('');
				end
				
		end
    end
    waitbar(i/numTrials,hwait);
end
close(hwait);

    
    