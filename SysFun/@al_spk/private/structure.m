% this script provides the default structure for the neurons Object

s.version = [];
s.name = '';
s.tag  = '';
s.comment  = '';
s.subject = '';
s.file = '';
s.date = '';

s.unittype = '';% e.g. 'MUA' 'SUA'
s.channel = '';%changed to cell array of strings 3/02/05
s.currentchan = [];
s.chancolor = [];
s.spk = [];% spike data [1,trial number]; changed to [numChan,trial number] 3/02/05
s.timeorder = [];%power of ten of time values (e.g. msec. -3) 

s.analog = []; % analog data, different channels in rows
s.analogunits = '';
s.analogname = ''; % name of analog rows, e.g. 'eyeX' etc.
s.analogtime = []; %
s.analogfreq = []; % sample frequency of analog data
s.analogalignbin = [];
s.currentanalog = [];

s.events = []; % NOT TRUE anymore: 3D-Array for event bins rows:trials cols:eventspertrial planes:eventtype
               % [eventnumber,trialnumber]
s.eventlabel = '';% one string for every eventtype
s.eventcolors = [];
s.eventmode = '';% mode of event detection

s.align = [];% alignbin for every cell
s.alignevent = '';

s.trialcode = [];% numerical codes for different groups in columns
s.trialcodelabel = '';% character array

s.currenttrials = [];

s.stimulus = [];
s.settings = [];
s.userdata = [];
