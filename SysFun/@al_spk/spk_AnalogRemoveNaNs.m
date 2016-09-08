function s = spk_AnalogRemoveNaNs(s)

% removes the NaN's introduced by padding the analog trial matrix
% s = spk_AnalogRemoveNaNs(s)

if isempty(s.currentanalog)
    s.currentanalog = 1:size(s.analog,2);
end
nChan = length(s.currentanalog);

for iCh = 1:nChan
    ChNr = s.currentanalog(iCh);
    NotNaNbins = all(~isnan(s.analog{ChNr}),1);

    LoBin = min(find(NotNaNbins));
    HiBin = max(find(NotNaNbins));
    s.analog{ChNr} = s.analog{ChNr}(:,LoBin:HiBin);
    s.analogalignbin(ChNr) = s.analogalignbin(ChNr)-(LoBin-1);
end
    
