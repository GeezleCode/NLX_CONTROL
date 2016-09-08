function s = spk_ExtractSpikeChan(s,ExtrChan)

% extracts an object with the selected channels
% s = spk_ExtractSpikeChan(s,ExtrChan)
% ExtrChan ... Either the channel number (numeric) or channel name (char)

[numChan,numTrials] = size(s.spk);
if iscell(ExtrChan)
	ExtrChanIndex = spk_findSpikeChan(s,ExtrChan);
elseif isnumeric(ExtrChan)
	ExtrChanIndex = ExtrChan;
end

s.unittype = s.unittype(ExtrChanIndex);
s.channel = s.channel(ExtrChanIndex);
s.spk = s.spk(ExtrChanIndex,:);