function [s,Amp,Theta] = spk_AnalogRemoveSine(s,f,Ev,EvOffset)

% fits a sine wave of frequency f to each trial and subtract the mean
% s = spk_AnalogRemoveSine(s,f,Ev,EvOffset)

nTr = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end

%% get time window
if nargin<3
    [EvTimes,i] = spk_getEvents(s,Ev);
    EvTimes = cat(1,EvTimes{:});
    if ischar(EvOffset)
        [EvOffsetTimes,i] = spk_getEvents(s,EvOffset);
    elseif isnumeric(EvOffset)
        EvTimes = repmat(EvTimes,[1 2]) + repmat(EvOffset,[length(EvTimes) 1])

%% loop channels
nCh = length(s.currentanalog);

for iCh = 1:nCh
    ChNr = s.currentanalog(iCh);
    SF = (1/s.analogfreq(ChNr));
    
    Amp = ones(nTr,1).*NaN;
    Theta = ones(nTr,1).*NaN;
	
    for iTr = 1:nTr
        ci(iTr,:) = ~isnan(s.analog{ChNr}(iTr,:));
        Ns = sum(ci(iTr,:),2);
        t = [0:Ns-1].*SF;
		[Amp(iTr),Theta(iTr),RMS]=sinefit2(s.analog{ChNr}(iTr,ci(iTr,:)),2*pi*f,0,SF);
    end
    
    AmpM = mean(Amp); 
    for iTr = 1:nTr
        Ns = sum(ci(iTr,:),2);
        t = [0:Ns-1].*SF;
        s.analog{ChNr}(iTr,ci(iTr,:)) = s.analog{ChNr}(iTr,ci(iTr,:)) - AmpM*sin(2*pi*f*t+Theta(iTr));
    end

end

function [Ahat,Theta,RMS]=sinefit2(s0,omega,t0,Ts) 
% sine wave fitting from noisy sine signal 
% phase fitting has to be considered 
% with a fixed omega! 
% Written by Dr Chen YangQuan <yqchen@ieee.org> 
% Last modified in 05-11-2000
% DESCRIPTIONS:
% s0: sampled series. 1xNp (note here) 
% omega: known freq. (2*pi*f) (rad/sec.) 
% Ts: sampling period (in Sec.) 
% t0: initial time (in Sec.) 
% Ahat: estimated amplitude 
% Theta: fitted theta_0 (in rad.) 
% RMS: root mean squares. 
% 
% See also "jomega"
Np=size(s0); 
t=t0+[0:Np(2)-1]*Ts; 
A11= (sin(omega*t)*(sin(omega*t))'); 
A12= (sin(omega*t)*(cos(omega*t))'); 
A22= (cos(omega*t)*(cos(omega*t))'); 
b1=s0*(sin(omega*t))'; 
b2=s0*(cos(omega*t))'; 
A=[A11,A12;A12,A22]; 
Alpha=inv(A)*[b1,b2]'; 
% be careful here... 
Asintheta=Alpha(2);Acostheta=Alpha(1); 
Ahat=sqrt(Asintheta*Asintheta+Acostheta*Acostheta); 
Theta=atan2(Asintheta,Acostheta); 
RMS=sqrt((s0-Ahat*sin(omega*t+Theta))*... 
(s0-Ahat*sin(omega*t+Theta))'/(Np(2)-1.)); 
