function [r,n,dt] = spk_SpikeWinrate(s,win)

% calculate rate of the current trials
% take all trials if not trials selected
%
% function [r,n,dt] = spk_winrate(s,win)
%
% INPUT
% win[n,[low hi],ith win] ........... two column vector or matrix, rows must be 1 or
%                                     number of selected trials
% trialNr ........................... trial numbers 
%
% OUTPUT
% r [chan,trial,ith win] ......... rates for every trial 
% n [chan,trial,ith win] ......... number of spikes in every trial
% dt [trial,ith win] ............. width of time window

[numChans,numTrials] = size(s.spk);
numCurrChans = length(spk_CheckCurrentChannels(s,0));
[dummy,s] = spk_CheckCurrentTrials(s,1);
numCurrTrials = length(dummy);

%______________________________________________________
% calculation
r = zeros(numCurrChans,numCurrTrials).*NaN;
n = zeros(numCurrChans,numCurrTrials).*NaN;
dt  = zeros(1,numCurrTrials).*NaN;

if numCurrTrials==0;
	return;
end

%______________________________________________________
% check the time windows
if size(win,1)==1
    win = repmat(win,numTrials,1);
elseif size(win,1)~=numCurrTrials
    error('spk_winrate: window matrix must have as many rows as number of selected trials !');
end

[numTrWin,numWinBorders,numWin] = size(win);

for i = 1:numCurrTrials
     j = s.currenttrials(i);
     for m = 1:numWin
        dt(i,m) = abs(diff(win(i,:,m)));
        for k = 1: numCurrChans
            n(k,i,m) = sum(s.spk{s.currentchan(k),j}>=win(i,1,m) & s.spk{s.currentchan(k),j}<=win(i,2,m));
            r(k,i,m) = (n(k,i,m)/dt(i,m)).*(10^(s.timeorder*(-1)));
        end
    end
end
