function [CCH,BinCentres,SpikeNum,SP,CentreBinNr] = spk_SpikeCCH(s,Ev,EvOffset,CCHHalfWidth,BinWidth,WinExtendFlag)

% calculates the auto correlation histogram
% [CCH,BinCentres,SpikeNum,SP,CentreBinNr] = spk_SpikeCCH(s,Ev,EvOffset,CCHHalfWidth,BinWidth,WinExtendFlag)
%
% Ev .............. reference event
% EvOffset ........ defines a window around the reference event
% CCHHalfWidth .... half width of th ACH
% BinWidth ........ width of the CCH bins
% WinExtendFlag ... correlates spikes that are within CCHHalfWidth outside
%                   the time window
%
% CCH .......... cross correlation histogram [nBins x nTrials x nCh]
% BinCentres ... centres of time bins
% SpikeNum ..... number of spikes [nTr,nCh]
% SP ........... shift predictor [nBins x nTrials x nCh]
%                stimulus locked component, computed by shifting signal#2
%                by one stimulus period (trial).

CCH = [];
BinCentres = [];
SpikeNum = [];
SP = [];

if nargin<6
    WinExtendFlag = false;
    if nargin<5
        BinWidth = 1;
    end;end

%% create pairs of channels
[ChNr,s] = spk_CheckCurrentChannels(s,true);
nCh = length(ChNr);
if nCh==1
    ChNr = cat(1,ChNr,ChNr);
elseif nCh==2
    ChNr = ChNr(:);
elseif nCh>2
    error('Too many channels!');
end
nCh = size(ChNr,2);

%% get trial groups
[TrNr,s] = spk_CheckCurrentTrials(s,true);
nTr = length(TrNr);
TrNr = [1:nTr]';
TrNrShift = circshift([1:nTr]',[-1]);

%% create bins
BinEdges = BinWidth/2:BinWidth:CCHHalfWidth;% positive tail
BinEdges = cat(2,fliplr(BinEdges*(-1)),BinEdges);% add negative tail
BinLim = BinEdges([1 end]);
BinCentres = BinEdges(1:end-1)+BinWidth/2;
BinNum = length(BinCentres);
CentreBinNr = (BinNum+1)/2;

%% get spike times
[TW1,EvTimes] = spk_getEventWindow(s,Ev,EvOffset);
if WinExtendFlag
    TW2(:,1) = TW1(:,1) + BinLim(1);
    TW2(:,2) = TW1(:,2) + BinLim(2);
else
    TW2 = TW1;
end

%% loop
for iLoop = 1:[nCh*nTr]
    [iCh,iTr] = ind2sub([nCh nTr],iLoop);
    
    [CCH(:,iTr,iCh),SpikeNum(iTr,iCh)] = ComputeCCH( ...
        s.spk{ChNr(1,iCh),TrNr(iTr)}, ...
        s.spk{ChNr(2,iCh),TrNr(iTr)}, ...
        TW1(TrNr(iTr),:),TW2(TrNr(iTr),:),BinEdges);
    
    SP(:,iTr,iCh) = ComputeCCH( ...
        s.spk{ChNr(1,iCh),TrNr(iTr)}, ...
        s.spk{ChNr(2,iCh),TrNrShift(iTr)}, ...
        TW1(TrNr(iTr),:),TW2(TrNrShift(iTr),:),BinEdges);

end
    

function [F,n] = ComputeCCH(S1,S2,TW1,TW2,BinEdges)
i1 = S1(:,1)>=TW1(1) & S1(:,1)<=TW1(2);
n = sum(i1);
i2 = S2(:,1)>=TW2(1) & S2(:,1)<=TW2(2);
D = repmat(S2(i2)',sum(i1),1) - repmat(S1(i1),1,sum(i2));
F = histc(D(:),BinEdges);
F = F(1:end-1);
