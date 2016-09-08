function nospikes = spk_isempty(s)

% checks for trials with no spikes
% works on current trials
% if you want to check all trials use spk_set(s,'currenttrials',[]) first

nospikes = isempty(s.spk);

if nospikes==1;nospikes=logical(nospikes);return;end

if isempty(s.currenttrials)
    nospikes = cellfun('isempty',s.spk);
else
    nospikes = cellfun('isempty',s.spk(s.currenttrials));
end    