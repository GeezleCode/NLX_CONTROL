function s = spk_ClearData(s)

% delete all data analog and spike, but keeps everything else.
%
% s = spk_ClearData(s)
%

% spike data
s.unittype = {};
s.channel = {};
s.currentchan = [];
s.chancolor = [];
s.spk = {};
s.spkwave = {};
s.spkfreq = [];

% analog data
s.analog = {};
s.analogunits = {};
s.analogname = {};
s.analogtime = {}; 
s.analogfreq = [];
s.analogalignbin = [];
s.currentanalog = [];
