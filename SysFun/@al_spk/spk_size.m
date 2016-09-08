function N = spk_size(s,DataSwitch)

if nargin<2
    DataSwitch = {'TRIAL' 'EVENT' 'SPIKE' 'ANALOG'};
end

%% check trialcode
if any(strcmpi(DataSwitch,'TRIAL'))
    N.TrialCodeLabel = length(s.trialcodelabel);
    if isempty(s.trialcode)
        N.Trials = 0;
    else
        N.Trials = sum(~all(isnan(s.trialcode),1));
    end
end

%% check events
if any(strcmpi(DataSwitch,'EVENT'))
    [cEvNum,cTrNum] = size(s.events);
    N.EventLabel = cEvNum;
    N.Events = zeros(cEvNum,cTrNum);
    N.EventDataFound = false(1,cEvNum);
    for i=1:prod(cEvNum,cTrNum)
        N.Events(i) = sum(~isnan(s.events{i}));
    end
    N.EventDataFound = sum(N.Events,2)>0;
end

%% check spikes
if any(strcmpi(DataSwitch,'SPIKE'))
    [cChNum,cTrNum] = size(s.spk);
    N.SpikeChans = cChNum;
    N.SpikeDataFound = false(1,cChNum);
    N.Spikes = zeros(cChNum,cTrNum);
    N.SpikeWaveformSamples = zeros(cChNum,cTrNum);
    for i=1:prod(cChNum,cTrNum)
        N.Spikes(i) = sum(~isnan(s.spk{i}));
        N.SpikeWaveformSamples(i) = max(sum(isnan(s.spkwave{i}),2));
    end
    N.SpikeDataFound = sum(N.Spikes,2)>0;
end

%% check analog
if any(strcmpi(DataSwitch,'ANALOG'))
    cChNum = length(s.analog);
    N.AnalogChans = cChNum;
    N.AnalogDataFound = false(1,cChNum);
    for i=1:cChNum
        [cTrNum,N.AnalogSamples(i)] = size(s.analog{i});
        N.Analog = any(~isnan(s.analog{i}(:)));
        N.AnalogDataFound(i) = any(~isnan(s.analog{i}(:)));
    end
end



