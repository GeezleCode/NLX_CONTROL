function s = spk_AnalogSubstractMean(s,ChanName,TrialwiseFlag)

% substract the mean signal, offset removal.
% s = spk_AnalogSubstractMean(s,ChanName,TrialwiseFlag)
% Input:
% ChanName ...... Name of an analog channel as in s.analog

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

%% loop channels
for iCh = 1:nChan
    if TrialwiseFlag
        for iTr = 1:size(s.analog{iChan(iCh)},1)
            s.analog{iChan(iCh)}(iTr,:) = s.analog{iChan(iCh)}(iTr,:) - mean(s.analog{iChan(iCh)}(iTr,~isnan(s.analog{iChan(iCh)}(iTr,:))));
        end
    else
        s.analog{iChan(iCh)} = s.analog{iChan(iCh)} - mean(s.analog{iChan(iCh)}(~isnan(s.analog{iChan(iCh)})));
    end
end

