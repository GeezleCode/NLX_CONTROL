function [currentchan,s] = spk_CheckCurrentChannels(s,SetAllIfEmpty)

% returns current channel nr, if empty it sets all channels

if nargin<2
    SetAllIfEmpty = true;
end

if isempty(s.currentchan) && SetAllIfEmpty
    NumChan = spk_SpikeChanNum(s);
    s.currentchan = [1:size(s.spk,1)];
    
end
currentchan =  s.currentchan;   