function [ACH_mat,ACHTimeBins,SpikeNum,SP_mat] = spk_SpikeAutoCorrelation2(s,win,halfwidth)

% calculates the auto correlation histogram
% [ACH_mat,ACHTimeBins] = spk_SpikeAutoCorrelation(s,win,halfwidth)
%
% win ......... calculate the ACH using spikes in this window as center
% halfwidth ... half width of th ACH
%
% ACH_mat ....... autocorrelation histogram 
% ACHTimeBins ... Bin Times
% SpikeNum ...... number of spikes [1,numCurrTrials,numCurrChans]
% SP_mat ........ shift predictor [nACHTimeBins,numCurrTrials,numCurrChans]

ACH_m = [];
ACH_t = [];

[numChans,numTrials] = size(s.spk);
numCurrChans = length(spk_CheckCurrentChannels(s,0));
numCurrTrials = length(spk_CheckCurrentTrials(s,0));

ACHTimeBins = [halfwidth*(-1) : halfwidth]; 
nACHTimeBins = length(ACHTimeBins);

ACH_mat = zeros(nACHTimeBins,numCurrTrials,numCurrChans);
SP_mat = zeros(nACHTimeBins,numCurrTrials,numCurrChans);

for k = 1:numCurrChans
	
	% create spike matrix
	SpWin = [win(1)-halfwidth win(2)+halfwidth];% make sure that you a window big enough
	[SpMat,SpMatBins] = SpikeCell2Mat(s.spk(s.currentchan(k),s.currenttrials),SpWin,1);
	SpMat(SpMat>0) = 1;
	
	% do correlation
	CorrWinIndex = find(SpMatBins>=win(1) & SpMatBins<=win(2));
	if any(SpMat(:))
		[ACH_mat(:,:,k),ACHTimeBins,SP_mat(:,:,k),V] = CorrelateSpikes(SpMat,SpMat,100,[CorrWinIndex(1) CorrWinIndex(end)]);
		SpikeNum(1,:,k) = V(ACHTimeBins==0,:);
	else
		SpikeNum(1,:,k) = 0;
	end
end