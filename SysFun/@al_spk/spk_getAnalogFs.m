function Fs = spk_getAnalogFs(s,ChanName)
% get sample frequency of analog channel

if nargin<2
    iCh = s.currentanalog;
elseif ischar(ChanName)||iscell(ChanName)
    iCh = spk_findAnalog(s,ChanName);
elseif isnumeric(ChanName)
    iCh = ChanName;
end
Fs = s.analogfreq(iCh);
