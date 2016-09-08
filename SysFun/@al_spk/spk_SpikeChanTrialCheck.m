function [isOKTrial,SpkCnt] = spk_SpikeChanTrialCheck(s,ChanName,MethodName,MethodPar,BlockedFlag)

% Check each trial if activity of channel matches criterion
% [isOKTrial,SpkCnt] = spk_SpikeChanTrialCheck(s,ChanName,MethodName,MethodPar,BlockedFlag)
%
% ChanName ..... 'char' of [num], if empty "currentchan"-field is used
% MethodName ... so far it's only 'SPIKECOUNT'
% MethodPar .... 'SPIKECOUNT' - minimum spike count found in trial
% BlockedFlag .. true/false, returns OKtrials as a block,
%                i.e. only trials in the beginning and end are indicated as not ok

%% check trial number and channels
nTr = spk_TrialNum(s);

if isempty(ChanName)
    [ChNr,s] = spk_CheckCurrentChannels(s,true);
elseif ischar(ChanName)
    ChNr = spk_findSpikeChan(s,ChanName);
elseif isnumeric(ChanName)
    ChNr = ChanName;
elseif iscell(ChanName)
    ChNr = spk_findSpikeChan(s,ChanName);
end

nCh = length(ChNr);
isOKTrial = false(nCh,nTr);

%% get "bad" trials
switch MethodName
    case 'SPIKECOUNT'
        SpkCnt = cellfun('length',s.spk);
        if nargin<4
            minSpkCnt = 1;
        else
            minSpkCnt = MethodPar;
        end
        
        isOKTrial = SpkCnt(ChNr,:)>=minSpkCnt;
        
        if nargout==0
            figure
            plot(SpkCnt');
            legend(s.channel{:});
        end

end

%% make sure OK trials are blocked
if nargin==5 && BlockedFlag
    i1 = find(isOKTrial,1,'first');
    i2 = find(isOKTrial,1,'last');
    isOKTrial(i1:i2) = true;
end

