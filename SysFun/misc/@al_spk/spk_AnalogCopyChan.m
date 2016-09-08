function [s,iNewChan] = spk_AnalogCopyChan(s,ChanName,NewChanName)

% makes a copy of an analog channel within the same object
iChan = spk_findAnalog(s,ChanName);
n = spk_AnalogCheckChan(s);
iNewChan = n+1;

s.analogname{iNewChan} = NewChanName;

s.analog{iNewChan} = s.analog{iChan};
s.analogunits{iNewChan} = s.analogunits{iChan};
if ~isempty(s.analogtime)
    s.analogtime{iNewChan} = s.analogtime{iChan};
end
s.analogfreq(iNewChan) = s.analogfreq(iChan);
s.analogalignbin(iNewChan) = s.analogalignbin(iChan);
