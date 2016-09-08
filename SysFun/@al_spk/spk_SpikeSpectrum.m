function R = spk_SpikeSpectrum(s,TimeWin,Event,BinWidth,Method,Set)

% performs spectral analysis of spike data
% R = spk_SpikeSpectrum(s,TimeWin,Event,BinWidth,Method,Set)
%
% TimeWin .... time window
% Event ...... reference event
% BinWidth ... width of time bins in SEC
% Method ..... character , see below
% Set ........ settings structure, see below
%
% METHODS:
% 'FFT'
% 'HANNING FFT'
% 'PMTM'
% 'CHRONUX'
% 'HilbertHuang'
% 'SPECTROGRAM'
% 'CHRONUXSPECGRAM'
%
% OUTPUT structure:
%         Set: [1x1 struct]
%          Ep: [1x1 Epoch]
%      EpBase: [1x1 Epoch]
%        Spec: {{3x1 cell}  {3x2 cell}}
%        Freq: {[1x144 double]  [1x144 double]}
%       SpecM: {[144x3 double]  [144x3x2 double]}
%       SpecS: {[144x3 double]  [144x3x2 double]}
%      SpecSE: {[144x3 double]  [144x3x2 double]}
%    SpecGram
%            t

%%
if nargin<5
    Set = [];
end

default.SpecSmoothFlag = false;
default.FreqBand = [];
default.Precision = -3;
default.RemoveMultiTimestamps = true;
default.Fs = (1/BinWidth);
default.removeDC = false;

%% channels
[ChanNr,s] = spk_CheckCurrentChannels(s,true);
nCh = length(ChanNr);
    
%% get trial groups
[TrGrp,s] = spk_CheckCurrentTrials(s,true);
if isnumeric(TrGrp)
    TrGrp = {TrGrp};
end
nTrGrps = numel(TrGrp);

%%
for iCh = 1:nCh        
    R(iCh).Method = Method;
    R(iCh).Spec = cell(1,nTrGrps);
    R(iCh).Freq = [];
    R(iCh).SpecGram = cell(1,nTrGrps);
    R(iCh).SpecGramF = [];
    R(iCh).SpecGramT = [];
%     R(iCh).imf = cell(1,nGrp);
%     R(iCh).imffreq = cell(1,nGrp);
    
    for iGrp = 1:nTrGrps
        nTr = length(TrGrp{iGrp});
        if isempty(TrGrp{iGrp});continue;end
        s = spk_set(s,'currenttrials',TrGrp{iGrp},'currentanalog',ChanNr(iCh));
        
%         tWin = spk_getEventWindow(s,Event,TimeWin);
        
        switch Method
            case 'FFT'
                %default.Fs = spk_getAnalogFs(s);
                default.N  = [];
                default.fres = 1;
                default.fpass  = [0 200];
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder),Set.removeDC);
                [R(iCh).Spec{iGrp},R(iCh).Freq] = fftspectrumc(dlfp,Set.Fs,Set.N,Set.fres,Set.fpass);
                R(iCh).Freq = R(iCh).Freq(:);
            case 'HANNING FFT'
                %default.Fs = spk_getAnalogFs(s);
                default.N  = 4096;
                default.fres = [];
                default.fpass  = [0 200];
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder),Set.removeDC);
                [nSpl,nTr] = size(dlfp);
                FFTWin = repmat(hanning(nSpl),[1,nTr]);
                [R(iCh).Spec{iGrp},R(iCh).Freq] = fftspectrumc(dlfp.*FFTWin,Set.Fs,Set.N,Set.fres,Set.fpass);
                R(iCh).Freq = R(iCh).Freq(:);
            case 'PMTM'
                default.dpss = 3;% scalar: time-bandwith-product cell: input for dpss.m
                default.f = 4096;% can be NFFT or vector of frequencies
                %default.Fs = spk_getAnalogFs(s);
                default.p = 0.95;
                default.DropLastTaper = true;
                default.method = 'adapt'; 
                default.range = 'onesided';
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder),Set.removeDC);
                [nSpl,nTr] = size(dlfp);
                for iTr = 1:nTr
                    [R(iCh).Spec{iGrp}(:,iTr),R(iCh).conf,R(iCh).Freq] = pmtm(dlfp(:,iTr), ...
                        Set.dpss,Set.f,Set.Fs, ...
                        Set.method,Set.range,'DropLastTaper',Set.DropLastTaper);
                end
                
            case 'CHRONUX'
                default.tapers = [2 3];
                default.pad = 4;
                %default.Fs = spk_getAnalogFs(s);
                default.fpass = [0 200];
                default.err = 0;
                default.trialave = 0;
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder),Set.removeDC);
                [R(iCh).Spec{iGrp},R(iCh).Freq]=mtspectrumpb(dlfp,Set);
                R(iCh).Freq = R(iCh).Freq(:);
            case 'HilbertHuang'
                %default.Fs = spk_getAnalogFs(s);
                default.maxIMFiteration = inf;
                default.fpass = [0 200];
                default.fbinwidth = 1;
                default.SigmaSec = 0.025;
                default.SigmaHz = 1;
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder),Set.removeDC);
                [S,t,f,imf,tf] = HilbertHuangTransform(dlfp',1/Set.Fs,Set.maxIMFiteration,Set.fpass,Set.fbinwidth);
                if ~isempty(Set.SigmaSec)&&~isempty(Set.SigmaHz)
                    for iTr = 1:nTr
                        SigmaSec = Set.SigmaSec/(1/Set.Fs);
                        SigmaHz = Set.SigmaHz/Set.fbinwidth;
                        SmoothN = round([SigmaHz*2 SigmaSec*2]);
                        S(:,:,iTr) = GaussianFilter2D(S(:,:,iTr),[SigmaHz,SigmaSec],[SmoothN],'same');
                    end
                end
                R(iCh).SpecGram{iGrp} = S;
                R(iCh).SpecGramF = f';
                R(iCh).SpecGramT = t.*1000+TimeWin(1);
%                 R(iCh).imf{iGrp} = imf;
%                 R(iCh).imffreq{iGrp} = tf;
                
                % calculate marginal power spectrum 
                TWindex = R(iCh).SpecGramT>=TimeWin(1) & R(iCh).SpecGramT<TimeWin(2);
                R(iCh).Spec{iGrp} = trapz(R(iCh).SpecGramT(TWindex)./1000,R(iCh).SpecGram{iGrp}(:,TWindex,:).^2,2);
                dt = (R(iCh).SpecGramT(find(TWindex,1,'last'))/1000-R(iCh).SpecGramT(find(TWindex,1,'first'))/1000);% window width in sec
                R(iCh).Spec{iGrp} = R(iCh).Spec{iGrp} ./ dt;
                R(iCh).Spec{iGrp} = permute(R(iCh).Spec{iGrp},[1 3 2]);
                R(iCh).Freq = R(iCh).SpecGramF;
            case 'SPECTROGRAM'
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder));
                nSpecGramWin = round(Set.SpecGramWin/(1/Set.Fs));
                noverlap = nSpecGramWin - round(Set.SpecGramTs/(1/Set.Fs));
                P = [];
                for iTr = 1:nTr
                    [S,f,t,P(:,:,iTr)] = spectrogram(dlfp(:,iTr),hanning(nSpecGramWin),noverlap,Set.SpecGramNfft,Set.Fs);
                end
                R(iCh).SpecGram{iGrp} = P;% 10*log10(P)
                R(iCh).SpecGramF = f;
                R(iCh).SpecGramT = t.*1000+TimeWin(1);
                                
                TWindex = R(iCh).SpecGramT>=TimeWin(1) & R(iCh).SpecGramT<TimeWin(2);
                R(iCh).Spec{iGrp} = agmean(R(iCh).SpecGram{iGrp}(:,TWindex,:),[],2);
                R(iCh).Spec{iGrp} = permute(R(iCh).Spec{iGrp},[1 3 2]);
                R(iCh).Freq = R(iCh).SpecGramF;
            case 'CHRONUXSPECGRAM'
                s = spk_SpikeTimePrecision(s,Set.Precision,Set.RemoveMultiTimestamps);
                [dlfp,tlfp] = spk_SpikeBins(s,Event,TimeWin,(1/Set.Fs)/(10^s.timeorder));
                [S,t,f] = mtspecgramc(dlfp,[Set.SpecGramWin Set.SpecGramTs],Set);
                
                R(iCh).SpecGram{iGrp} = permute(S,[2 1 3]);% 10*log10(P)
                R(iCh).SpecGramF = f';
                R(iCh).SpecGramT = t.*1000+TimeWin(1);
                
                TWindex = R(iCh).SpecGramT>=TimeWin(1,1) & R(iCh).SpecGramT<TimeWin(1,2);
                R(iCh).Spec{iGrp} = agmean(R(iCh).SpecGram{iGrp}(:,TWindex,:),[],2);
                R(iCh).Spec{iGrp} = permute(R(iCh).Spec{iGrp},[1 3 2]);
                R(iCh).Freq = R(iCh).SpecGramF;
        end
    end
    
    % reconstruct factor dimensions
    R(iCh).Spec = reshape(R(iCh).Spec,size(TrGrp));
end

%% filter the spectra
if Set.SpecSmoothFlag
    for iCh = 1:nCh
        nGrp = numel(TrGrp);
        nLevel = size(TrGrp);
        for iGrp = 1:nGrp
            % R(iCh).Spec{iGrp} = sgolayfilt(R(iCh).Spec{iGrp},3,41);
            for iTr = 1:size(R(iCh).Spec{iGrp},2)
                R(iCh).Spec{iGrp}(:,iTr) = smooth(R(iCh).Spec{iGrp}(:,iTr),17,'sgolay',3);
            end
        end
    end
end

%% average over trials
for iCh = 1:nCh
    nGrp = numel(TrGrp);
    nLevel = size(TrGrp);
    
    for iGrp = 1:nGrp
        [nFB,nTr] = size(R(iCh).Spec{iGrp});
        
        % calc mean and median
        [R(iCh).SpecM(:,iGrp),R(iCh).SpecS(:,iGrp),R(iCh).SpecSE(:,iGrp)] = agmean(R(iCh).Spec{iGrp},[],2);
        [R(iCh).SpecMed(:,iGrp),R(iCh).SpecP25(:,iGrp),R(iCh).SpecP75(:,iGrp)] = agmedian(R(iCh).Spec{iGrp},[25 75],2);
        
%         % detect outliers
%         SpecZScore = (R(iCh).Spec{iGrp} - repmat(R(iCh).SpecM(:,iGrp),[1,nTr])) ./ repmat(R(iCh).SpecSE(:,iGrp),[1,nTr]);
%         fprintf(1,'%2.2f %2.2f\n',min(SpecZScore(:)),max(SpecZScore(:)));
    end
    
    % reconstruct factor dimensions
    R(iCh).SpecM = reshape(R(iCh).SpecM,[size(R(iCh).SpecM,1) nLevel]);
    R(iCh).SpecS = reshape(R(iCh).SpecS,[size(R(iCh).SpecS,1) nLevel]);
    R(iCh).SpecSE = reshape(R(iCh).SpecSE,[size(R(iCh).SpecSE,1) nLevel]);
    R(iCh).SpecMed = reshape(R(iCh).SpecMed,[size(R(iCh).SpecMed,1) nLevel]);
    R(iCh).SpecP25 = reshape(R(iCh).SpecP25,[size(R(iCh).SpecP25,1) nLevel]);
    R(iCh).SpecP75 = reshape(R(iCh).SpecP75,[size(R(iCh).SpecP75,1) nLevel]);
end

%% COMPUTE: Frequency Bands
nFB = size(Set.FreqBand,1);
for iCh = 1:nCh
    nGrp = numel(TrGrp);
    nLevel = size(TrGrp);
    
    % allocate
    for iGrp = 1:nGrp
        R(iCh).FB(iGrp) = struct( ...
            'Tr',{cell(1,nFB)}, ...
            'M' ,{zeros(1,nFB).*NaN}, ...
            'S' ,{zeros(1,nFB).*NaN}, ...
            'SE' ,{zeros(1,nFB).*NaN}, ...
            'Med' ,{zeros(1,nFB).*NaN}, ...
            'P25' ,{zeros(1,nFB).*NaN}, ...
            'P75' ,{zeros(1,nFB).*NaN});
    end
    R(iCh).FB = reshape(R(iCh).FB,nLevel);
    
    for iFB = 1:nFB
        cFBWin = R(iCh).Freq>Set.FreqBand(iFB,1) & R(iCh).Freq<=Set.FreqBand(iFB,2);
        for iGrp = 1:[nGrp]
            % average power in band
            R(iCh).FB(iGrp).Tr{1,iFB} = agmean(R(iCh).Spec{iGrp}(cFBWin,:),[],1);
            [R(iCh).FB(iGrp).M(1,iFB),R(iCh).FB(iGrp).S(1,iFB),R(iCh).FB(iGrp).SE(1,iFB)] = agmean(R(iCh).FB(iGrp).Tr{1,iFB},[],2);
            [R(iCh).FB(iGrp).Med(1,iFB),R(iCh).FB(iGrp).P25(1,iFB),R(iCh).FB(iGrp).P75(1,iFB)] = agmedian(R(iCh).FB(iGrp).Tr{1,iFB},[25 75],2);
        end
    end
end
