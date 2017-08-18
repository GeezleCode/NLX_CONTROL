function [M,bins,Err,trial_d,h] = spk_density(s,sigma,win,varargin)

% Calculates the Spike Density Function over trials listed in s.currenttrials
% Time resolution 1 ms
%
% function [M,bins,Err.S,trial_d,h] = spk_density(s,sigma,win,varargin)
%
% INPUT
% sigma ...... sigma of gaussian
% win ........ smoothing window in ms
% varargin ... line properties if not empty plots in the current axes
%
% OUTPUT:
% d - density in hertz

NumCurrChan = length(spk_CheckCurrentChannels(s,0));
numCurrTr = length(spk_CheckCurrentTrials(s,0));
h = [];
alpha = 0.05; % for confidence interval
%__________________________________________________________________________
% time
smoothwin      = -3*sigma:3*sigma;
smoothwinwidth = abs(diff([smoothwin(1) smoothwin(end)]));

% check time win
if length(win(:))>2
    error('Time window must be [start end]. al_spk must be aligned.');
end
timewin         = win(1):win(2);
bins      = timewin;

M    = zeros(NumCurrChan,length(timewin)).*NaN;
Err.V   = zeros(NumCurrChan,length(timewin)).*NaN;
Err.S   = zeros(NumCurrChan,length(timewin)).*NaN;
Err.SE   = zeros(NumCurrChan,length(timewin)).*NaN;
Err.CI = zeros(NumCurrChan,length(timewin)).*NaN;
trial_d   = zeros(NumCurrChan,length(timewin),numCurrTr).*NaN;

nBinSmoothWin = length(smoothwin);
nBinTimeBin = length(timewin);

%gaussians = exp(-(smoothwin/(2.*sigma)).^2)'; 
% is this an error ?????!!!!! rather: 
gaussians = exp(-(smoothwin.^2/(2.*sigma.^2)))';
gaussians = gaussians/sum(gaussians);

% if isempty(win) | nBinSmoothWin*3>nBinTimeBin
%      warning('Please increase time window or decrease smoothwindow !');
%      M = NaN;
%      bins = NaN;
%      Err.S = NaN;
%      trial_d = NaN;
%      h = NaN;
%      return;
% end


for currChan = s.currentchan
    currChanIndex = find(s.currentchan==currChan);
    %__________________________________________________________________________
    % get spikes
    spkmat = zeros(nBinTimeBin,numCurrTr);
    i=0;
    for trial = s.currenttrials
        i  = i+1;
        if ~isempty(s.spk{currChan,trial})
            currSpkTimes = ceil(s.spk{currChan,trial}.*(10^s.timeorder)./(10^(-3)));%round milliseconds
            currSpkTimes = currSpkTimes(currSpkTimes>=win(1)&currSpkTimes<=win(2));% excise spikes outside window
            spkmat(currSpkTimes-win(1)+1,i) = 1;% times as index in spkmat
        end
    end
    
    %_______________________
    % filter with gaussian
    spkmat = cat(1,zeros(nBinSmoothWin*3,numCurrTr),spkmat,zeros(nBinSmoothWin*3,numCurrTr));% append zeros
    smooth = filtfilt(gaussians,1,spkmat);
    smooth = smooth(nBinSmoothWin*3+1:size(smooth,1)-nBinSmoothWin*3,:);% cut zeros
	smooth = smooth'.*1000;% convert to spikes/sec
    
    % safetime = find(timewin>timewin(1)+smoothwinwidth & timewin<timewin(end)-smoothwinwidth);
    % if isempty(safetime);error('Can not calculate density !');end
    % timewin = timewin(safetime);
    % smooth = smooth(safetime,:);
    
    %_________________
    % OUTPUT
    M(currChanIndex,:)    = sum(smooth,1)./numCurrTr;
    
    %_____________________________
    % Determine standard deviation.
    if nargout>2 & numCurrTr>1
		Err.V(currChanIndex,:) = sum( (smooth -repmat(M(currChanIndex,:),[numCurrTr,1])).^2 ,1)./(numCurrTr-1);
        Err.S(currChanIndex,:) = sqrt(Err.V(currChanIndex,:));
		Err.SE(currChanIndex,:) = Err.S(currChanIndex,:)./sqrt(numCurrTr);
		
		% confidence interval of the mean
		dF = numCurrTr-1;
		tcrit = tinv(1-alpha/2,dF);
		Err.CI(currChanIndex,:) = tcrit.*Err.SE(currChanIndex,:);

    end
    
    %____________________________
    % trial data
    if nargout>3
        trial_d(currChanIndex,:,:) = permute(smooth,[3 2 1]);
    end
    
end
%___________________________
% plot density
h = [];
if nargin<4;return;end
if NumCurrChan>1
	error('Cannot plot more than one channel!');
end

% h(1) = patch( ...
% 	[bins bins], ...
% 	[M-Err.S M+Err.S], ...
% 	[0.6 0.6 0.6], ...
% 	'linestyle','none');
h(2) = line(bins,M,varargin{:});