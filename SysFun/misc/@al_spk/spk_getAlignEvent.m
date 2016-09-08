function [i,e] = spk_getAlignEvent(s)

% gets the event with timestamp 0

n = cellfun('length',s.events);
[r,c] = size(s.events);
ZeroIndex = zeros(r,c);
for iLoop = 1:r*c
    ci = find(s.events{iLoop}==0);
    if length(ci)>1
        error('Found more than 1 zero timestamp per event per trial!');
    elseif ~isempty(ci)
        ZeroIndex(iLoop) = ci;
    end
end
i = any(ZeroIndex>0,2);
e = s.eventlabel(i);

