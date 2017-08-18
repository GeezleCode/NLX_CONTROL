function out = spk_CheckCurrentChannels(s,SetAllIfEmpty)
if isempty(s.currentchan) & SetAllIfEmpty~=0
    warning('''currentchan'' field is not set. Process all channels!');
    s.currentchan = [1:size(s.spk,1)];
elseif isempty(s.currentchan) & SetAllIfEmpty==0
    error('''currentchan'' field is not set!');
end
out =  s.currentchan;   