function C = spk_AnalogSpectrogram(s,ChanName,TimeWin,SpecMethod,varargin)

% computes the Hilbert-Huang Transform for selected analog channels/trials
%  C = spk_AnalogSpectrogram(s,ChanName,TimeWin ...)
% ChanName ... char or cell array with channel names (s.analogname)
% TimeWin .... {EventLabel TimeWin/Eventlabel nPoints} 
%              e.g {'NLX_STIM_ON' [0 500] [512]}
%                  {'NLX_STIM_ON' 'NLX_STIM_OFF' [512]}
%                  {[] [0 500] [512]}
%                  or []
%
% Hilbert-Huang Transformation
% C = spk_AnalogSpectrogram(s,ChanName,TimeWin,'HHT',FreqBandPass,FreqBinWidth,maxIMFiteration)
%
% Matlab Spectrogram (spectrogram.m)
% C = spk_AnalogSpectrogram(s,ChanName,TimeWin,'SPECTROGRAM',window,noverlap,Nfft)
%
% Chronux Spectrogram (mtspecgramc.m)
% C = spk_AnalogSpectrogram(s,ChanName,TimeWin,'CHRONUX',tapers,pad,fpass,err,trialave,movingwin)

%% default input
if nargin<5
    maxIMFiteration  = inf;
    if nargin<4
        FreqBinWidth = 1;
        if nargin<3
            FreqBandPass = [0 250];
            if nargin<2
                ChanName = [];
            end;end;end;end

%% get trial numbers
nTrTotal = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTrTotal;
end
nTr = length(s.currenttrials);

%% get analog channel
if nargin>=2 && ~isempty(ChanName)
    s.currentanalog = spk_findAnalog(s,ChanName);
end
if isempty(s.currentanalog)
    error('spk_AnalogHHT: No analog channel selected!');
end
nCh = length(s.currentanalog);

%% get time windows
if isempty(TimeWin)
    BinWin = [];
elseif isempty(TimeWin{1}) && ~isnumeric(TimeWin{2})
    [BinWin] = spk_AnalogEventWindow(s,0,TimeWin{2});
elseif ischar(TimeWin{1}) && ~isempty(TimeWin{2})
    [BinWin] = spk_AnalogEventWindow(s,TimeWin{1},TimeWin{2});
end

% create an n-point time window
if length(TimeWin)==3 && ~isempty(TimeWin{3}) && TimeWin{3}>0
    BinWin(:,2,:) = BinWin(:,1,:)+TimeWin{3}-1;
end

%%
[iAlignEvent,AlignEvent] = spk_getAlignEvent(s);

%% loop channels and trials
hwait = waitbar(0,'');set(get(get(hwait,'children'),'title'),'interpreter','none');
for iCh = 1:nCh
    cCh = s.currentanalog(iCh);
    Tn = size(s.analog{cCh},2);
    Ts = 1/s.analogfreq(cCh);
    Ti = 0-(s.analogalignbin(cCh)-1)*Ts : Ts : (Tn-s.analogalignbin(cCh))*Ts;
    
    C(iCh).Name = s.analogname{cCh};
    C(iCh).SpecMethod = SpecMethod;
    C(iCh).Ts = Ts;
    C(iCh).T = Ti;
    C(iCh).idx = false(nTr,Tn);
    C(iCh).iTr = s.currenttrials;
    C(iCh).AlignEvent = AlignEvent;
    
    C(iCh).SpecS = cell(1,nTr);% time-frequency spectrogram
    C(iCh).SpecT = cell(1,nTr);% time bin centres for plotting
    C(iCh).SpecF = cell(1,nTr);% frequency bin centres for plotting
    
    % spec method specific stuff
    switch upper(SpecMethod)
        case 'HHT'
            C(iCh).Par.FreqBandPass = varargin{1};
            C(iCh).Par.FreqBinWidth = varargin{2};
            C(iCh).Par.maxIMFiteration = varargin{3};
            C(iCh).Par.SaveIMF = varargin{4};
            
            if C(iCh).Par.SaveIMF
                C(iCh).imf = cell(1,nTr);
                C(iCh).imfAmp = cell(1,nTr);
                C(iCh).imfF = cell(1,nTr);
                C(iCh).imfT = cell(1,nTr);
            end

        case 'SPECTROGRAM'
            C(iCh).Par.window = varargin{1};%hanning(nSpecGramWin);
            C(iCh).Par.noverlap = varargin{2};
            C(iCh).Par.Nfft = varargin{3};
            C(iCh).Par.fpass = varargin{4};
            
        case 'CHRONUX'
            C(iCh).Par.Fs = 1/C(iCh).Ts;
            C(iCh).Par.tapers = varargin{1};
            C(iCh).Par.pad = varargin{2};
            C(iCh).Par.fpass = varargin{3};
            C(iCh).Par.err = varargin{4};
            C(iCh).Par.trialave = varargin{5};
            C(iCh).Par.movingwin = varargin{6};
    end     
    
    % loop trials and compute
    for iTr = 1:nTr
        waitbar(((iCh-1)*nTr+iTr-1)/(nCh*nTr),hwait,sprintf('%s: Trial %1.0f(%1.0f) Chan %1.0f(%1.0f)',SpecMethod,iTr,nTr,iCh,nCh));
        cTr = s.currenttrials(iTr);
        x = s.analog{cCh}(cTr,:);
        if isempty(BinWin)
            C(iCh).idx(iTr,:) = ~isnan(x);
        else
            C(iCh).idx(iTr,BinWin(iTr,1,iCh):BinWin(iTr,2,iCh)) = true;
        end
        cT = Ti(C(iCh).idx(iTr,:));
        
        switch upper(SpecMethod)
            case 'HHT'
                C(iCh).imfT{iTr} = Ti(C(iCh).idx(iTr,:));
                if C(iCh).Par.SaveIMF
                    [C(iCh).SpecS{iTr}, C(iCh).SpecT{iTr}, C(iCh).SpecF{iTr}, C(iCh).imf{iTr}, C(iCh).imfAmp{iTr}, C(iCh).imfF{iTr}] = HilbertHuangSpectrogram(x(C(iCh).idx(iTr,:)), ...
                        C(iCh).Ts,C(iCh).Par.maxIMFiteration,C(iCh).Par.FreqBandPass,C(iCh).Par.FreqBinWidth);
                else
                    [C(iCh).SpecS{iTr}, C(iCh).SpecT{iTr}, C(iCh).SpecF{iTr}] = HilbertHuangSpectrogram(x(C(iCh).idx(iTr,:)), ...
                        C(iCh).Ts,C(iCh).Par.maxIMFiteration,C(iCh).Par.FreqBandPass,C(iCh).Par.FreqBinWidth);
                end
                C(iCh).SpecT{iTr} = C(iCh).SpecT{iTr} + cT(1);
            case 'SPECTROGRAM'
                [S,C(iCh).SpecF{iTr},C(iCh).SpecT{iTr},C(iCh).SpecS{iTr}] = spectrogram(x(C(iCh).idx(iTr,:))', ...
                    C(iCh).Par.window,C(iCh).Par.noverlap,C(iCh).Par.Nfft,1/C(iCh).Ts);
                C(iCh).SpecT{iTr} = C(iCh).SpecT{iTr} + cT(1);
                iFrq = C(iCh).SpecF{iTr}>=C(iCh).Par.fpass(1) & C(iCh).SpecF{iTr}<=C(iCh).Par.fpass(2);
                C(iCh).SpecF{iTr} = C(iCh).SpecF{iTr}(iFrq);
                C(iCh).SpecS{iTr} = C(iCh).SpecS{iTr}(iFrq,:);
            case 'CHRONUX'
                [C(iCh).SpecS{iTr},C(iCh).SpecT{iTr},C(iCh).SpecF{iTr}] = mtspecgramc(x(C(iCh).idx(iTr,:))',C(iCh).Par.movingwin,C(iCh).Par);
                C(iCh).SpecS{iTr} = C(iCh).SpecS{iTr}';
                C(iCh).SpecT{iTr} = C(iCh).SpecT{iTr} + cT(1);
        end
        C(iCh).SpecT{iTr} = C(iCh).SpecT{iTr}(:);
        C(iCh).SpecF{iTr} = C(iCh).SpecF{iTr}(:);

        
        
        waitbar(((iCh-1)*nTr+iTr)/(nCh*nTr),hwait,sprintf('%s: Trial %1.0f(%1.0f) Chan %1.0f(%1.0f)',SpecMethod,iTr,nTr,iCh,nCh));
    end
    
    
end
close(hwait);

