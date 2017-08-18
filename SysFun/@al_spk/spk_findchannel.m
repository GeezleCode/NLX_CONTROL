function ChanIndex = spk_findchannel(s,ChanName)

% get the indices of channels as appearing in s.channel
% ChanIndex = spk_findchannel(s,ChanName)
%
% ChanName ... cell array of channel names

for i = 1:length(ChanName)
    CurrIndex = strmatch(ChanName{i},s.channel,'exact');
    if isempty(CurrIndex)
        ChanIndex(i) = NaN;
    else
        ChanIndex(i) = CurrIndex;
    end
end
    