function total = spk_TrialNum(s)

% returns and check for number of trials in @al_spk object
% function total = spk_numtrials(s)
%
% total ... total number of trials


% check trial numbers
nTrials = zeros(1,6);

nTrials(1) = size(s.spk,2);
nTrials(2) = size(s.events,2);
nTrials(3) = size(s.align,2);
nTrials(4) = size(s.trialcode,2);
nTrials(5) = size(s.stimulus,2);

% nAnalogTrials = cellfun('size',s.analog,1);


if any(nTrials==0 | isnan(nTrials))
    nTrials = nTrials(nTrials~=0 & ~isnan(nTrials));
%     warning('spk_numtrials: empty fields in object !');
end
if isempty(nTrials)
    nTrials = 0;
end

total = unique(nTrials);
if length(total)>1
    error('inconsistency in number of trials !!!');
end

% function nTrials = check_array(x,dim)
% if isempty(x)
%     nTrials = NaN;
% elseif iscell(x)
%     nTrials = cellfun('size',x,dim);
% elseif isnumeric(x)
%     nTrials = size(x,dim);
% end