function [c,lags] = spk_AnalogXCorr(s,SigChan,RefChan,TW)

% cross correlation between two channels

nTr = spk_TrialNum(s);

%% get the channel index
iSig = spk_findAnalog(s,SigChan);
iRef = spk_findAnalog(s,RefChan);

%% check for consistency of sampling
if s.analogfreq(iSig)~=s.analogfreq(iRef)
    error('Sample Frequency of signal is inconsistent!');
end

%% get current trials
if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end
nTr = length(s.currenttrials);

tSig = spk_AnalogTimeVec(s,SigChan);
bSig = find(tSig>=TW(1)&tSig<=TW(2));
tRef = spk_AnalogTimeVec(s,RefChan);
bRef = find(tRef>=TW(1)&tRef<=TW(2));

%% xcorr
for iTr = 1:nTr
    cTrNr = s.currenttrials(iTr);
    [c(iTr,:),lags(iTr,:)] = xcorr(s.analog{iSig}(cTrNr,bSig),s.analog{iRef}(cTrNr,bRef),'coeff');
end
lags = lags.*(1000/s.analogfreq(iSig));
