function s = spk_AnalogEuclidDist(s,SigChans,RefChans,ThChanName,RChanName)

% calculates the euclidean distance from signal SigChans to signal RefChans
% s = spk_AnalogEuclidDist(s,SigChans,RefChans,ThChanName,RChanName)
% SigChans,RefChans .... cell array of strings with X and Y channel names

%% get the channel index
iSigX = spk_findAnalog(s,SigChans{1});
iSigY = spk_findAnalog(s,SigChans{2});
iRefX = spk_findAnalog(s,RefChans{1});
iRefY = spk_findAnalog(s,RefChans{2});

%% copy channel data
[s,iTh] = spk_AnalogCopyChan(s,SigChans{1},ThChanName);
[s,iR] = spk_AnalogCopyChan(s,SigChans{1},RChanName);

%% check for consistency of sampling
if s.analogfreq(iSigX)~=s.analogfreq(iSigY) || s.analogfreq(iRefX)~=s.analogfreq(iRefY)
    error('Sample Frequency of signal is inconsistent!');
end

tSigX = spk_AnalogTimeVec(s,SigChans{1});
% tSigY = spk_AnalogTimeVec(s,SigChans{2});
nBin = length(tSigX);
tRefX = spk_AnalogTimeVec(s,RefChans{1});
% tRefY = spk_AnalogTimeVec(s,RefChans{2});

%% match time bins of signals
i = ones(1,nBin);
for iBin = 1:nBin
    [dummy,i(iBin)] = min(abs(tSigX(iBin)-tRefX));
end

%% cart 2 pol
[s.analog{iTh},s.analog{iR}] = cart2pol(s.analog{iRefX}(:,i)-s.analog{iSigX},s.analog{iRefY}(:,i)-s.analog{iSigY});
