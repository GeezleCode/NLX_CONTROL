function ChanIndex = spk_findSpikeChan(s,ChanName)

% get the indices of channels as appearing in s.channel
% ChanIndex = spk_findSpikeChan(s,ChanName)
%
% ChanName ... cell array of channel names

if isempty(ChanName)
    ChanIndex = [];
elseif ischar(ChanName)
    ChanIndex = find(strcmp(ChanName,s.channel));
elseif iscell(ChanName)
    for i = 1:length(ChanName)
%         CurrIndex = find(strcmpi(ChanName{i},s.channel));
        CurrIndex = find(ismember(upper(s.channel),upper(ChanName(i))));
        if isempty(CurrIndex)
            ChanIndex(i) = NaN;
        else
            ChanIndex(i) = CurrIndex;
        end
    end
end