function [s,ChanNr] = spk_AddAnalogChan(s,Name,Data,SF,Time,Units,AlignBin)

% adds a new channel to analog data

currChanNr = spk_AnalogCheckChan(s);
ChanNr = currChanNr+1;

s.analog{ChanNr} = Data;
s.analogunits{ChanNr} = Units;
s.analogname{ChanNr} = Name;
s.analogtime{ChanNr} = Time;
s.analogfreq(ChanNr) = SF;
s.analogalignbin(ChanNr) = AlignBin;

