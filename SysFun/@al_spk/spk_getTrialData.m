function [x,y] = spk_getTrialData(s,Field,TrialIndex,FieldLabel)

% get data from trial arrays
%
% [x,y] = spk_getTrialData(s,Field,TrialIndex,FieldLabel)
%
% Field  ......... defines what data to extract
%                 'spk', 'analog', 'trialcode' or 'events'
% [TrialIndex] ... trial index, use s.currenttrials if omitted
% [FieldLabel] ... secondary index, indicating channels or labels (Index or
%                  Label)
%

if nargin<2 || isempty(TrialIndex)
    TrialIndex = spk_CheckCurrentTrials(s,true);
end
    
switch Field
    case 'spk'
        y = s.channel;
        if nargin>3 && ~isempty(FieldLabel)
            if iscell(FieldLabel) || ischar(FieldLabel)
                FieldLabel = spk_findSpikeChan(s,FieldLabel);
            end
        end
        x = s.spk(FieldLabel,TrialIndex);
                
    case 'analog'
        y = s.analogname;
        if nargin>3 && ~isempty(FieldLabel)
            if iscell(FieldLabel) || ischar(FieldLabel)
                FieldLabel = spk_findAnalog(s,FieldLabel,false);
            end
        else
            FieldLabel = 1:length(s.analog);
        end
        for i = 1:length(FieldLabel)
            x{i} = s.analog{FieldLabel(i)}(TrialIndex,:);
        end
        
    case 'trialcode'
        y = s.trialcodelabel;
        if nargin>3 && ~isempty(FieldLabel)
            if iscell(FieldLabel) || ischar(FieldLabel)
                FieldLabel = spk_findTrialcodelabel(s,FieldLabel);
            end
        else
            FieldLabel = 1:length(s.analog);
        end
        x = s.trialcode(FieldLabel,TrialIndex);
    
    case 'events'
        y = s.eventlabel;
        if nargin>3 && ~isempty(FieldLabel)
            if iscell(FieldLabel) || ischar(FieldLabel)
                FieldLabel = spk_findEventlabel(s,FieldLabel);
            end
        else
            FieldLabel = 1:length(s.analog);
        end
        x = s.events(FieldLabel,TrialIndex);
end