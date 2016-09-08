function [STA,BinCentres,SpikeNum,SP,CentreBinNr] = spk_SpikeTA(s,Ev,EvOffset,STAHalfWidth,WinExtendFlag)

% spike triggered average
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

STA = [];
BinCentres = [];
SpikeNum = [];
SP = [];

if nargin<6
    WinExtendFlag = false;
    if nargin<5
        BinWidth = 1;
    end;end

%% create pairs of channels
ChNr = [s.currentchan;s.currentanalog];
nCh = size(ChNr,2);

%% get trial groups
[TrNr,s] = spk_CheckCurrentTrials(s,true);
nTr = length(TrNr);
TrNr = [1:nTr]';
TrNrShift = circshift([1:nTr]',[-1]);

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
    
    t = spk_AnalogTimeVec(s,ChNr(2,iCh));
    t = t(:)';% make sure t is horizontal
    Fs = spk_getAnalogFs(s,ChNr(2,iCh));
    BinCentres(iCh,:) = [fliplr(1000/Fs:1000/Fs:STAHalfWidth).*(-1) 0 [1000/Fs:1000/Fs:STAHalfWidth]];
    BinIndex = BinCentres./(1000/Fs);
    CentreBinNr = size(BinCentres(iCh,:),2)/2+1;
    
    [STA(iTr,:,iCh),SpikeNum(iTr,iCh)] = ComputeSTA( ...
        s.spk{ChNr(1,iCh),TrNr(iTr)}, ...
        s.analog{ChNr(2,iCh)}(TrNr(iTr),:), ...
        TW1(TrNr(iTr),:),t,BinIndex);
    
    SP(iTr,:,iCh) = ComputeSTA( ...
        s.spk{ChNr(1,iCh),TrNr(iTr)}, ...
        s.analog{ChNr(2,iCh)}(TrNrShift(iTr),:), ...
        TW1(TrNr(iTr),:),t,BinIndex);

end

function [F,n1] = ComputeSTA(S1,S2,TW1,t,BinIndex)
n2 = length(t);
nB = length(BinIndex);
i1 = S1(:,1)>=TW1(1) & S1(:,1)<=TW1(2);
n1 = sum(i1);
D = repmat(t,n1,1) - repmat(S1(i1),1,n2);
[minBinDiff,ZeroBinIndex] = min(abs(D),[],2);
BinIndex = repmat(BinIndex,n1,1) + repmat(ZeroBinIndex,1,nB);
iS2 = sub2ind([1,n2],ones(n1,nB),BinIndex);
F = sum(S2(iS2),1)./n1;

