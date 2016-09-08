function s = spk_SpikeRandomTrain(s,TimeWin,Refract)

% shuffles spike trains in selected channels and trials
% SPIKE times will be rounded to ms (integer spike times) !!!
% uses the unifrnd.m to draw random spike times
%
% s = spk_SpikeRandomTrain(s,TimeWin,Dist,Refract)

ChInd =  s.currentchan;
nCh = length(ChInd);
TrInd = s.currenttrials;
nTr = length(TrInd);

if size(TimeWin,1)==1 & nTr~=1
	TimeWin = repmat(TimeWin,[nTr 1]);
end

for iCh = 1:nCh
	for iTr = 1:nTr
        TrNr = s.currenttrials(iTr);
		s.spk{iCh,TrNr} = unique(round(s.spk{iCh,TrNr}));% round to ms and remove double spikes
		cSpkIndex = s.spk{iCh,TrNr}>=TimeWin(iTr,1) & s.spk{iCh,TrNr}<=TimeWin(iTr,2);
		nSpk = sum(cSpkIndex);
		WinWidth = TimeWin(iTr,2)-TimeWin(iTr,1);
		ImpPerSec = nSpk/(WinWidth/1000);
		currTrain = ones(1,nSpk).*NaN;
		
		
		if ImpPerSec<=500 & nSpk>=2
			SpkPool = TimeWin(iTr,1):1:TimeWin(iTr,2);
			PoolIndex = find(~isnan(SpkPool));
			nSpkPool = length(PoolIndex);
			for iSpk = 1:nSpk
				pInd = unidrnd(nSpkPool,1,1);
				currTrain(iSpk) = SpkPool(PoolIndex(pInd));
				SpkPool(PoolIndex(pInd):PoolIndex(pInd)+Refract) = NaN;
				PoolIndex = find(~isnan(SpkPool));
				nSpkPool = length(PoolIndex);
				if all(isnan(SpkPool)) & any(isnan(currTrain))
					currTrain = ones(1,nSpk).*NaN;
					warning('Spike train simulation failure.');
				end
			end
		end
			
% 		if ImpPerSec<=500 & nSpk>=2
% 			currTrainDiff = diff(currTrain);
% 			for iSpk = 1:nSpk
% 				if iSpk==1
% 					currTrain([1 2]) = round(TimeWin(iTr,1) + unifrnd(0,1).*WinWidth);
%                     currTrainDiff = diff(currTrain);
% 				else
% 					while isnan(currTrainDiff(iSpk-1)) || currTrainDiff(iSpk-1)<=Refract
% 						currTrain(iSpk) = round(TimeWin(iTr,1) + unifrnd(0,1).*WinWidth);
% 						currTrain(1:iSpk) = sort(currTrain(1:iSpk));
% 						currTrainDiff = diff(currTrain);
% 					end
% 				end
% 			end
% 		end
		
		s.spk{iCh,TrNr}(cSpkIndex) = currTrain;
	end
end
	