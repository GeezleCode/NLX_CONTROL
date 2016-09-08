function i = spk_findTrialcodelabel(s,trialcodelabel)

% returns the index of a trialcodelabel
%
% i = spk_findTrialcodelabel(s,trialcodelabel)

if ischar(trialcodelabel)
    i = find(strcmp(trialcodelabel,s.trialcodelabel));
elseif iscell(trialcodelabel)
    n = length(trialcodelabel);
    i = zeros(1,n).*NaN;
    for iTcl = 1:n
        ci = strcmp(trialcodelabel{iTcl},s.trialcodelabel);
        if any(ci)
            i(iTcl) = find(ci);
        end
    end
end
