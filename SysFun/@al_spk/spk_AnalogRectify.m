function s = spk_AnalogRectify(s,ChanName,NewChanName)

% rectifies (applies abs.m) analog channel.
% s = spk_AnalogRectify(s,ChanName,NewChanName)
% Input:
% ChanName ...... Name of an analog channel as in s.analog
% NewChanName ... optional

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

%% copy channel
if nargin==3
    [s,iChan] =  spk_AnalogCopyChan(s,ChanName,NewChanName);
end

%% loop channels
for iCh = 1:nChan
    s.analog{iChan(iCh)} = abs(s.analog{iChan(iCh)});
end

