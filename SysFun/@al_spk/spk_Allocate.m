function s = spk_Allocate(s,N)

% creates a default object with non-empty fields
% s = spk_Allocate(s,N)
%
% N ... structure containing array size settings
%     N.Trials = 1000;
%     N.Spikes = 1000;
%     N.SpikeChans = 2;
%     N.SpikeWaveformSamples = 32;
%     N.AnalogSamples = 8192;
%     N.AnalogChans = 4;
%     N.EventLabel = 30;
%     N.Events = 5;
%     N.TrialCodeLabel = 50;

if nargin<2
    N.Trials = 1000;
    N.Spikes = 1000;
    N.SpikeChans = 2;
    N.SpikeWaveformSamples = 32;
    N.AnalogSamples = 8192;
    N.AnalogChans = 4;
    N.EventLabel = 30;
    N.Events = 5;
    N.TrialCodeLabel = 50;
end

%% header
s.version = 'TOALLOCATE';
s.name = 'TOALLOCATE';
s.tag  = 'TOALLOCATE';
s.comment  = 'TOALLOCATE';
s.subject = 'TOALLOCATE';
s.file = 'TOALLOCATE';
s.date = 'TOALLOCATE';
s.timeorder = NaN; 

%% spikes
s.unittype = cell(1,N.SpikeChans);
s.unittype(:) = {'TOALLOCATE'};

s.channel = cell(1,N.SpikeChans);
s.channel(:) = {'TOALLOCATE'};

s.currentchan = ones(1,N.SpikeChans).*NaN;

s.chancolor = ones(N.SpikeChans,3).*NaN;

s.spk = cell(N.SpikeChans,N.Trials);
s.spk(:) = {ones(N.Spikes,1)};

s.spkwave = cell(N.SpikeChans,N.Trials);
s.spkwave(:) = {ones(N.Spikes,N.SpikeWaveformSamples)};
s.spkwavealign = NaN;
s.spkwavefreq = NaN;

%% analog
s.analog = cell(1,N.AnalogChans);
s.analog(:) = {ones(N.Trials,N.AnalogSamples).*NaN};
s.analogunits = cell(1,N.AnalogChans);
s.analogunits(:) = {'TOALLOCATE'};
s.analogname = cell(1,N.AnalogChans);
s.analogname(:) = {'TOALLOCATE'};
s.analogtime = cell(1,N.AnalogChans);
s.analogtime(:) = {ones(N.AnalogSamples,1).*NaN};

s.analogfreq = ones(1,N.AnalogChans).*NaN;
s.analogalignbin = ones(1,N.AnalogChans).*NaN;
s.currentanalog = ones(1,N.AnalogChans).*NaN;

%% events
s.events = cell(N.EventLabel,N.Trials);
s.events(:) = {ones(N.Events,1).*NaN};
s.eventlabel = cell(1,N.EventLabel);
s.eventlabel(:) = {'TOALLOCATE'};
s.eventcolors = [];
s.eventmode = '';

%% align
s.align = ones(1,N.Trials).*NaN;
s.alignevent = '';

%% trialcode
s.trialcode = ones(N.TrialCodeLabel,N.Trials).*NaN;
s.trialcodelabel = cell(N.TrialCodeLabel,1);
s.trialcodelabel(:) = {'TOALLOCATE'};

s.currenttrials = [];

%% others
s.stimulus = [];
s.settings.alloc = N;
s.userdata = [];