function [M,STD,SE,tx,DATA] = spk_AnalogMean(s,ChanName,TimeWin,MeanMode)

% Calculate mean value of analog channel
% [M,STD,SE,DATA] = spk_AnalogMean(s,ChanName,TimeWin)
%
% MeanMode ... ['TRIALS'] average across trials, preserving bins
%              'BINS'     average across bins, preserving trials
%              otherwise  average across bins and trials, scalar

if nargin < 4
    MeanMode = 'TRIALS';
end

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
nBins = length(iBins);

%% get data
DATA = s.analog{iChan}(s.currenttrials,iBins);
switch MeanMode
    case 'BINS'
        [M,STD,SE,ERR] = CalcMean(DATA,2);
    case 'TRIALS'
        [M,STD,SE,ERR] = CalcMean(DATA,1);
    otherwise
        [M,STD,SE,ERR] = CalcMean(DATA,2);
        [M,STD,SE,ERR] = CalcMean(M,1);
end

function [M,STD,SE,ERR] = CalcMean(DATA,dim)
nData = size(DATA);
RepMatArray = ones(size(nData));
RepMatArray(dim) = nData(dim);
NaNs = isnan(DATA);
n = sum(~NaNs,dim);
DATA(NaNs) = 0;
M = sum(DATA,dim)./n;% mean
ERR = DATA - repmat(M,RepMatArray);
ERR(NaNs) = 0;
V = sum(ERR.*ERR,dim)./n;% variance
STD = sqrt(V);%standard deviation
SE = STD./sqrt(n);%standard error

