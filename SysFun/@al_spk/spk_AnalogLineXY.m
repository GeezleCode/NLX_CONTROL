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


%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);


%% loop channels
[nTr,numSamples] = size(s.analog{iChanX});

s = spk_set(s,'currentanalog',iChanX);
TimeData = spk_AnalogTimeVec(s);
if nargin>=3 && ~isempty(TimeWin)
    iBins = find(TimeData>=TimeWin(1)&TimeData<=TimeWin(2));
else
    iBins = 1:length(TimeData);
end

TimeData = repmat(TimeData(iBins),[length(s.currenttrials) 1])';
[nPltTr,nPltBins] = size(TimeData);


h = line(s.analog{iChanX}(s.currenttrials,iBins)',s.analog{iChanY}(s.currenttrials,iBins)',varargin{:});

