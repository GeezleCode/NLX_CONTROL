function R = spk_FA_AnalogSpectrum(s,ChanName,Par,Ep,EpBase)

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
%       SpecZ: {[]  {3x2 cell}}
%      SpecZM: {[]  [144x3x2 double]}
%      SpecZS: {[]  [144x3x2 double]}
%     SpecZSE: {[]  [144x3x2 double]}
%    SpecGram
%            t

R.Set = Par;
R.Ep = Ep;
R.EpBase = EpBase;

%% check file properties
iCh = spk_findAnalog(s,ChanName);

%% check settings
Ep = [EpBase Ep];
nEp = length(Ep);

%% COMPUTE: spectrum
for iEp = 1:nEp
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    for iGrp = 1:nGrp
        
        nTr = length(Ep(iEp).GroupTrialIndex{iGrp});
        fprintf(1,'spk_FA_AnalogSpectrum: Win ''%s'' Grp %1.0f(%1.0f ) - %1.0f trials\n',Ep(iEp).Name,iGrp,nGrp,nTr);
        if isempty(Ep(iEp).GroupTrialIndex{iGrp});continue;end

        % extract the data
        s = spk_set(s,'currenttrials',Ep(iEp).GroupTrialIndex{iGrp},'currentanalog',iCh);
        cEv = spk_getEvents(s,Ep(iEp).GroupAlignEvent{iGrp});
        cEv = round(cat(1,cEv{:}));
        [dlfp,tlfp] = spk_ChronuxGetLFP(s,Ep(iEp).AnalyseWin,cEv,false);
        
        % compute the spectrum
        R.Spec{iEp}{iGrp} = [];
        R.Freq{iEp} = [];
        R.SpecGram{iEp}{iGrp} = [];
        R.t{iEp} = [];
        R.imf{iEp}{iGrp} = {};
        R.imffreq{iEp}{iGrp} = {};
        switch Par.SpecMethod
            case 'FFT'
                [R.Spec{iEp}{iGrp},R.Freq{iEp}] = fftspectrumc(dlfp,Par);
                R.Freq{iEp} = R.Freq{iEp}';
            case 'HANNING FFT'
                [nSpl,nTr] = size(dlfp);
                FFTWin = repmat(hanning(nSpl),[1,nTr]);
                [R.Spec{iEp}{iGrp},R.Freq{iEp}] = fftspectrumc(dlfp.*FFTWin,Par);
                R.Freq{iEp} = R.Freq{iEp}';
            case 'CHRONUX'
                [R.Spec{iEp}{iGrp},R.Freq{iEp}]=mtspectrumc(dlfp,Par);
            case 'HilbertHuang'
                hwait = waitbar(0,sprintf('Hilbert Huang Transform %1.0f of %1.0f trials (Grp# %1.0f of %1.0f)',0,nTr,iGrp,nGrp));
                for iTr = 1:nTr
                    [R.Spec{iEp}{iGrp}(iTr,:),R.SpecGram{iEp}{iGrp}(:,:,iTr),R.t{iEp},R.Freq{iEp},R.imf{iEp}{iGrp}{iTr},R.imffreq{iEp}{iGrp}{iTr}] = HilbertHuangTransform_2(dlfp(:,iTr)',1/Par.Fs,Par.maxIMFiteration,Par.fpass,Par.fbinwidth,Par.SigmaSec,Par.SigmaHz);
                    waitbar(iTr/nTr,hwait,sprintf('Hilbert Huang Transform %1.0f of %1.0f trials (Grp# %1.0f of %1.0f)',iTr,nTr,iGrp,nGrp));
                end
                close (hwait);
                R.Spec{iEp}{iGrp} = R.Spec{iEp}{iGrp}';
                R.Freq{iEp} = R.Freq{iEp}';
        end
        
        % filter the spectrum
        if Par.SpecSmoothFlag
            % R.Spec{iEp}{iGrp} = sgolayfilt(R.Spec{iEp}{iGrp},3,41);
            for k=1:size(R.Spec{iEp}{iGrp},2)
                R.Spec{iEp}{iGrp}(:,k) = smooth(R.Spec{iEp}{iGrp}(:,k),17,'sgolay',3);
            end
        end
        
        [R.SpecM{iEp}(:,iGrp),R.SpecS{iEp}(:,iGrp),R.SpecSE{iEp}(:,iGrp)] = agmean(R.Spec{iEp}{iGrp},[],2);
    end
    R.Spec{iEp} = reshape(R.Spec{iEp},nLevel);
    R.SpecM{iEp} = reshape(R.SpecM{iEp},[size(R.SpecM{iEp},1) nLevel]);
    R.SpecS{iEp} = reshape(R.SpecS{iEp},[size(R.SpecS{iEp},1) nLevel]);
    R.SpecSE{iEp} = reshape(R.SpecSE{iEp},[size(R.SpecSE{iEp},1) nLevel]);
end

%% COMPUTE: stimulus induced spectrum (Z-Score spectrum)
if ~isempty(EpBase)
    nBaseGrp = numel(EpBase.GroupTrialIndex);
    nBaseFac = ndims(EpBase.GroupTrialIndex);
    nBaseLevel = size(EpBase.GroupTrialIndex);
    
    for iEp = 2:nEp
        nGrp = numel(Ep(iEp).GroupTrialIndex);
        nFac = ndims(Ep(iEp).GroupTrialIndex);
        nLevel = size(Ep(iEp).GroupTrialIndex);
        
        % check grouping
        if nFac<nBaseFac || any(~ismember(EpBase.GroupFactor,Ep(iEp).GroupFactor))
            error('Cannot process the present grouping of baseline epoch!');
        end
        
        for iGrp = 1:nGrp
            % find the correct base group by matching trial indices
            for iBaseGrp = 1:nBaseGrp
                if all(ismember(Ep(iEp).GroupTrialIndex{iGrp},EpBase.GroupTrialIndex{iBaseGrp}))
                    break;
                elseif (iBaseGrp == nBaseGrp)
                    error('Cannot find matching group indices!');
                end
            end
            
            [nFreq,nTr] = size(R.Spec{iEp}{iGrp});
            
            switch Par.SpecNormMode
                case 'Z'
                    R.SpecZ{iEp}{iGrp} = (R.Spec{iEp}{iGrp} - repmat(R.SpecM{1}(:,iBaseGrp),[1 nTr])) ./ repmat(R.SpecS{1}(:,iBaseGrp),[1 nTr]);
                case 'DIFF'
                    R.SpecZ{iEp}{iGrp} = (R.Spec{iEp}{iGrp} - repmat(R.SpecM{1}(:,iBaseGrp),[1 nTr]));
                case 'RATIO'
                    R.SpecZ{iEp}{iGrp} = (R.Spec{iEp}{iGrp} ./ repmat(R.SpecM{1}(:,iBaseGrp),[1 nTr]));
                otherwise
                    R.SpecZ{iEp}{iGrp} = R.Spec{iEp}{iGrp};
            end
            [R.SpecZM{iEp}(:,iGrp),R.SpecZS{iEp}(:,iGrp),R.SpecZSE{iEp}(:,iGrp)] = agmean(R.SpecZ{iEp}{iGrp},[],2);
        end
        R.SpecZ{iEp} = reshape(R.SpecZ{iEp},[ nLevel]);
        R.SpecZM{iEp} = reshape(R.SpecZM{iEp},[size(R.SpecZM{iEp},1) nLevel]);
        R.SpecZS{iEp} = reshape(R.SpecZS{iEp},[size(R.SpecZS{iEp},1) nLevel]);
        R.SpecZSE{iEp} = reshape(R.SpecZSE{iEp},[size(R.SpecZSE{iEp},1) nLevel]);
    end
elseif isempty(Pdm.Base.WinName)&&~isempty(Pdm.Base.GroupNr)
end

%% COMPUTE: Frequency Bands
nFB = size(Par.FreqBand,1);
for iLoop = 1:[nFB*2]
    [iFB iEp] = ind2sub([nFB 2],iLoop);
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    R.FB(iEp,iFB).Tr = cell(nLevel);
    R.FB(iEp,iFB).M = zeros(nLevel).*NaN;
    R.FB(iEp,iFB).S = zeros(nLevel).*NaN;
    R.FB(iEp,iFB).SE = zeros(nLevel).*NaN;
    R.FB(iEp,iFB).Med = zeros(nLevel).*NaN;
    R.FB(iEp,iFB).P25 = zeros(nLevel).*NaN;
    R.FB(iEp,iFB).P75 = zeros(nLevel).*NaN;
    cFBWin = R.Freq{iEp}>=Par.FreqBand(iFB,1) & R.Freq{iEp}<Par.FreqBand(iFB,2);
    for iGrp = 1:nGrp
        [nf,nTr] = size(R.Spec{iEp}{iGrp});
        R.FB(iEp,iFB).Tr{iGrp} = agmean(R.Spec{iEp}{iGrp}(cFBWin,:),[],1);
        [R.FB(iEp,iFB).M(iGrp),R.FB(iEp,iFB).S(iGrp),R.FB(iEp,iFB).SE(iGrp)] = agmean(R.FB(iEp,iFB).Tr{iGrp},[],2);
        [R.FB(iEp,iFB).Med(iGrp),pppprct] = agmedian(R.FB(iEp,iFB).Tr{iGrp}',[25 75]);
        R.FB(iEp,iFB).P25(iGrp) = pppprct(1);
        R.FB(iEp,iFB).P75(iGrp) = pppprct(2);
    end
end

iEp = 2;
iEpBase = 1;
for iFB = 1:nFB
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    R.FBz(iEp,iFB).Tr = cell(nLevel);
    R.FBz(iEp,iFB).M = zeros(nLevel).*NaN;
    R.FBz(iEp,iFB).S = zeros(nLevel).*NaN;
    R.FBz(iEp,iFB).SE = zeros(nLevel).*NaN;
    R.FBz(iEp,iFB).Med = zeros(nLevel).*NaN;
    R.FBz(iEp,iFB).P25 = zeros(nLevel).*NaN;
    R.FBz(iEp,iFB).P75 = zeros(nLevel).*NaN;
    for iGrp = 1:nGrp
        % find the correct base group by matching trial indices
        for iBaseGrp = 1:nBaseGrp
            if all(ismember(Ep(iEp).GroupTrialIndex{iGrp},Ep(iEpBase).GroupTrialIndex{iBaseGrp}))
                break;
            elseif (iBaseGrp == nBaseGrp)
                error('Cannot find matching group indices!');
            end
        end
        R.FBz(iEp,iFB).Tr{iGrp} = (R.FB(iEp,iFB).Tr{iGrp}-R.FB(iEpBase,iFB).M(iBaseGrp))./R.FB(iEpBase,iFB).S(iBaseGrp);
        [R.FBz(iEp,iFB).M(iGrp),R.FBz(iEp,iFB).S(iGrp),R.FBz(iEp,iFB).SE(iGrp)] = agmean(R.FBz(iEp,iFB).Tr{iGrp},[],2);
        [R.FBz(iEp,iFB).Med(iGrp),pppprct] = agmedian(R.FBz(iEp,iFB).Tr{iGrp}',[25 75]);
        R.FBz(iEp,iFB).P25(iGrp) = pppprct(1);
        R.FBz(iEp,iFB).P75(iGrp) = pppprct(1);
    end
end
        
