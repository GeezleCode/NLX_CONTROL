function s = spk_SpikeTimePrecision(s,Prec,RemoveDupFlag)

% set the temporal precision of timestamps
% s = spk_SpikeTimePrecision(s,Prec,RemoveDupFlag)
%
% Prec ............. precision in power to ten seconds, e.g. -3 is milliseconds
% RemoveDupFlag .... removes timestamp duplicates (created by rounding)

fprintf(1,'set spike time precision to 10^%1.0f ...\n',Prec);

if isempty(s.timeorder)
    error('The field s.timeorder is not set. Can''t estimate precision of timestamps!');
end
[nCh,nTr] = size(s.spk);

for iCh = 1:nCh
    for iTr = 1:nTr
        
        s.spk{iCh,iTr} = round(s.spk{iCh,iTr}.*(10^(s.timeorder-Prec)))./(10^(s.timeorder-Prec));
        [s.spk{iCh,iTr},SortIdx] = sort(s.spk{iCh,iTr});
        
        if ~isempty(s.spkwave)
            s.spkwave{iCh,iTr} = s.spkwave{iCh,iTr}(SortIdx,:);
        end
        
        if RemoveDupFlag
            RMi = find(diff(s.spk{iCh,iTr})==0) + 1;
            s.spk{iCh,iTr}(RMi) = [];
            if ~isempty(s.spkwave)
                s.spkwave{iCh,iTr}(RMi,:) = [];
            end
        end
    end
end

