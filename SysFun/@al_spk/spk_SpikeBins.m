function [M,t] = spk_SpikeBins(s,Ev,TimeWin,BinWidth,DeMeanFlag)

% converts a cell array of spike times to a matrix
% uses hist for the calculation
% [M,Bins] = spk_SpikeBins(s,Ev,TimeWin,BinWidth)
%
% Ev .......... reference event
% TimeWin ..... timelimit of the matrix
% BinWidth .... binwidth of the matrix
% M ............. [timebins,trials,channels]

if nargin<5
    DeMeanFlag = false;
end

%% trials
[TrNr,s] = spk_CheckCurrentTrials(s,true);
nTrs = length(TrNr);

%% channels
[ChanNr,s] = spk_CheckCurrentChannels(s,true);
nCh = length(ChanNr);

%% binning
BinEdges = [TimeWin(1) : BinWidth : TimeWin(2)];
BinCentres = BinEdges(1:end-1)+BinWidth/2;
nBn = length(BinCentres);
M = zeros(nBn+1,nTrs,nCh);% last bin equals last edge

%% reference event
EvTimes = spk_getEvents(s,Ev,1);

%% loop trials and channels
for iLoop=1:[nCh*nTrs]
    [iCh,iTr] = ind2sub([nCh,nTrs],iLoop);
    if ~isempty(s.spk{iCh,iTr})
         M(:,iTr,iCh) = histc(s.spk{iCh,iTr}-EvTimes(iTr),BinEdges);
    end
end

%% remove last bin
t = BinCentres;
M(end,:,:) = [];%remove last bin

%% remove DC component
if DeMeanFlag
    for iLoop=1:[nCh*nTrs]
        [iCh,iTr] = ind2sub([nCh,nTrs],iLoop);
        M(:,iTr,iCh) = M(:,iTr,iCh) - agmean(M(:,iTr,iCh),[],1);
    end
end
    
			
		
