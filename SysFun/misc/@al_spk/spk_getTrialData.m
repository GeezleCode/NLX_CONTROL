function [x,y] = spk_getTrialData(s,Field,TrialIndex,LabelIndex)

% get data from trial arrays
%
% [x,y] = spk_getTrialData(s,Field,TrialIndex,LabelIndex)
%
% Field  ....... defines what data to extract
%                'spk', 'analog', 'trialcode' or 'events'
% TrialIndex ... trial index
% LabelIndex ... secondary index, indicating channels or labels
%

if nargin<3
    TrialIndex = [];
    if ~isempty(s.currenttrials)
        TrialIndex = s.currenttrials;
    end
end
if nargin<4
    LabelIndex = [];
end

switch Field
    case 'spk'
        [nLab,nTr] = size(s.spk);
        if isempty(LabelIndex);LabelIndex = [1:nLab];end
        if isempty(TrialIndex);TrialIndex = [1:nTr];end
        y = s.channel;
        x = s.spk(LabelIndex,TrialIndex);
    case 'analog'
        nLab = length(s.analog);
        nTr = size(s.trialcode,2);
        if isempty(LabelIndex);LabelIndex = [1:nLab];end
        if isempty(TrialIndex);TrialIndex = [1:nTr];end
        y = s.analogname;
        x = s.analog{LabelIndex}(TrialIndex,:);
    case 'trialcode'
        [nLab,nTr] = size(s.trialcode);
        if isempty(LabelIndex);LabelIndex = [1:nLab];end
        if isempty(TrialIndex);TrialIndex = [1:nTr];end
        y = s.trialcodelabel;
        x = s.trialcode(LabelIndex,TrialIndex);
    case 'events'
        [nLab,nTr] = size(s.events);
        if isempty(LabelIndex);LabelIndex = [1:nLab];end
        if isempty(TrialIndex);TrialIndex = [1:nTr];end
        y = s.eventlabel;
        x = s.events(LabelIndex,TrialIndex);
    case 'align'
        nTr = size(s.align,1);
        if isempty(TrialIndex);TrialIndex = [1:nTr];end
        y = [];
        x = s.align(1,TrialIndex);
end