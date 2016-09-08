function [Y,F,TrialCode,Par] = spk_AnaSpec(s,Method,Par,Win,GroupTerm)

% calculates a power spectrum of single trials
% s.currentanalog needs to be set
% 
%
% IN:
% Method ...... 'Chronux','FFT',
% Par ......... structure, depends on method
% Win ......... boundaries [lo hi], requires alignment
% GroupTerm ... char: a trialcode label.
%               omitted: s.currenttrials needs to be set.
%               [] or '': all trials are calculated
% OUT:

%% prepare stuff
nTrTot = spk_numtrials(s);
iAna = s.currentanalog;
Fs = s.analogfreq(iAna);
WinBin = round(Win/(1/Fs/(10^s.timeorder)));

%% default parameter
switch Method
    case 'Chronux'
        DefPars.tapers = [4 7];
        DefPars.pad = 0;
        DefPars.Fs = Fs;
        DefPars.fpass = [0 Fs/2];
        DefPars.err = 0;
        DefPars.trialave = 0;
    case 'FFT'
        DefPars.Fres = [];
        DefPars.Npoints = 512;
        DefPars.fpass = [0 Fs/2];
        DefPars.WinFun = '';
        DefPars.WinOpt = [];
end

%% update parameter
if isempty(Par);
    Par=DefPars;
else
    ParFields = fieldnames(Par);
    DefParsFields = fieldnames(DefPars);
    FieldsToSet = find(~ismember(DefParsFields,ParFields));
    for iFld = 1:length(FieldsToSet)
        Par = setfield(Par,DefParsFields{FieldsToSet(iFld)},getfield(DefPars,DefParsFields{FieldsToSet(iFld)}));
    end
end

%% get trial groups
if nargin<5
    TrialNr{1} = s.currenttrials;
    TrialCode = NaN;
elseif isempty(GroupTerm)
    TrialNr{1} = 1:nTrTot;
    TrialCode = -1;
else
    [TrialNr,TrialCode] = spk_GroupTrials(s,GroupTerm);
end
nTrGrp = length(TrialNr);
nGrpTrials = cellfun('length',TrialNr);

%% loop trialgroups
for iTrGrp=1:nTrGrp
    
    %% extract the data
    DATA = s.analog{iAna}(TrialNr{iTrGrp},:);% select trials
    DATA = DATA(:,s.analogalignbin(iAna)+WinBin(1):s.analogalignbin(iAna)+WinBin(2));%select bins
    DATA = DATA';
    if any(isnan(DATA(:)))
        warning('Found NaN in data!');
    end
    [nBins,nTrials] = size(DATA);

    %% compute spectrum
    switch Method
        case 'Chronux'
            for iTr=1:nTrials
                if Par.err==0
                    [Y(1,iTrGrp).Power(:,iTr),F]=mtspectrumc(DATA(:,iTr),Par);
                else
                    [Y(1,iTrGrp).Power(:,iTr),F,Y(1,iTrGrp).Err(:,:,iTr)]=mtspectrumc(DATA(:,iTr),Par);
                end
            end
        case 'FFT'
            if ~isempty(DefPars.WinFun)
                WinVec = ones(nBins,nTrials);
                if ~isempty(Par.WinOpt)
                    eval(['WinVec = window(@' Par.WinFun  sprintf(',%1.0f',nBins) ',Par.WinOpt);']);
                else
                    eval(['WinVec = window(@' Par.WinFun  sprintf(',%1.0f',nBins) ');']);
                end
                DATA = DATA.*repmat(WinVec,[1,nTrials]);
            end
                
            % calc points/fftr resolution
            if isempty(Par.Npoints) & ~isempty(Par.Fres)
                Par.Npoints = Fs/Par.Fres;
            elseif ~isempty(Par.Npoints)
                Par.Fres = Fs/Par.Npoints;
            end
            % do fft
            y = fft(DATA,round(Par.Npoints),1);
            % calc frequency and power
            Y(1,iTrGrp).Power = y.* conj(y) / round(Par.Npoints);
            Y(1,iTrGrp).Power = Y(1,iTrGrp).Power(1:round(Par.Npoints/2)+1,:);
            F = Fs*(0:round(Par.Npoints/2))/round(Par.Npoints);
            F = F';
            % restrict to pass band
            Fi = (F>=Par.fpass(1)&F<=Par.fpass(2));
            Y(1,iTrGrp).Power(~Fi,:) = [];
            F(~Fi) = [];
    end
end


