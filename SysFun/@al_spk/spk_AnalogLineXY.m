function [h,s] = spk_AnalogLineXY(s,XChanName,YChanName,TimeWin,varargin)

% Plots two analog channels (X vs Y) of current trials into current axes.
% [h,s] = spk_AnalogLine(s,XChanName,YChanName,TimeWin,varargin)
% Input:
% XChanName,YChanName ...... Name of an analog channel as in s.analog
% TimeWin ....... Time window
% varargin ...... line object properties

%% get the channel index
iChanX = spk_FindAnalog(s,XChanName);
iChanY = spk_FindAnalog(s,YChanName);
[nTr,numSamples] = size(s.analog{iChanX});

%% get time data
s.currentanalog = [iChanX iChanY];
TimeData = spk_AnalogTimeVec(s);
TimeData = TimeData{1};

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);

%% loop channels
if nargin<3 || isempty(TimeWin)
    iBins = 1:length(TimeData);
elseif length(TimeWin)==2
    iBins = find(TimeData>=TimeWin(1)&TimeData<=TimeWin(2));
elseif length(TimeWin)==1
    [timeerror,iBins] = min(abs(TimeData-TimeWin(1)));
else
    
end

TimeData = repmat(TimeData(iBins),[length(s.currenttrials) 1])';
[nPltTr,nPltBins] = size(TimeData);


h = line(s.analog{iChanX}(s.currenttrials,iBins)',s.analog{iChanY}(s.currenttrials,iBins)',varargin{:});

