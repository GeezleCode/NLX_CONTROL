function s = spk_NLX_readNSE(s,NSE,NLXWin,ElName,WinMode,AddChannelFlag)

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
% AddChannelFlag ..... if 1 existing channels won't be deleted

if nargin<6
	AddChannelFlag = 0;
	if nargin<5
		WinMode = 'ABS';
		if nargin<4
			ElName = 'Sc1';
		end;end;end

TimeDimDiff = (-6) - s.timeorder;

% check clusters
NLXcells = unique(NSE.ClusterNr);
NLXcellNum = length(NLXcells);
if NLXcellNum==0
    warning('spk_NLX_readNSE: did not find any spikes!');
    return;
end
for i=1:NLXcellNum
	ChannelNames{i} = sprintf([ElName '.%02.0f'],NLXcells(i));
end

% clear object from spike data
numTrials = size(s.events,2);

if AddChannelFlag
	NumChan = size(s.spk,1);
    if any(ismember(s.channel,ChannelNames))
        error('Found duplicate channel names!');
    end
    if isempty(s.channel)&NumChan==0
        s.spk = {};
        s.channel = {};
    end
	s.spk(NumChan+1:NumChan+NLXcellNum,:) = {[]};
	s.channel(NumChan+1:NumChan+NLXcellNum) = ChannelNames;
else
	NumChan = 0;
	s.spk = cell(NLXcellNum,numTrials);
	s.channel = ChannelNames;
end

% loop trials
hwait = waitbar(0,'Extract spikes from neuralynx NSE file ...');
for i = 1:numTrials
    
	% load spike times into object
    for j = 1:NLXcellNum
        chanInd = NumChan+j;
		% load spikes
		% extract the ncs data
		switch upper(WinMode)
			case 'REL'
				if size(NLXWin,1)>1
					s.spk{chanInd,i} =  NSE.TimeStamps(NSE.ClusterNr==NLXcells(j) & NSE.TimeStamps>=(NLXWin(i,1)+s.align(i))./(10^TimeDimDiff) & NSE.TimeStamps<=(NLXWin(2)+s.align(i))./(10^TimeDimDiff)) .* (10^TimeDimDiff) - s.align(i);
				else
					s.spk{chanInd,i} =  NSE.TimeStamps(NSE.ClusterNr==NLXcells(j) & NSE.TimeStamps>=(NLXWin(1)+s.align(i))./(10^TimeDimDiff) & NSE.TimeStamps<=(NLXWin(2)+s.align(i))./(10^TimeDimDiff)) .* (10^TimeDimDiff) - s.align(i);
				end
			case 'ABS'
				if size(NLXWin,1)>1
					s.spk{chanInd,i} =  NSE.TimeStamps(NSE.ClusterNr==NLXcells(j) & NSE.TimeStamps>=NLXWin(i,1) & NSE.TimeStamps<=NLXWin(i,2)) .* (10^TimeDimDiff) - s.align(i);
				else
					error('');
				end
				
		end
    end
    waitbar(i/numTrials,hwait);
end
close(hwait);

    
    