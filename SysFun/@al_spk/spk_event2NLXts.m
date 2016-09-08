function s = spk_event2NLXts(s)

if isempty(s.timeorder)
    error('Time order in @al_spk object is not set!');
end


[SizeAl(1),SizeAl(2)] = size(s.align);
[nEventTypes,nTrials] = size(s.events);
if SizeAl(2)~=nTrials
    error;
end

for i = 1:nEventTypes
    for j = 1:nTrials
        s.events{i,j} = (s.events{i,j}+s.align(j)).*10^(s.timeorder-(-6));
    end
end