function [M,STD,SE,tx,DATA] = spk_AnalogMean(s,ChanName,TimeWin)

% Calculate mean value of analog channel
% [M,STD,SE,DATA] = spk_AnalogMean(s,ChanName,TimeWin)

%% get the channel index
if nargin<2 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_FindAnalog(s,ChanName);
end
nChan = length(iChan);
if nChan>1;error('Only 1 channel allowed!');end

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);

%% calc mean
[nTr,numSamples] = size(s.analog{iChan});

%% get bins
s = spk_set(s,'currentanalog',iChan);
TimeData = spk_AnalogTimeVec(s);
if nargin>=3 && ~isempty(TimeWin) && length(TimeWin)==2
    iBins = find(TimeData>=TimeWin(1)&TimeData<=TimeWin(2));
elseif nargin>=3 && ~isempty(TimeWin) && length(TimeWin)==1
    [dummy,iBins] = min(abs(TimeData-TimeWin));
else
    iBins = 1:length(TimeData);
end

tx = TimeData(iBins);

%% get data
DATA = s.analog{iChan}(s.currenttrials,iBins);
NaNs = isnan(DATA);
n = sum(~NaNs,1);
DATA(NaNs) = 0;

%% mean
M = sum(DATA,1)./n;

%% variance, standard deviation, standard error
ERR = DATA - repmat(M,[numCurrenttrials,1]);
ERR(NaNs) = 0;
V = sum(ERR.*ERR,1)./n;
STD = sqrt(V);
SE = STD./sqrt(n);

