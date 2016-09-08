function varargout = spk_SpikeDensity(s,sigma,win,HalfGaussMode)

% Calculates the Spike Density Function over trials listed in s.currenttrials
% Time resolution 1 ms
%
% ... = spk_SpikeDensity(s,sigma,win)
% sigma ... width of gaussian
% win  .... is a two element vector giving the time boundaries of the histogram
%
%
% [mDens,bins,Err,trDens,h] = spk_SpikeDensity( ... )
% Output for non grouped trial selection.
% mDens is density in hertz, bins is time, ...
%
% D = spk_SpikeDensity( ... )
% Output of structure D for grouped trial selection.

h = [];
alpha = 0.05; % for confidence interval

NumCurrChan = length(spk_CheckCurrentChannels(s,0));

%% check trialnumber
if iscell(s.currenttrials)
    TrialGroup = size(s.currenttrials);
    TrialGroupIndex = s.currenttrials;
    TrialGroupFlag = true;
    varargout = cell(1,5);
elseif isnumeric(s.currenttrials)
    TrialGroup = 1;
    TrialGroupIndex = [];
    TrialGroupFlag = false;
    varargout = cell(1,1);
end

%% prepare gaussian filter
% time
smoothwin      = -3*sigma:3*sigma;
smoothwinwidth = abs(diff([smoothwin(1) smoothwin(end)]));

% check time win
if length(win(:))>2
    error('Time window must be [start end]. al_spk must be aligned.');
end
timewin         = win(1):win(2);
bins      = timewin;

nBinSmoothWin = length(smoothwin);
nBinTimeBin = length(timewin);

%gaussians = exp(-(smoothwin/(2.*sigma)).^2)'; 
% is this an error ?????!!!!! rather:
gaussians = exp(-(smoothwin.^2/(2.*sigma.^2)))';

% cut gaussian in half
if HalfGaussMode
    gaussians(smoothwin<0) = 0;
end

% normalise area under the gaussian to 1
gaussians = gaussians/sum(gaussians);

% if isempty(win) | nBinSmoothWin*3>nBinTimeBin
%      warning('Please increase time window or decrease smoothwindow !');
%      mDens = NaN;
%      bins = NaN;
%      Err.S = NaN;
%      trDens = NaN;
%      h = NaN;
%      return;
% end



for cTrGrp = 1:prod(TrialGroup)
    if TrialGroupFlag
        s.currenttrials = TrialGroupIndex{cTrGrp};
    end
    nTr = length(s.currenttrials);
    
    D(cTrGrp).mean = zeros(NumCurrChan,length(timewin)).*NaN;
    D(cTrGrp).V = zeros(NumCurrChan,length(timewin)).*NaN;
    D(cTrGrp).S = zeros(NumCurrChan,length(timewin)).*NaN;
    D(cTrGrp).SE = zeros(NumCurrChan,length(timewin)).*NaN;
    D(cTrGrp).CI = zeros(NumCurrChan,length(timewin)).*NaN;
    D(cTrGrp).trial = zeros(NumCurrChan,length(timewin),nTr).*NaN;
    D(cTrGrp).time = timewin;
        
    if nTr==0;continue;end
    for cChNr = s.currentchan
        iCh = find(s.currentchan==cChNr);
 
        %% get spikes
        spkmat = zeros(nBinTimeBin,nTr);
        i=0;
        for trial = s.currenttrials
            i  = i+1;
            if ~isempty(s.spk{cChNr,trial})
                currSpkTimes = ceil(s.spk{cChNr,trial}.*(10^s.timeorder)./(10^(-3)));%round milliseconds
                currSpkTimes = currSpkTimes(currSpkTimes>=win(1)&currSpkTimes<=win(2));% excise spikes outside window
                spkmat(currSpkTimes-win(1)+1,i) = 1;% times as index in spkmat
            end
        end
    
        %% filter with gaussian
        spkmat = cat(1,zeros(nBinSmoothWin*3,nTr),spkmat,zeros(nBinSmoothWin*3,nTr));% append zeros
        smooth = filtfilt(gaussians,1,spkmat);
        smooth = smooth(nBinSmoothWin*3+1:size(smooth,1)-nBinSmoothWin*3,:);% cut zeros
        smooth = smooth'.*1000;% convert to spikes/sec
    
        % safetime = find(timewin>timewin(1)+smoothwinwidth & timewin<timewin(end)-smoothwinwidth);
        % if isempty(safetime);error('Can not calculate density !');end
        % timewin = timewin(safetime);
        % smooth = smooth(safetime,:);
    
        %% OUTPUT
        D(cTrGrp).mean(iCh,:) = sum(smooth,1)./nTr;
    
        %% Determine standard deviation.
        if nargout>2 && nTr>1
            D(cTrGrp).V(iCh,:) = sum( (smooth -repmat(D(cTrGrp).mean(iCh,:),[nTr,1])).^2 ,1)./(nTr-1);
            D(cTrGrp).S(iCh,:) = sqrt(D(cTrGrp).V(iCh,:));
            D(cTrGrp).SE(iCh,:) = D(cTrGrp).S(iCh,:)./sqrt(nTr);
            
            % confidence interval of the mean
            dF = nTr-1;
            tcrit = tinv(1-alpha/2,dF);
            D(cTrGrp).CI(iCh,:) = tcrit.*D(cTrGrp).SE(iCh,:);
            
        end
        
        %% trial data
        if nargout>3 || TrialGroupFlag
            D(cTrGrp).trial(iCh,:,:) = permute(smooth,[3 2 1]);
        end
    end
end

%% construct output
if TrialGroupFlag
    D = reshape(D,TrialGroup);
    varargout{1} = D;
else
    varargout{1} = D.mean;
    varargout{2} = D.time;
    varargout{3} = D;
    varargout{4} = D.trial;
end
