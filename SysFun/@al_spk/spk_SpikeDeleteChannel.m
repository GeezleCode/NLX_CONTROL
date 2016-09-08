function s = spk_SpikeDeleteChannel(s,DelChan)

% delete spike channels
%
% s = spk_SpikeDeleteChannel(s,DelChan)
%
% DelChan ... cell array of channel names
%             'ALL' deletes all channels
%             index of spike channels
%             when omitted or empty, all except s.currentchan are deleted

if nargin<2
    DelChan = [];
end
    
nCh = spk_SpikeChanNum(s);

if isempty(DelChan)
    DelChanIndex = setdiff(1:nCh,s.currentchan);
elseif iscell(DelChan)
	DelChanIndex = spk_findSpikeChan(s,DelChan);
elseif ischar(DelChan)
    if strcmpi(DelChan,'ALL')
        DelChanIndex = 1:nCh;
    else
        DelChanIndex = spk_findSpikeChan(s,DelChan);
    end
elseif isnumeric(DelChan)
	DelChanIndex = DelChan;
end

s.unittype(DelChanIndex) = []; 
s.channel(DelChanIndex) = [];
s.spk(DelChanIndex,:) = [];

if ~isempty(s.spkwave)
    s.spkwave(DelChanIndex,:) = [];
end
if ~isempty(s.spkfreq)
    s.spkwave(DelChanIndex) = [];
end

