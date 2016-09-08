function s = spk_AnalogGradient(s,ChanName,n,NewChanName)

% Differentiates analog channel using gradient.m. Only works on all trials.
% s = spk_AnalogDiff(s,ChanName,n)
% Input:
% ChanName ...... Name of an analog channel as in s.analog
% n ............. diff order

%% get the channel index
if nargin<2 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_findAnalog(s,ChanName);
end
nChan = length(iChan);

%% copy channel
if nargin==4
    [s,iChan] =  spk_AnalogCopyChan(s,ChanName,NewChanName);
end

%% loop channels
for iCh = 1:nChan
    for i=1:n
        s.analog{iChan(iCh)} = gradient(s.analog{iChan(iCh)},(1/s.analogfreq(iChan(iCh))));
    end
end

