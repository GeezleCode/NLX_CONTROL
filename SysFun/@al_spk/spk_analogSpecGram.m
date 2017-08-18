function [B,f,t] = spk_analogSpecGram(s,nfft,WINDOW,NOVERLAP)



if nargin<2 | isempty(nfft)
    nfft = 512;
end

numAna = length(s.currentanalog);

for iA = s.currentanalog
    iANr = find(s.currentanalog==iA);

    [NumTrials,NumSamples] = size(s.analog{s.currentanalog(iA)});
	[out,s] = spk_CheckCurrentTrials(s,1);
    
%     t = spk_analogtimematrix(s);
%     WinBins = find(t>=timewin(1) & t<=timewin(2));
%     
%     nWinBins = length(WinBins);
%     if nWinBins<nfft
%         warning('Time Window doesn''t match nfft!');
%     end
    
	for i = 1:length(s.currenttrials)
		[B{iANr}(:,:,i),f{iANr},t{iANr}] = specgram(s.analog{iA}(s.currenttrials(i),:),nfft,s.analogfreq(iA),WINDOW,NOVERLAP);
	end
	B{iANr} = 20.*log10(abs(B{iANr})+eps);


end

if numAna==1
    B = B{1};
    f = f{1};
    t = t{1};
end

