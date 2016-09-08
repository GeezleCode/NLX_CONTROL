function [PS,F] = spk_analogPowerSpectrum(s,timewin,nfft)

if nargin<3
    nfft = 512;
end

numAna = length(s.currentanalog);

for iA = 1:length(s.currentanalog)
    iANr = s.currentanalog(iA);

    [NumTrials,NumSamples] = size(s.analog{iANr});
    if isempty(s.currenttrials)
        s.currenttrials = 1:size(NumTrials,1);
    end
    
    t = spk_AnalogTimeVec(s);
    
    WinBins = find(t>=timewin(1) & t<=timewin(2));
    
    nWinBins = length(WinBins);
    if nWinBins<nfft
        warning('Time Window doesn''t match nfft!');
    end
    
    PS{iANr} = fft(s.analog{iA}(s.currenttrials,WinBins)',nfft)';
    PS{iANr} = PS{iANr}.* conj(PS{iANr}) / nfft;
    
    PS{iANr} = PS{iANr}(:,1:(nfft/2)+1);
    F{iANr} = s.analogfreq(iA)*(0:nfft/2)/nfft;

end

if numAna==1
    PS = PS{1};
    F = F{1};
end

