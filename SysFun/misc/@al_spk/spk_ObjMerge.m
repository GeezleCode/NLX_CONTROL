function s = spk_ObjMerge(s,s2)

% Merges two objects of same trial number. Trialnumber stays constant.
% s = spk_ObjMerge(s,s2)

nTr1 = spk_TrialNum(s);
nTr2 = spk_TrialNum(s2);
if nTr1~=nTr2
    error('Objects must have same number of trials!');
end

%% spike channel
if ~isempty(s2.spk)
    s.spk = cat(1,s.spk,s2.spk);
    s.channel = cat(2,s.channel,s2.channel);
    s.unittype = cat(2,s.unittype,s2.unittype);
end
if ~isempty(s.spkwave)&&~isempty(s2.spkwave)
    s.spkwave = cat(1,s.spkwave,s2.spkwave);
    s.spkfreq = cat(2,s.spkfreq,s2.spkfreq);
end

%% analog channel
if ~isempty(s2.analog)
    s.analog = cat(2,s.analog,s2.analog);
    s.analogname = cat(2,s.analogname,s2.analogname);
    s.analogfreq = cat(2,s.analogfreq,s2.analogfreq);
    s.analogalignbin = cat(2,s.analogalignbin,s2.analogalignbin);
    s.analogunits = cat(2,s.analogunits,s2.analogunits);
    s.analogtime = cat(2,s.analogtime,s2.analogtime);
end

%% events
s.events = cat(1,s.events,s2.events);
s.eventlabel = cat(1,s.eventlabel,s2.eventlabel);

%% trialcode
s.trialcode = cat(1,s.trialcode,s2.trialcode);
s.trialcodelabel = cat(1,s.trialcodelabel,s2.trialcodelabel);

%% misc
s.stimulus = cat(1,s.stimulus,s2.stimulus);

if isstruct(s.settings) && isstruct(s2.settings)
    fn2 = fieldnames(s2.settings);
    for i=1:length(fn2)
        s.settings.(fn2{i}) = s2.settings.(fn2{i});
    end
end
