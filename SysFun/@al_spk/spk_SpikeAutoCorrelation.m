function [ACH_mat,ACHTimeBins,SpikeNum] = spk_SpikeAutoCorrelation(s,win,halfwidth)

% calculates the auto correlation histogram
% [ACH_mat,ACHTimeBins] = spk_SpikeAutoCorrelation(s,win,halfwidth)
%
% win ......... calculate the ACH using spikes in this window as center
% halfwidth ... half width of th ACH
%

ACH_m = [];
ACH_t = [];

[numChans,numTrials] = size(s.spk);
numCurrChans = length(spk_CheckCurrentChannels(s,0));
numCurrTrials = length(spk_CheckCurrentTrials(s,0));

ACHTimeBins = [halfwidth*(-1) : halfwidth]; 
nACHTimeBins = length(ACHTimeBins);

ACH_mat = zeros(numCurrTrials,nACHTimeBins,numCurrChans);
for k = 1:numCurrChans
	for i = 1:numCurrTrials
		cT = s.currenttrials(i);
		cC = s.currentchan(k);
		
		% get spikes in window and round to milliseconds
		cSpkIndex = find(s.spk{cC,cT}>=win(1) & s.spk{cC,cT}<=win(2));
		cSpkTimes = ceil(s.spk{cC,cT}(cSpkIndex).*(10^s.timeorder)./(10^(-3)));
		SpikeNum(i,k) = length(cSpkIndex);
		
		for j = 1:SpikeNum(i,k)
			csi = find((s.spk{cC,cT}-cSpkTimes(j))>=halfwidth*(-1)  & (s.spk{cC,cT}-cSpkTimes(j))<=halfwidth); 
			ACH_mat(i,:,k) = ACH_mat(i,:,k) + hist(s.spk{cC,cT}(csi)-cSpkTimes(j),ACHTimeBins);
		end
	end
end