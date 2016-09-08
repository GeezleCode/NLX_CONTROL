function [c] = spk_ExtractTrials(s,i)

% extract trials out of an object
% [c] = spk_cuttrials(s,i)
%
% INPUT
% i ... trial indices
% OUTPUT
% c ... extracted trials as object


c = s;

if ~isempty(s.spk);
    c.spk = s.spk(:,i);
end

if ~isempty(s.spkwave);
    c.spkwave = s.spkwave(:,i);
end

if ~isempty(s.analog);
    for k = 1:length(s.analog)
        c.analog{k} = s.analog{k}(i,:);           
    end
end

if ~isempty(s.events);
    c.events = s.events(:,i);           
end

if ~isempty(s.align);
    c.align = s.align(i);             
end

if ~isempty(s.trialcode);
    c.trialcode = s.trialcode(:,i);   
end

if ~isempty(s.currenttrials);
    c.currenttrials = [];             
end

if ~isempty(s.stimulus);
    c.stimulus = s.stimulus(:,i);             
end




 
