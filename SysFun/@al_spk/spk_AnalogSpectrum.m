function R = spk_AnalogSpectrum(s,TimeWin,Event,Method,Set,ChanName)

% performs spectral analysis of analog data
% R = spk_AnalogSpectrum(s,TimeWin,Event,Method,Set,ChanName)
%
% TimeWin .... time window
% Event ...... reference event
% Method ..... character , see below
% Set ........ settings structure, see below
% ChanName ... analog channel name
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
% R = 
% 
%        Method: 'HANNING FFT'
%           Set: [1x1 struct]
%          Spec: {[102x296 double]}
%          Freq: [102x1 double]
%      SpecGram: {[]}
%     SpecGramF: []
%     SpecGramT: []
%         SpecM: [102x1 double]
%         SpecS: [102x1 double]
%        SpecSE: [102x1 double]
%       SpecMed: [102x1 double]
%       SpecP25: [102x1 double]
%       SpecP75: [102x1 double]
%            FB: [1x1 struct]
% 

%%
if nargin<5
    Set = [];
end

default.SpecSmoothFlag = false;
default.FreqBand = [];
default.MapImageResizeFactor = 5;
default.MapImageResizeInterpolation = 'bilinear'; % nearest bilinear bicubic
default.MapImageResizeFilterOrder = 3;

%% get channels to analyse
if nargin<6||isempty(ChanName)
    ChNr = s.currentanalog;
elseif iscell(ChanName)||ischar(ChanName)
    ChNr = spk_findAnalog(s,ChanName);
elseif isnumeric(ChanName)
    ChNr = ChanName;
end
nCh = length(ChNr);
    
%% get trial groups
[TrGrp,s] = spk_CheckCurrentTrials(s,true);
if isnumeric(TrGrp)
    TrGrp = {TrGrp};
end
nTrGrps = numel(TrGrp);

% tWin = spk_getEventWindow(s,Event,TimeWin);

for iCh = 1:nCh        
    R(iCh).Method = Method;
    R(iCh).Set = [];% will be set in the methods
    R(iCh).Spec = cell(1,nTrGrps);
    R(iCh).Freq = [];
    R(iCh).SpecGram = cell(1,nTrGrps);
    R(iCh).SpecGramF = [];
    R(iCh).SpecGramT = [];
%     R(iCh).imf = cell(1,nGrp);
%     R(iCh).imffreq = cell(1,nGrp);
    
    for iGrp = 1:nTrGrps
        if isempty(TrGrp{iGrp});continue;end
        s = spk_set(s,'currenttrials',TrGrp{iGrp},'currentanalog',ChNr(iCh));
        
%         tWin = spk_getEventWindow(s,Event,TimeWin);
        
        switch Method
            case 'FFT'
                default.Fs = spk_getAnalogFs(s);
                default.N  = [];
                default.fres = 1;
                default.fpass  = [0 200];
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,false);
                [R(iCh).Spec{iGrp},R(iCh).Freq] = fftspectrumc(dlfp,Set.Fs,Set.N,Set.fres,Set.fpass);
                R(iCh).Freq = R(iCh).Freq(:);
            
            case 'HANNING FFT'
                default.Fs = spk_getAnalogFs(s);
                default.N  = [];
                default.fres = 1;
                default.fpass  = [0 200];
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,false);
                [nSpl,nTr] = size(dlfp);
                FFTWin = repmat(hanning(nSpl),[1,nTr]);
                [R(iCh).Spec{iGrp},R(iCh).Freq] = fftspectrumc(dlfp.*FFTWin,Set.Fs,Set.N,Set.fres,Set.fpass);
                R(iCh).Freq = R(iCh).Freq(:);
            
            case 'PMTM'
                default.dpss = 2;% scalar: time-bandwith-product cell: input for dpss.m
                default.f = 512;% can be NFFT or vector of frequencies
                default.Fs = spk_getAnalogFs(s);
                default.p = 0.95;
                default.DropLastTaper = true;
                default.method = 'adapt'; 
                default.range = 'onesided';
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,false);
                [nSpl,nTr] = size(dlfp);
                
                for iTr = 1:nTr
                    [R(iCh).Spec{iGrp}(:,iTr),Conf,R(iCh).Freq] = pmtm(dlfp(:,iTr), ...
                        Set.dpss,Set.f,Set.Fs, ...
                        Set.method,Set.range,'DropLastTaper',Set.DropLastTaper);
                end
                
            case 'CHRONUX'
                default.tapers = [2 3];
                default.pad = 1;
                default.Fs = spk_getAnalogFs(s);
                default.fpass = [0 200];
                default.err = 0;
                default.trialave = 0;
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                
                R(iCh).Spec{iGrp} = [];
                R(iCh).Freq = [];
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,false);
                [R(iCh).Spec{iGrp},R(iCh).Freq]=mtspectrumc(dlfp,Set);
                R(iCh).Freq = R(iCh).Freq(:);
            
            case 'HilbertHuang'
                default.Fs = spk_getAnalogFs(s);
                default.maxIMFiteration = inf;
                default.fpass = [0 200];
                default.fbinwidth = 1;
                default.SigmaSec = 0.025;
                default.SigmaHz = 1;
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,false);
                [nSpl,nTr] = size(dlfp);
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
                default.Fs = spk_getAnalogFs(s);
                default.SpecGramNfft = 512;% can be NFFT or vector of frequencies
                default.SpecGramWin = 0.5;
                default.SpecGramTs = 0.01;
                default.fpass  = [0 200];
                Set = StructUpdate(default,Set);
                R(iCh).Set = Set;
                
                nSpecGramWin = round(Set.SpecGramWin/(1/Set.Fs));
                noverlap = nSpecGramWin - round(Set.SpecGramTs/(1/Set.Fs));
                cTW = TimeWin + [-1 1].*(ceil(nSpecGramWin/2)).*(1/Set.Fs).*(1/(10^s.timeorder));
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,cTW,Event,false);
                [nSpl,nTr] = size(dlfp);
%                 if CompleteWinFlag
%                     dt = diff(tWin(:,:,iCh),[],2);
%                     db = diff(bWin(:,:,iCh),[],2) .* bwidth(iCh);
%                     dis = abs(dt-db) .* (10^(s.timeorder+3));% convert to ms
%                     cbw = bwidth(iCh) .* (10^(s.timeorder+3));
%                     if any(round(dis)>round(cbw))
%                         error('Not enough analog data in given time window!');
%                     end
%                 end
                
                P = [];
                for iTr = 1:nTr
                    [S,f,t,P(:,:,iTr)] = spectrogram(dlfp(:,iTr),hanning(nSpecGramWin),noverlap,Set.SpecGramNfft,Set.Fs);
                end
                findex = f>=Set.fpass(1) & f<=Set.fpass(2);
                f = f(findex);
                P = P(findex,:,:);
                R(iCh).SpecGram{iGrp} = P;% 10*log10(P)
                R(iCh).SpecGramF = f;
                R(iCh).SpecGramT = t./(10^s.timeorder)+cTW(1);
                                
                TWindex = R(iCh).SpecGramT>=TimeWin(1) & R(iCh).SpecGramT<TimeWin(2);
                R(iCh).Spec{iGrp} = agmean(R(iCh).SpecGram{iGrp}(:,TWindex,:),[],2);
                R(iCh).Spec{iGrp} = permute(R(iCh).Spec{iGrp},[1 3 2]);
                R(iCh).Freq = R(iCh).SpecGramF;
            
            case 'CHRONUXSPECGRAM'
                default.tapers = [5 9];
                default.pad = 1;
                default.Fs = [];
                default.fpass = [0 200];
                default.err = 0;
                default.trialave = 0;
                default.SpecGramWin = 0.5;
                default.SpecGramTs = 0.01;
                default.movingwin = [];
                Set = StructUpdate(default,Set);
                if isempty(Set.movingwin);Set.movingwin = [Set.SpecGramWin Set.SpecGramTs];end % do it this way to keep Set structure similar to "Spectrogram"
                R(iCh).Set = Set;
        
                % expand the time window for mtspecgramc
                cTW = TimeWin + [-0.5 1.5].*(Set.SpecGramWin/(10^s.timeorder));
                [dlfp,tlfp] = spk_ChronuxGetLFP(s,cTW,Event,false);
                [nSpl,nTr] = size(dlfp);
                
                [S,t,f] = mtspecgramc(dlfp,[Set.SpecGramWin Set.SpecGramTs],Set);
                
                R(iCh).SpecGram{iGrp} = permute(S,[2 1 3]);% 10*log10(P)
                R(iCh).SpecGramF = f';
                R(iCh).SpecGramT = t./(10^s.timeorder)+cTW(1);
                
                TWindex = R(iCh).SpecGramT>=TimeWin(1,1) & R(iCh).SpecGramT<TimeWin(1,2);
                R(iCh).Spec{iGrp} = agmean(R(iCh).SpecGram{iGrp}(:,TWindex,:),[],2);
                R(iCh).Spec{iGrp} = permute(R(iCh).Spec{iGrp},[1 3 2]);
                R(iCh).Freq = R(iCh).SpecGramF;
            
            otherwise
                error('Don''t know spectral method "%s" !!!',Method);
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
    nTr = cellfun('length',TrGrp);
    
    for iGrp = 1:nGrp
        
        % calc mean and median
        if nTr(iGrp)>0 && ~isempty(R(iCh).Spec{iGrp}) && ~all(isnan(R(iCh).Spec{iGrp}(:)))
            [R(iCh).SpecM(:,iGrp),R(iCh).SpecS(:,iGrp),R(iCh).SpecSE(:,iGrp)] = agmean(R(iCh).Spec{iGrp},[],2);
            [R(iCh).SpecMed(:,iGrp),R(iCh).SpecP25(:,iGrp),R(iCh).SpecP75(:,iGrp)] = agmedian(R(iCh).Spec{iGrp},[25 75],2);
        else
            R(iCh).SpecM(:,iGrp) = 0;
            R(iCh).SpecS(:,iGrp) =  0;
            R(iCh).SpecSE(:,iGrp) =  0;
            R(iCh).SpecMed(:,iGrp) =  0;
            R(iCh).SpecP25(:,iGrp) =  0;
            R(iCh).SpecP75(:,iGrp) =  0;
        end
        
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
    nTr = cellfun('length',TrGrp);
    
    for iFB = 1:nFB
        FB = struct;
        FB.Tr = cell(nLevel);
        FB.M = zeros(nLevel).*NaN;
        FB.S = zeros(nLevel).*NaN;
        FB.SE = zeros(nLevel).*NaN;
        FB.Med = zeros(nLevel).*NaN;
        FB.P25 = zeros(nLevel).*NaN;
        FB.P75 = zeros(nLevel).*NaN;
    
        cFBWin = R(iCh).Freq>Set.FreqBand(iFB,1) & R(iCh).Freq<=Set.FreqBand(iFB,2);
        for iGrp = 1:[nGrp]
            nTr = size(R(iCh).Spec{iGrp},2);
            if nTr>0
                % average power in band
                FB.Tr{iGrp} = agmean(R(iCh).Spec{iGrp}(cFBWin,:),[],1);
                [FB.M(iGrp),FB.S(iGrp),FB.SE(iGrp)] = agmean(FB.Tr{iGrp},[],2);
                [FB.Med(iGrp),FB.P25(iGrp),FB.P75(iGrp)] = agmedian(FB.Tr{iGrp},[25 75],2);
            end
        end
        R(iCh).FB(iFB) = FB;
    end
end
