function [currentchan,s] = spk_CheckCurrentAnalog(s,SetAllIfEmpty)

% returns current channel nr, if empty it sets all channels

if nargin<2
    SetAllIfEmpty = true;
end
if isempty(s.currentanalog) && SetAllIfEmpty
    s.currentanalog = [1:size(s.analog,2)];
end
currentchan =  s.currentanalog;   