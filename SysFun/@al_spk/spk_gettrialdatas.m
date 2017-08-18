function values = spk_gettrialdata(s,PropName)

% gets data of trials specified by s.currenttrials
%
% values = spk_gettrialdata(s,PropName)
%
% PropName can be 'SPK','EVENTS','ALIGN','TRIALCODE'

if isempty(s.currenttrials)
    s.currenttrials = 1:spk_numtrials(s);
end

switch upper(PropName)
    case 'SPK'
        values = s.spk(:,s.currenttrials);
    case 'EVENTS'
        values = s.events(:,s.currenttrials);
    case 'ALIGN'
        values = s.align(s.currenttrials);
    case 'TRIALCODE'
        values = s.trialcode(:,s.currenttrials);
    case 'ANALOG'
        values = s.analog(:,s.currenttrials);
    otherwise
        error(['can''t return ' PropName ' trials !']);
end
