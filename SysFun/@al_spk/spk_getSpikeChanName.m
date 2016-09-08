function ChName = spk_getSpikeChanName(s,iCh)

% returns the name of spike channel
% displays all channels, if no input and no channel currently selected.
% ChName = spk_getSpikeChanName(s,iCh)

%% show trialcode info
if nargin<2 && isempty(s.currentchan)
    nCh = length(s.channel);
    fprintf(1,'existing spike channels:\n');
    for i=1:nCh
        fprintf(1,'%10s ',s.channel{i});
    end
    fprintf(1,'\n');

elseif nargin<2 && ~isempty(s.currentchan)
    ChName = s.chan(s.currentchan);
    if length(ChName)==1;
        ChName = char(ChName);
    end
else
    ChName = s.channel(iCh);
    if length(ChName)==1;
        ChName = char(ChName);
    end
end
