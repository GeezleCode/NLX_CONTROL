function ChName = spk_getAnalogChanName(s,iCh)

% returns the name of an analog channel
% displays all channels, if no input and no channel currently selected.
% ChName = spk_getAnalogChanName(s,iCh)

%% show trialcode info
if nargin<2 && isempty(s.currentanalog)
    nCh = length(s.analogname);
    fprintf(1,'existing analog channels:\n');
    for i=1:nCh
        fprintf(1,'%10s ',s.analogname{i});
    end
    fprintf(1,'\n');

elseif nargin<2 && ~isempty(s.currentanalog)
    ChName = s.analogname(s.currentanalog);
    if length(ChName)==1;
        ChName = char(ChName);
    end
else
    ChName = s.analogname(iCh);
    if length(ChName)==1;
        ChName = char(ChName);
    end
end
