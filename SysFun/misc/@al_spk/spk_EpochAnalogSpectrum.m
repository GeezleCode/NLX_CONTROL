function R = spk_EpochAnalogSpectrum(s,ChanName,Par,Ep)

% compute spectrum of LFP
% R = spk_FA_AnalogSpectrum(s,ChanName,Par,Ep,EpBase)
%
% s ... @al_spk object
% ChanName ... analog channel name
%
% Set ........ settings for computations
%              Set.SpecMethod - 'FFT' 'HANNING FFT' 'CHRONUX'
%              Set.SpecBand - [loF hiF]
%              Set.SpecNormMode = 'Z'
%              Set.ChronuxPar.tapers - [TW K] Bandwidth product and number of tapers
%              Set.ChronuxPar.pad - scalar integer
%              Set.ChronuxPar.Fs - sample frequency
%              Set.ChronuxPar.fpass - pass band
%              Set.ChronuxPar.err - scalar
%              Set.ChronuxPar.trialave - scalar
%              Set.FFTPar.Fs - sample frequency
%              Set.FFTPar.N - points of fourier transformation
%              Set.FFTPar.Fres - frequency resolution of fft
%              Set.FFTPar.Flim - 
%
% Ep,EpBase .. condition grouping structure
%              Ep(iWin).Name - [char] name of this window
%              Ep(iWin).PlotWin - [1x2] time window for plotting
%              Ep(iWin).AnalyseWin - [1x2] time window for analyses
%              Here, factors and levels are different from Pdm.Cnd because of
%              regrouping of conditions
%              Ep(iWin).GroupFactor - {1xnFac} char with name of factor  
%              Ep(iWin).GroupLevel - {1xnFac} arrays with parameter of cateories
%              Ep(iWin).GroupCnd - {nLevel1 x nLevel2 x nLevel3 ...} condition numbers
%              Ep(iWin).GroupAlignEvent - {nLevel1 x nLevel2 x nLevel3 ...} event strings
%              Ep(iWin).GroupTrialIndex - {nLevel1 x nLevel2 x nLevel3 ...} trialindices
% 
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

iCh = spk_findAnalog(s,ChanName);
nEp = length(Ep);

for iEp = 1:nEp
    R(iEp).Set = Par;
    R(iEp).Ep = Ep(iEp);
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    nWin = size(Ep(iEp).AnalyseWin,1);
        
    R(iEp).Spec = cell(1,nWin);R(iEp).Spec(:) = {cell(1,nGrp)};
    R(iEp).Freq = cell(1,nWin);
    R(iEp).SpecGram = cell(1,nGrp);
    R(iEp).SpecGramF = [];
    R(iEp).SpecGramT = [];
%     R(iEp).imf = cell(1,nGrp);
%     R(iEp).imffreq = cell(1,nGrp);
    
    for iGrp = 1:nGrp
        nTr = length(Ep(iEp).GroupTrialIndex{iGrp});
        if isempty(Ep(iEp).GroupTrialIndex{iGrp});continue;end
        s = spk_set(s,'currenttrials',Ep(iEp).GroupTrialIndex{iGrp},'currentanalog',iCh);
        
        % get event as reference for the time window
        cEv = spk_getEvents(s,Ep(iEp).GroupAlignEvent{iGrp});
        cEv = round(cat(1,cEv{:}));
        
        switch Par.SpecMethod
            case 'FFT'
                for iWin = 1:nWin
                    R(iEp).Spec{iWin}{iGrp} = [];
                    R(iEp).Freq{iWin} = [];
                    [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseWin(iWin,:),cEv,false);
                    [R(iEp).Spec{iWin}{iGrp},R(iEp).Freq{iWin}] = fftspectrumc(dlfp,Par);
                    R(iEp).Freq{iWin} = R(iEp).Freq{iWin}(:);
                end
            case 'HANNING FFT'
                for iWin = 1:nWin
                    R(iEp).Spec{iWin}{iGrp} = [];
                    R(iEp).Freq{iWin} = [];
                    [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseWin(iWin,:),cEv,false);
                    [nSpl,nTr] = size(dlfp);
                    FFTWin = repmat(hanning(nSpl),[1,nTr]);
                    [R(iEp).Spec{iWin}{iGrp},R(iEp).Freq{iWin}] = fftspectrumc(dlfp.*FFTWin,Par.Fs,Par.N,Par.Fres,Par.Flim);
                    R(iEp).Freq{iWin} = R(iEp).Freq{iWin}(:);
                end
            case 'CHRONUX'
                for iWin = 1:nWin
                    R(iEp).Spec{iWin}{iGrp} = [];
                    R(iEp).Freq{iWin} = [];
                    [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseWin(iWin,:),cEv,false);
                    [R(iEp).Spec{iWin}{iGrp},R(iEp).Freq{iWin}]=mtspectrumc(dlfp,Par);
                    R(iEp).Freq{iWin} = R(iEp).Freq{iWin}(:);
                end
            case 'HilbertHuang'
                iWin = 1;
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseMainWin,cEv,false);
                fprintf(1,'HHT: Epoch %2.0f(%2.0f) Group %2.0f(%2.0f)\n',iEp,nEp,iGrp,nGrp);
                [S,t,f,imf,tf] = HilbertHuangTransform(dlfp',1/Par.Fs,Par.maxIMFiteration,Par.fpass,Par.fbinwidth);
                if ~isempty(Par.SigmaSec)&&~isempty(Par.SigmaHz)
                    for iTr = 1:nTr
                        SigmaSec = Par.SigmaSec/(1/Par.Fs);
                        SigmaHz = Par.SigmaHz/Par.fbinwidth;
                        SmoothN = round([SigmaHz*2 SigmaSec*2]);
                        S(:,:,iTr) = GaussianFilter2D(S(:,:,iTr),[SigmaHz,SigmaSec],[SmoothN],'same');
                    end
                end
                R(iEp).SpecGram{iGrp} = S;
                R(iEp).SpecGramF = f';
                R(iEp).SpecGramT = t.*1000+Ep(iEp).AnalyseMainWin(1);
%                 R(iEp).imf{iGrp} = imf;
%                 R(iEp).imffreq{iGrp} = tf;
                
                % calculate marginal power spectrum 
                for iWin = 1:nWin
                    TWindex = R(iEp).SpecGramT>=Ep(iEp).AnalyseWin(iWin,1) & R(iEp).SpecGramT<Ep(iEp).AnalyseWin(iWin,2);
                    R(iEp).Spec{iWin}{iGrp} = trapz(R(iEp).SpecGramT(TWindex)./1000,R(iEp).SpecGram{iGrp}(:,TWindex,:).^2,2);
                    dt = (R(iEp).SpecGramT(find(TWindex,1,'last'))/1000-R(iEp).SpecGramT(find(TWindex,1,'first'))/1000);% window width in sec
                    R(iEp).Spec{iWin}{iGrp} = R(iEp).Spec{iWin}{iGrp} ./ dt;
                    R(iEp).Spec{iWin}{iGrp} = permute(R(iEp).Spec{iWin}{iGrp},[1 3 2]);
                    R(iEp).Freq{iWin} = R(iEp).SpecGramF;
                end
            case 'SPECTROGRAM'
                iWin = 1;
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseMainWin,cEv,false);
                nSpecGramWin = round(Par.SpecGramWin/(1/Par.Fs));
                noverlap = nSpecGramWin - round(Par.SpecGramTs/(1/Par.Fs));
                P = [];
                for iTr = 1:nTr
                    [S,f,t,P(:,:,iTr)] = spectrogram(dlfp(:,iTr),hanning(nSpecGramWin),noverlap,Par.SpecGramNfft,Par.Fs);
                end
                R(iEp).SpecGram{iGrp} = P;% 10*log10(P)
                R(iEp).SpecGramF = f;
                R(iEp).SpecGramT = t.*1000+Ep(iEp).AnalyseMainWin(1);
                                
                for iWin = 1:nWin
                    TWindex = R(iEp).SpecGramT>=Ep(iEp).AnalyseWin(iWin,1) & R(iEp).SpecGramT<Ep(iEp).AnalyseWin(iWin,2);
                    R(iEp).Spec{iWin}{iGrp} = agmean(R(iEp).SpecGram{iGrp}(:,TWindex,:),[],2);
                    R(iEp).Spec{iWin}{iGrp} = permute(R(iEp).Spec{iWin}{iGrp},[1 3 2]);
                    R(iEp).Freq{iWin} = R(iEp).SpecGramF;
                end
            case 'CHRONUXSPECGRAM'
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseMainWin,cEv,false);
                [S,t,f] = mtspecgramc(dlfp,[Par.SpecGramWin Par.SpecGramTs],Par);
                
                R(iEp).SpecGram{iGrp} = permute(S,[2 1 3]);% 10*log10(P)
                R(iEp).SpecGramF = f';
                R(iEp).SpecGramT = t.*1000+Ep(iEp).AnalyseMainWin(1);
                
                for iWin = 1:nWin
                    TWindex = R(iEp).SpecGramT>=Ep(iEp).AnalyseWin(iWin,1) & R(iEp).SpecGramT<Ep(iEp).AnalyseWin(iWin,2);
                    R(iEp).Spec{iWin}{iGrp} = agmean(R(iEp).SpecGram{iGrp}(:,TWindex,:),[],2);
                    R(iEp).Spec{iWin}{iGrp} = permute(R(iEp).Spec{iWin}{iGrp},[1 3 2]);
                    R(iEp).Freq{iWin} = R(iEp).SpecGramF;
                end
        end
    end
    
    % reconstruct factor dimensions
    for iWin = 1:nWin
        R(iEp).Spec{iWin} = reshape(R(iEp).Spec{iWin},nLevel);
    end
end

%% filter the spectra
if Par.SpecSmoothFlag
    for iEp = 1:nEp
        nGrp = numel(Ep(iEp).GroupTrialIndex);
        nLevel = size(Ep(iEp).GroupTrialIndex);
        nWin = size(Ep(iEp).AnalyseWin,1);
        for iLoop = 1:[nGrp*nWin]
            [iGrp,iWin] = ind2sub([nGrp nWin],iLoop);
            % R(iEp).Spec{iWin}{iGrp} = sgolayfilt(R(iEp).Spec{iWin}{iGrp},3,41);
            for iTr = 1:size(R(iEp).Spec{iWin}{iGrp},2)
                R(iEp).Spec{iWin}{iGrp}(:,iTr) = smooth(R(iEp).Spec{iWin}{iGrp}(:,iTr),17,'sgolay',3);
            end
        end
    end
end

%% average over trials
for iEp = 1:nEp
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    nWin = size(Ep(iEp).AnalyseWin,1);
    
    for iLoop = 1:[nGrp*nWin]
        [iGrp,iWin] = ind2sub([nGrp nWin],iLoop);
        [nFB,nTr] = size(R(iEp).Spec{iWin}{iGrp});
        
        % calc mean and median
        [R(iEp).SpecM{iWin}(:,iGrp),R(iEp).SpecS{iWin}(:,iGrp),R(iEp).SpecSE{iWin}(:,iGrp)] = agmean(R(iEp).Spec{iWin}{iGrp},[],2);
        [R(iEp).SpecMed{iWin}(:,iGrp),R(iEp).SpecP25{iWin}(:,iGrp),R(iEp).SpecP75{iWin}(:,iGrp)] = agmedian(R(iEp).Spec{iWin}{iGrp},[25 75],2);
        
%         % detect outliers
%         SpecZScore = (R(iEp).Spec{iWin}{iGrp} - repmat(R(iEp).SpecM{iWin}(:,iGrp),[1,nTr])) ./ repmat(R(iEp).SpecSE{iWin}(:,iGrp),[1,nTr]);
%         fprintf(1,'%2.2f %2.2f\n',min(SpecZScore(:)),max(SpecZScore(:)));
    end
    
    % reconstruct factor dimensions
    for iWin = 1:nWin
        R(iEp).SpecM{iWin} = reshape(R(iEp).SpecM{iWin},[size(R(iEp).SpecM{iWin},1) nLevel]);
        R(iEp).SpecS{iWin} = reshape(R(iEp).SpecS{iWin},[size(R(iEp).SpecS{iWin},1) nLevel]);
        R(iEp).SpecSE{iWin} = reshape(R(iEp).SpecSE{iWin},[size(R(iEp).SpecSE{iWin},1) nLevel]);
        R(iEp).SpecMed{iWin} = reshape(R(iEp).SpecMed{iWin},[size(R(iEp).SpecMed{iWin},1) nLevel]);
        R(iEp).SpecP25{iWin} = reshape(R(iEp).SpecP25{iWin},[size(R(iEp).SpecP25{iWin},1) nLevel]);
        R(iEp).SpecP75{iWin} = reshape(R(iEp).SpecP75{iWin},[size(R(iEp).SpecP75{iWin},1) nLevel]);
    end
end

%% COMPUTE: Frequency Bands
nFB = size(Par.FreqBand,1);
for iEp = 1:nEp
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    nWin = size(Ep(iEp).AnalyseWin,1);
    
    % allocate
    for iGrp = 1:nGrp
        R(iEp).FB(iGrp) = struct( ...
            'Tr',{cell(nWin,nFB)}, ...
            'M' ,{zeros(nWin,nFB).*NaN}, ...
            'S' ,{zeros(nWin,nFB).*NaN}, ...
            'SE' ,{zeros(nWin,nFB).*NaN}, ...
            'Med' ,{zeros(nWin,nFB).*NaN}, ...
            'P25' ,{zeros(nWin,nFB).*NaN}, ...
            'P75' ,{zeros(nWin,nFB).*NaN});
    end
    R(iEp).FB = reshape(R(iEp).FB,nLevel);
    
    for iLoop = 1:[nFB*nWin]
        [iFB,iWin] = ind2sub([nFB nWin],iLoop);
        cFBWin = R(iEp).Freq{iWin}>Par.FreqBand(iFB,1) & R(iEp).Freq{iWin}<=Par.FreqBand(iFB,2);
        for iGrp = 1:[nGrp]
            % average power in band
            R(iEp).FB(iGrp).Tr{iWin,iFB} = agmean(R(iEp).Spec{iWin}{iGrp}(cFBWin,:),[],1);
            [R(iEp).FB(iGrp).M(iWin,iFB),R(iEp).FB(iGrp).S(iWin,iFB),R(iEp).FB(iGrp).SE(iWin,iFB)] = agmean(R(iEp).FB(iGrp).Tr{iWin,iFB},[],2);
            [R(iEp).FB(iGrp).Med(iWin,iFB),R(iEp).FB(iGrp).P25(iWin,iFB),R(iEp).FB(iGrp).P75(iWin,iFB)] = agmedian(R(iEp).FB(iGrp).Tr{iWin,iFB},[25 75],2);
        end
    end
end
