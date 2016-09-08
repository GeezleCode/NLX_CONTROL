function s = spk_AnalogAlign(s,ChanName,AlignTime)

% Aligns values of analog channel to value at a given point in time.
% s = spk_AnalogAlign(s,ChanName,AlignTime)
% Input:
% ChanName ...... Name of an analog channel as in s.analog
% AlignTime ....... 

%% get the channel index
if nargin<2 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_findAnalog(s,ChanName);
end
nChan = length(iChan);

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);

    
%% loop channels
for iCh = 1:nChan
    [nTr,numSamples] = size(s.analog{iChan(iCh)});
    
    s = spk_set(s,'currentanalog',iChan(iCh));
    TimeData = spk_AnalogTimeVec(s);
    [dummy,iBin] = min(abs(TimeData-AlignTime));
    
    s.analog{iChan(iCh)}(s.currenttrials,:) = s.analog{iChan(iCh)}(s.currenttrials,:) - repmat(s.analog{iChan(iCh)}(s.currenttrials,iBin),[1,numSamples]);

end

