function s = spk_DeleteSpikeChannels(s,DelChan)

[numChan,numTrials] = size(s.spk);
if iscell(DelChan)
	DelChanIndex = spk_findchannel(s,DelChan);
elseif isnumeric(DelChan)
	DelChanIndex = DelChan;
end

s.unittype(DelChanIndex) = []; 
s.channel(DelChanIndex) = [];
s.spk(DelChanIndex,:) = [];