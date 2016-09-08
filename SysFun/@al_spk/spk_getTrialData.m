function [x,y] = spk_getTrialData(s,Field,TrialIndex,ChanIndex)

% retrieve trial data
% [x,y] = spk_getTrialData(s,Field,TrialIndex,ChanIndex)
% Field: 'spk' 'analog' 'trialcode' 'events'

if nargin<4
    ChanIndex = [];
end

switch Field
    case 'spk'
        y = s.channel;
        if isempty(ChanIndex), x = s.spk(:,TrialIndex);
        else x = s.spk(ChanIndex,TrialIndex);end
    case 'analog'
        y = s.analogname;
        if isempty(ChanIndex),
            for i=1:length(s.analog)
                x{1,i} = s.analog{i}(TrialIndex,:);
            end
        else x = s.analog{ChanIndex}(TrialIndex,:);
        end
    case 'trialcode'
        y = s.trialcodelabel;
        if isempty(ChanIndex), x = s.trialcode(:,TrialIndex);
        else x = s.trialcode(ChanIndex,TrialIndex);end
    case 'align'
        y = [];
        x = s.align(1,TrialIndex);
    case 'events'
        y = s.eventlabel;
        if isempty(ChanIndex), x = s.events(:,TrialIndex);
        else x = s.events(ChanIndex,TrialIndex);end
    otherwise
        error('Don''t know name of data-field!!');
end