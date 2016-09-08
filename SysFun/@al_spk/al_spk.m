function s = al_spk(x)

% Constructor for the @al_spk class
%
% function s = al_spk(x)
% s	... @al_spk object
% x	... [] or omitted -> create default object
%       struct        -> convert to object
%       al_spk-obj    -> copy object
%

%% Read the default data structure.
% general information
s.version = [];
s.name = '';
s.tag  = '';
s.comment  = '';
s.subject = '';
s.file = '';
s.date = '';

% spike data
s.unittype = '';% e.g. 'MUA' 'SUA'
s.channel = '';%changed to cell array of strings 3/02/05
s.currentchan = [];
s.chancolor = [];
s.spk = {};% spike data [1,trial number]; changed to [numChan,trial number] 3/02/05
s.timeorder = [];%power of ten of time values (e.g. msec. -3) 
s.spkwave = {};
s.spkwavealign = [];
s.spkwavefreq = [];

% analog data
s.analog = []; % analog data, different channels in rows
s.analogunits = '';
s.analogname = ''; % name of analog rows, e.g. 'eyeX' etc.
s.analogtime = []; %
s.analogfreq = []; % sample frequency of analog data
s.analogalignbin = [];
s.currentanalog = [];

% event data
s.events = []; % NOT TRUE anymore: 3D-Array for event bins rows:trials cols:eventspertrial planes:eventtype
               % [eventnumber,trialnumber]
s.eventlabel = '';% one string for every eventtype
s.eventcolors = [];
s.eventmode = '';% mode of event detection

% temporal alignment of trial time data
s.align = [];% align time for every cell
s.alignevent = '';

% trial properties
s.trialcode = [];% numerical codes for different groups in columns
s.trialcodelabel = '';% character array
s.currenttrials = [];

% miscellaneous
s.stimulus = [];
s.settings = [];
s.userdata = [];


%% react to different types of INPUT
if nargin == 0 || isempty(x)
   %% CREATE an empty object
   s = class(s,'al_spk');
   
elseif isa(x,'struct')
   %% CONVERT structure to an object
   xFields = fieldnames(x);
   sFields = fieldnames(s);
   nrFields = length(sFields);
   for fieldNr = 1:nrFields
	   indexInx = strmatch(sFields{fieldNr},xFields,'exact');
	   if ~isempty(indexInx)
           s.(sFields{fieldNr}) = x.(xFields{indexInx});
		   %s = setfield(s,sFields{fieldNr},getfield(x,xFields{indexInx}));
	   end   
   end
   s = class(s,'al_spk');
   
elseif isa(x,'al_spk')
   %% COPY the object
   s = x;	
   
else
   s = class(s,'al_spk');
   error(s,'No such constructor')
   
end


