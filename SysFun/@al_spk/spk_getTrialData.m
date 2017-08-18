function out = spk_getTrialData(s,TrNr,field)

% returns data of a given category
% TrNr ...
% field

switch field
    case 'events'
        out = s.events(:,TrNr);
    case 'align'
        out = s.align(TrNr);
    case 'trialcode'
        out = s.trialcode(:,TrNr);
    case 'stimulus'
        out = s.stimulus(TrNr);
    case 'spk'
        if isempty(s.currentchan);
            s.currentchan = 1:size(s.spk,1);
        end
        out = s.spk(s.currentchan,TrNr);
    case 'analog'
        if isempty(s.currentanalog);
            s.currentanalog = 1:length(s.analog);
        end
        for i=1:length(s.currentanalog)
            out{i} = s.analog{s.currentanalog(i)}(TrNr,:);
        end
    case 'analogtime'
        out = s.analogtime(TrNr);
    case 'analogalignbin'
        out = s.analogalignbin(TrNr);
end        