function s = spk_AnalogDiff(s,ChanName,n,NewChanName)

% Differentiates analog channel using diff.m. Only works on all trials.
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
    iChan = spk_FindAnalog(s,ChanName);
end
nChan = length(iChan);

%% copy channel
if nargin==4
    [s,iChan] =  spk_AnalogCopyChan(s,ChanName,NewChanName);
end

%% loop channels
for iCh = 1:nChan
    s.analog{iChan(iCh)} = diff(s.analog{iChan(iCh)},n,2);
    s.analog{iChan(iCh)} = s.analog{iChan(iCh)}./(1/s.analogfreq(iChan(iCh)));
    s.analogalignbin(iChan(iCh)) = s.analogalignbin(iChan(iCh))-floor(n/2);
    if ~isempty(s.analogtime)
        s.analogtime{iChan(iCh)} = s.analogtime{iChan(iCh)}(1:end-n)+diff(s.analogtime{iChan(iCh)}(1:end-n+1),1,2)*n;
    end
end

