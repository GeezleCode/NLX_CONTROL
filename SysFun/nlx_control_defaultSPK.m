function s = nlx_control_defaultSPK(ChanName,AnalogChanName)

% Creates the default data structure to store event and spike data.
% Input:
% ChanName ... ChannelNr in rows. Electrode Name in 1st column. ClusterNr in 2nd column.
% Output:
% SPK ... structure containing events, spike timestamps etc.

global NLX_CONTROL_SETTINGS;

TrialCodeLabel = {'TrialID' 'CortexBlock' 'CortexCondition' 'CortexPresentationNr' 'StimulusCode'};

N.Trials = 1000;
N.Spikes = 1000;
N.SpikeChans = size(ChanName,1);;
N.SpikeWaveformSamples = 32;
N.AnalogSamples = 8192;
N.AnalogChans = length(AnalogChanName);
N.EventLabel = size(NLX_CONTROL_SETTINGS.EventName,1);
N.Events = 5;
N.TrialCodeLabel = length(TrialCodeLabel);

s = spk_Allocate(al_spk,N);


s = spk_set(s, ...
    'channel',ChanName, ...
    'chancolor',NLX_CONTROL_SETTINGS.SpikeChanColor(1:N.SpikeChans,:), ...    
    'eventlabel',NLX_CONTROL_SETTINGS.EventName, ...
    'date',datestr(now,30), ...
    'timeorder',-3, ...
    'stimulus',cell(1,N.Trials), ...
    'analogname',AnalogChanName);

