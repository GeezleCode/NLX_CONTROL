function [h,TrialSpread] = spk_AnalogLine(s,ChanName,TimeWin,TrialSpread,varargin)

% Plots line objects of current analog trials into current axes.
% [h,yOffset] = spk_AnalogLine(s,ChanName,TimeWin,TrialSpread,varargin)
% Input:
% TrialSpread ... adds cumulative values to every trial to spread trials
% ChanName ...... Name of an analog channel as in s.analog
% TimeWin ....... Time window
% varargin ...... line object properties

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

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);

%%
TrialSpread = [0:TrialSpread:(numCurrenttrials-1)*TrialSpread];
    
%% loop channels
for iCh = 1:nChan
    [nTr,numSamples] = size(s.analog{iChan(iCh)});
    
    s = spk_set(s,'currentanalog',iChan(iCh));
    TimeData = spk_AnalogTimeVec(s);
    if nargin>=3 && ~isempty(TimeWin)
        iBins = find(TimeData>=TimeWin(1)&TimeData<=TimeWin(2));
    else
        iBins = 1:length(TimeData);
    end

    TimeData = repmat(TimeData(iBins),[length(s.currenttrials) 1])';
    [nPltBins,nPltTr] = size(TimeData);
    
    yOffset = repmat(TrialSpread,[nPltBins 1]);
    
    h = line(TimeData,s.analog{iChan(iCh)}(s.currenttrials,iBins)' + yOffset,varargin{:});    
end

if length(TrialSpread)>1
    set(gca,'ylim',[TrialSpread(1)-TrialSpread(2) TrialSpread(end)+TrialSpread(2)]);
end
