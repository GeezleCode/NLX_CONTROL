function s = spk_AnalogOffset(s,Offset,ChanName)

% Adds an offset to analog channel.
% Acts on selected trials, if currentrials is not empty.
% s = spk_AnalogMultiply(s,Factor,Units,ChanName)
%
% INPUT:
% Offset
% ChanName

%% get the channel index
if nargin<3 || isempty(ChanName)
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
    
    if isempty(s.currenttrials)
        s.analog{iChan(iCh)} = s.analog{iChan(iCh)} + Offset;
    else
        s.analog{iChan(iCh)}(s.currenttrials,:) = s.analog{iChan(iCh)}(s.currenttrials,:) + Offset;
    end
    
end