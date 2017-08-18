function [h,s] = spk_analogLine1(s,TrialYDiff,varargin)

numTrials = spk_numtrials(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end

numAna = length(s.currentanalog);

for a = 1:numAna
    
    numCurrenttrials = length(s.currenttrials);
    
    [nTr,numSamples] = size(s.analog{a});
    TimeData = spk_analogtimematrix(s);
    
    h = line( ...
        repmat(TimeData,[length(s.currenttrials) 1])', ...
        s.analog{a}(s.currenttrials,:)' + repmat([1:numCurrenttrials],[numSamples 1]) .* TrialYDiff, ...
        varargin{:});
    
    for i = 1:length(s.currenttrials)
        line( ...
            [cat(2,s.events{:,s.currenttrials(i)});cat(2,s.events{:,s.currenttrials(i)})], ...
            repmat([i.*TrialYDiff-0.5*TrialYDiff;i.*TrialYDiff+0.5*TrialYDiff],[1 length(cat(2,s.events{:,s.currenttrials(i)}))]), ...
            'color','m');
    end
    
end

