function [AllNaN,NaNBins] = spk_AnalogIsNaN(s,TimeWindow,ChanName)

% detect NaN values in analog data


%% get the channel index#
if nargin==3 && ~isempty(ChanName)
    iChan = spk_FindAnalog(s,ChanName);
    s.currentanalog = iChan;
elseif isempty(s.currentanalog)
    s.currentanalog = 1:length(s.analog);
end
nCh = length(s.currentanalog);

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
nTr = length(s.currenttrials);

%% get window
tVec = spk_AnalogTimeVec(s);
if ~isempty(TimeWindow)
    BW = find(tVec>=TimeWindow(1)&tVec<=TimeWindow(2));
else
    BW = 1:length(tVec);
end

%% find peaks and valleys
for iCh = 1:nCh
    NaNBins{iCh} = isnan(s.analog{s.currentanalog(iCh)}(s.currenttrials,:));
    AllNaN{iCh} = all(NaNBins{iCh}(:,BW),2);
end

%% modify
if nCh==1
    NaNBins = NaNBins{1};
    AllNaN = AllNaN{1};
end
