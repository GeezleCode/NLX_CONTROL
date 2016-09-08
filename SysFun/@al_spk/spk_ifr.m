function [IFRmean,IFRtrial,h] = spk_ifr(s,TimeWin,varargin)

% calculates instantaneaous spike rate for the current trials
% function [mSecF,mSec,h] = spk_instant(s,rateflag,plottype,varargin)
%
% ratescale

numCurrChan = length(spk_CheckCurrentChannels(s,0));
numCurrTr = length(spk_CheckCurrentTrials(s,0));
numSpikes = cellfun('length',s.spk);

IFRtrial = s.spk(s.currentchan,s.currenttrials);

t = TimeWin(1):TimeWin(2);

for cc = 1:numCurrChan
    j = s.currentchan(cc);
%     TotalNumSpk = sum(numSpikes);
%     sTimes = zeros(1,TotalNumSpk);
%     IFR = zeros(1,TotalNumSpk);
    for ct = 1:numCurrTr
        i = s.currenttrials(ct);
        dt = 1./(diff(s.spk{j,i})*10^s.timeorder);
		if ~isempty(dt)
        	IFRtrial{cc,ct} = [dt dt(end)];
		else
			IFRtrial{cc,ct} = [];
		end
	end

% 	IFRmean{cc} = [cat(2,s.spk{j,s.currenttrials})' cat(2,IFRtrial{cc,:})'];
% 	[IFRmean{cc}(:,1),sorti] = sort(IFRmean{cc}(:,1));
% 	IFRmean{cc}(:,2) = IFRmean{cc}(sorti,2);
% 	
% 	for i=1:size(IFRmean{cc},1)
% 		cTrialIFR = zeros(1,numCurrTr);
% 		for ct = 1:numCurrTr
% 			earlySpk = find(s.spk{j,s.currenttrials(ct)}<=IFRmean{cc}(i,1));
% 			if isempty(earlySpk)
% 				cTrialIFR(ct) = IFRmean{cc}(i,2);
% 			else
% 				cTrialIFR(ct) = IFRtrial{cc,ct}(earlySpk(end));
% 			end
% 		end
% 		IFRmean{cc}(i,2) = sum(cTrialIFR)/numCurrTr;
% 	end

	IFRmean{cc} = [t' zeros(length(t),1)];
	for i=1:length(t)
		cTrialIFR = zeros(1,numCurrTr);
		for ct = 1:numCurrTr
			earlySpk = find(s.spk{j,s.currenttrials(ct)}<=IFRmean{cc}(i,1));
			if isempty(earlySpk)
				cTrialIFR(ct) = IFRmean{cc}(i,2);
			else
				cTrialIFR(ct) = IFRtrial{cc,ct}(earlySpk(end));
			end
		end
		IFRmean{cc}(i,2) = sum(cTrialIFR)/numCurrTr;
	end

end

% plot histogram
h = [];
if nargin<2;return;end          
for cc = 1:numCurrChan
	h = line(IFRmean{cc}(:,1),IFRmean{cc}(:,2),varargin{:});
end
