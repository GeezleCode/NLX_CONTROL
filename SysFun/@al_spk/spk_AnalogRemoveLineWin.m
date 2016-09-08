function s = spk_AnalogRemoveLineWin(s,Fl,WinEv,doPlot)

% fits a sine wave of frequency f to each trial and substract the mean
% s = spk_AnalogRemoveSine(s,f,Ev,EvOffset)
%
% Fl ....... line frequency
% WinEv ....... eventlabel defining windows
% doPLot ...

if nargin<5
    doPlot = false;
end

%% get trial numbers
nTrTotal = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTrTotal;
end
nTr = length(s.currenttrials);

% s = spk_AnalogFiltFiltButter(s,6,[10 90],'bandpass');

%% loop channels
nCh = length(s.currentanalog);
hwait = waitbar(0,'removing line noise');
for iCh = 1:nCh
    ChNr = s.currentanalog(iCh);
        
    %% get time parameter
    Tp = (1/Fl)/(10^s.timeorder);% period of line frequency
    Ts = (1/s.analogfreq(ChNr))/(10^s.timeorder);% period of sampling
    PrdBinT = 0:Ts:Tp;% bin times of a period segment
    PrdBinN = length(PrdBinT);% number of bins in one period
    DoublePrdBinT = 0:Ts:2*Tp;% bin times of a two period segment
    DoublePrdBinN = length(DoublePrdBinT);
    
    %% get time windows
    [nTrTotaldummy,nBn] = size(s.analog{ChNr});
    nWinEv = length(WinEv);
    nw = nWinEv+1;
    wb = zeros(nTr,2,nw);
    wb(:,1,1) = 1;
    wb(:,2,nw) = nBn;
    for iwev = 1:nWinEv
        [v,t,i,terr] = spk_findAnalogEventBin(s,spk_getAnalogChanName(s,ChNr),WinEv{iwev});
%         [b,t,tVec] = spk_AnalogEventWindow(s,Ev,[0 0]);
        wb(:,2,iwev) = i'-1;
        wb(:,1,iwev+1) = i';
    end

    %% loop thru trials
    LineComponent = zeros(nTr,DoublePrdBinN).*NaN;
    SineComponent = zeros(nTr,DoublePrdBinN).*NaN;
    for iTr = 1:nTr
        TrNr = s.currenttrials(iTr);
        for iw = 1:nw
            widx = wb(iTr,1,iw):1:wb(iTr,2,iw);
            wnb = length(widx);
            if wnb<=1;continue;end
            cTrData = s.analog{ChNr}(TrNr,widx);
            if any(isnan(cTrData)) || isempty(cTrData);continue;end
            LC = GetLineComponent(cTrData,Ts,Tp);
            omega = 2*pi*Fl;
            [Ahat,Theta,RMS]=sinefit2(LC,omega,0,1/s.analogfreq(ChNr));
            SineSignal = Ahat*sin(omega*(([0:Ts:Ts*(wnb-1)]).*0.001)+Theta);
            cTrData = cTrData - SineSignal;
            s.analog{ChNr}(TrNr,widx) = cTrData;
        end
        waitbar(((iCh-1)*nTr+iTr)/(nCh*nTr),hwait);
    end

%     %% plotting 
%     if doPlot
%         figure
%         set(gcf,'name',s.analogname{ChNr});
%         rowN = ceil(sqrt(nTr));
%         colN = rowN;
%         axWidth = 1/colN;
%         axHeight = 1/rowN;
%         for iTr = 1:nTr
%             [rowNr,colNr] = ind2sub([rowN,colN],iTr);
%             axH(iTr) = subplot('position',[0+(colNr-1)*axWidth 1-(rowNr)*axHeight axWidth axHeight]);
%             line(DoublePrdBinT([1 end]),[0 0],'color','k','linewidth',0.75);
%             line(DoublePrdBinT,LineComponent(iTr,:),'color','k','linewidth',1.2);
%             line(DoublePrdBinT,SineComponent(iTr,:),'color','r','linewidth',1.5);
%         end
%         set(axH(:),'box','on', ...
%             'xlim',DoublePrdBinT([1 end]),'xtick',[],'ylim',[-10 10],'ytick',[]);
%     end
    
end
close(hwait);

% % chronux moving window
% smooth=1./(1+exp(-tau.*(x-Noverlap/2)/Noverlap)); % sigmoidal function
% smooth=repmat(smooth,[1 C]);
% for n=1:nw;
%     indx=winstart(n):winstart(n)+Nwin-1;
%     datawin=data(indx,:);
%     [datafitwin,as,fs]=fitlinesc(datawin,params,p,'n',f0);
%     Amps{n}=as;
%     freqs{n}=fs;
%     datafitwin0=datafitwin;
%     if n>1;
%         datafitwin(1:Noverlap,:)= smooth.*datafitwin(1:Noverlap,:) + (1-smooth).*datafitwin0(Nwin-Noverlap+1:Nwin,:);
%     end;
%     datafit(indx,:)=datafitwin;
% end;


function [LC,LCb] = GetLineComponent(data,Ts,Tp)
data = data(:);% make sure data is column
[nTot,nTr] = size(data);
n = floor(Tp/Ts)+1;% bins in one period
LCb = zeros(n,n*2-1)*NaN;
for i=1:n%sum line for each bin in the period 
    % sum consecutive periods
    SegStartBin = round(i:Tp/Ts:nTot);% get first bin for each period segment
    SegStartBin(SegStartBin+n-1>nTot)=[];
    [x,y] = meshgrid([0:n-1],SegStartBin);% get index for summation matrix
    cLC = data(x+y);
    cLC = cLC-repmat(nanmean(cLC,2),[1,n]);% substract DC offset
    LCb(i,[i:n+i-1]) = nanmean(cLC,1);
end
LC = nanmean(LCb,1);

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
