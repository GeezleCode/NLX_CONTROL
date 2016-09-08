function [s,c] = spk_TrialCut(s,i)

% cut trials out of an object
% [s,c] = spk_cuttrials(s,i)
%
% INPUT
% i ... trial indices
% OUTPUT
% s ... modified object
% c ... cut out trial as object


c = s;

if ~isempty(s.spk);
    c.spk = s.spk(:,i);
    s.spk(:,i) = [];
end

if ~isempty(s.spkwave);
    c.spkwave = s.spkwave(:,i);
    s.spkwave(:,i) = [];
end

if ~isempty(s.analog);
    for k = 1:length(s.analog)
        c.analog{k} = s.analog{k}(i,:);           
        s.analog{k}(i,:) = [];
    end
end

if ~isempty(s.events);
    c.events = s.events(:,i);           
    s.events(:,i) = [];
end

if ~isempty(s.align);
    c.align = s.align(i);             
    s.align(i) = [];
end

if ~isempty(s.trialcode);
    c.trialcode = s.trialcode(:,i);   
    s.trialcode(:,i) = [];
end

if ~isempty(s.currenttrials);
    c.currenttrials = [];             
    s.currenttrials = [];
end

if ~isempty(s.stimulus);
    c.stimulus = s.stimulus(:,i);             
    s.stimulus(i) = [];
end




 
