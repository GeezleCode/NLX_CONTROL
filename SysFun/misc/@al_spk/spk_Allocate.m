function s = spk_Allocate(s,NumTrials,NumSpikes,NumSpikeChans,NumAnalogSamples,NumAnalogChans,NumEventLabel,NumEvents,NumTrialCodeLabel)

% creates a default object with non-empty fields
% s = spk_Allocate(s,NumTrials,NumSpikes,NumSpikeChans,NumAnalogSamples,NumAnalogChans,NumEventLabel,NumEvents,NumTrialCodeLabel)

s.version = 'TOALLOCATE';
s.name = 'TOALLOCATE';
s.tag  = 'TOALLOCATE';
s.comment  = 'TOALLOCATE';
s.subject = 'TOALLOCATE';
s.file = 'TOALLOCATE';
s.date = 'TOALLOCATE';

s.unittype = cell(NumSpikeChans,NumTrials);
s.unittype(:) = {'TOALLOCATE'};

s.channel = cell(1,NumSpikeChans);
s.channel(:) = {'TOALLOCATE'};

s.currentchan = ones(1,NumSpikeChans).*NaN;

s.chancolor = ones(NumSpikeChans,3).*NaN;

s.spk = cell(NumSpikeChans,NumTrials);
s.spk(:) = {ones(NumSpikes,1)};

s.timeorder = NaN; 

s.analog = cell(1,NumAnalogChans);
s.analog(:) = {ones(NumTrials,NumAnalogSamples).*NaN};
s.analogunits = cell(1,NumAnalogChans);
s.analogunits(:) = {'TOALLOCATE'};
s.analogname = cell(1,NumAnalogChans);
s.analogname(:) = {'TOALLOCATE'};
s.analogtime = cell(1,NumAnalogChans);
s.analogtime(:) = {ones(NumAnalogSamples,1).*NaN};

s.analogfreq = ones(1,NumAnalogChans).*NaN;
s.analogalignbin = ones(1,NumAnalogChans).*NaN;
s.currentanalog = ones(1,NumAnalogChans).*NaN;

s.events = cell(NumEventLabel,NumTrials);
s.events(:) = {ones(NumEvents,1).*NaN};
s.eventlabel = cell(1,NumEventLabel);
s.eventlabel(:) = {'TOALLOCATE'};
s.eventcolors = [];
s.eventmode = '';

s.align = ones(1,NumTrials).*NaN;
s.alignevent = '';

s.trialcode = ones(NumTrialCodeLabel,NumTrials).*NaN;
s.trialcodelabel = cell(NumTrialCodeLabel,1);
s.trialcodelabel(:) = {'TOALLOCATE'};

s.currenttrials = [];

s.stimulus = [];
s.settings = [];
s.userdata = [];