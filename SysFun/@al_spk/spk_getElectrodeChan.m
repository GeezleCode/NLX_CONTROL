function [i,e] = spk_getElectrodeChan(s,El);

% retrieves index for channels of a given electrode
% assumes that channelnames consist of [El].[ClusterNr] (e.g. Sc1.1)
% [i,e] = spk_GetElectrodeChan(s,El)
% i ... logical index of current electrode [ElChanNum X totalChanNum]
% e ... cell array of electrode name

[ElChans,ClChans] = spk_SpikeDecodeChanName(s);
e = unique(ElChans);
nCh = length(ElChans);

if nargin<2 | isempty(El)
    ne = length(e);
    i = false(ne,nCh);
    for ie = 1:ne
        i(ie,:) = ismember(ElChans,e(ie));
    end
else
    if ischar(El);
        e = {El};
    else
        e = El;
    end
    ne = length(e);
    i = false(ne,nCh);
    for ie = 1:ne
        i(ie,:) = ismember(ElChans,e(ie));
    end
end
