function [Th,R,Xm,Ym] = spk_AnalogCircularMean(s,ChanName,TimeWin)

% Calculate mean value of analog channel with circular data
% [M,STD,SE,DATA] = spk_AnalogMean(s,ChanName,TimeWin)
% ChanName ... cell array {ThetName RName}

%% get the channel index
iChan = spk_FindAnalog(s,ChanName);
if length(iChan)==1
    iChan(2) = NaN;
end

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);

%% calc mean
[nTr,numSamples] = size(s.analog{iChan(1)});

%% get bins
s = spk_set(s,'currentanalog',iChan(1));
TimeData = spk_AnalogTimeVec(s);
if nargin>=3 && ~isempty(TimeWin) && length(TimeWin)==2
    iBins = find(TimeData>=TimeWin(1)&TimeData<=TimeWin(2));
elseif nargin>=3 && ~isempty(TimeWin) && length(TimeWin)==1
    [dummy,iBins] = min(abs(TimeData-TimeWin));
else
    iBins = 1:length(TimeData);
end

%% get data
ThetaDATA = s.analog{iChan(1)}(s.currenttrials,iBins);
if isnan(iChan(2))
    RDATA = ones(size(ThetaDATA));
else
    ThetaDATA = s.analog{iChan(2)}(s.currenttrials,iBins);
end
[X,Y] = pol2cart(ThetaDATA,RDATA);

NaNs = isnan(X);
n = sum(~NaNs,1);
X(NaNs) = 0;
Y(NaNs) = 0;

%% mean
Xm = sum(X,1)./n;
Ym = sum(Y,1)./n;

[Th,R] = cart2pol(Xm,Ym);
