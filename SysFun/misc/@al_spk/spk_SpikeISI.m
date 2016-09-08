function [ISI,SpikeNum] = spk_SpikeISI(s)

% get spike ISI data

nTr = spk_TrialNum(s);
nCh = spk_SpikeChanNum(s);

if isempty(s.currentchan)
    s.currentchan = 1:nCh;
end

if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end
if ~iscell(s.currenttrials)
    s.currenttrials = {s.currenttrials};
end
nTrGrps = length(s.currenttrials);

for iCh = 1: length(s.currentchan)
    cCh = s.currentchan(iCh);
    
    for iTrGrp = 1:nTrGrps
        SpikeNum(iCh,iTrGrp) = 0;
        ISI(iCh,iTrGrp) = {[]};
        for iTr = 1:length(s.currenttrials{iTrGrp})
            SpikeNum(iCh,iTrGrp) = SpikeNum(iCh,iTrGrp)+length(s.spk{cCh,s.currenttrials{iTrGrp}(iTr)});
            ISI{iCh,iTrGrp} = cat(1,ISI{iCh,iTrGrp},diff(s.spk{cCh,s.currenttrials{iTrGrp}(iTr)}));
        end
    end
end

