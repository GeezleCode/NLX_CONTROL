function [mBLP,trBLP,trBLS,t] = spk_AnalogBLPower(s,fBands,TimeWin,Event,ffun,fParam,DoEnvelope)

% compute the Band-limited power of an analog signal
%
% [mBLP,trBLP,trBLS,t] = spk_AnalogBLPower(s,fBands,TimeWin,Event,ffun,fParam)
%
% fBands .... frequency band limits [n Bands X 2]
% TimeWin ... time window for analog signal
% Event ..... reference event for time window
% ffun ...... filter function, see spk_AnalogFiltFilt.m
% fParam .... filter parameter function, see spk_AnalogFiltFilt.m
%
% mBLP .... mean BLP signal [nBands x nBins x nCh]
% trBLP ... BLP signals 
% trBLS ... band limited signal
% t ....... timebins
%
% 1. bandpass filtering the appropriate signal using a second-order, 
%    bidirec- tional, zero-phase Chebyshev type 1 bandpass filter
% 2. full-wave rectification

if nargin<7
    DoEnvelope = false;
end

[currentchan,s] = spk_CheckCurrentAnalog(s,true);
nChan = length(currentchan);

[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(currenttrials);

nfB = size(fBands,1);

trBLS = cell(nfB,nChan);
trBLP = cell(nfB,nChan);

for ifB = 1:nfB
    for iCh = 1:nChan
        s.currentanalog = currentchan(iCh);
        
        sfB = spk_AnalogFiltFilt(s,ffun,fBands(ifB,:),'bandpass',fParam);
        [trBLS{ifB,iCh},t] = spk_getAnalog(sfB,TimeWin,[],Event);
        
        sfB = spk_AnalogRectify(sfB);
        
        if DoEnvelope
%             sfB = spk_AnalogEnvelope(sfB,'POS');
            sfB = spk_AnalogFiltFilt(sfB,'butter',10,'low',{'n',3});
        end
                
        [trBLP{ifB,iCh},t] = spk_getAnalog(sfB,TimeWin,[],Event);
        mBLP(ifB,:,iCh) = agmean(trBLP{ifB,iCh},[],1);
    end
end
