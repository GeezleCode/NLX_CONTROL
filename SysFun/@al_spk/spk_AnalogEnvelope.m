function [s,PosEnv,NegEnv,MeanEnv] = spk_AnalogEnvelope(s,EnvOption,ChanName)

% computes envelope of an analog signal

%% get the channel index
if nargin<3 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_FindAnalog(s,ChanName);
end
nChan = length(iChan);

[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(currenttrials);

%% loop channels
for iCh = 1:nChan
    [nTrTotal,nBins] = size(s.analog{iChan(iCh)});
    
    PosEnv{iCh} = zeros(nTr,nBins).*NaN;
    NegEnv{iCh} = zeros(nTr,nBins).*NaN;
    MeanEnv{iCh} = zeros(nTr,nBins).*NaN;
    
    for iTr = 1:nTr 
        PosEnv{iCh}(iTr,:) = getspline(s.analog{iChan(iCh)}(currenttrials(iTr),:)); 
        NegEnv{iCh}(iTr,:) = -getspline(s.analog{iChan(iCh)}(currenttrials(iTr),:)); 
        MeanEnv{iCh}(iTr,:) = nanmean([PosEnv{iCh}(iTr,:);NegEnv{iCh}(iTr,:)]);
    end
    
    switch EnvOption
        case 'POS'
            s.analog{iChan(iCh)}(currenttrials,:) = PosEnv{iCh};
        case 'NEG'
            s.analog{iChan(iCh)}(currenttrials,:) = NegEnv{iCh};
        case 'MEAN'
            s.analog{iChan(iCh)}(currenttrials,:) = MeanEnv{iCh};
    end
end

function s = getspline(x)

N = length(x);
p = findpeaks(x);
s = spline([0 p N+1],[0 x(p) 0],1:N);

function n = findpeaks(x)
% Find peaks.
% n = findpeaks(x)

n    = find(diff(diff(x) > 0) < 0);
u    = find(x(n+1) > x(n));
n(u) = n(u)+1;