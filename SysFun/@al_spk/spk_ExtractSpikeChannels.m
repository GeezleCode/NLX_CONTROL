function s = spk_ExtractSpikeChannels(s,ExtrChan)

[numChan,numTrials] = size(s.spk);
if iscell(ExtrChan)
	ExtrChanIndex = spk_findchannel(s,ExtrChan);
elseif isnumeric(ExtrChan)
	ExtrChanIndex = ExtrChan;
end

s.channel = s.channel(ExtrChanIndex);
s.spk = s.spk(ExtrChanIndex,:);