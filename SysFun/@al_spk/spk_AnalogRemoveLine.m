function s = spk_AnalogRemoveLine(s,Fl,x1,x2,doPlot)

% fits a sine wave of frequency f to each trial and substract the mean
% s = spk_AnalogRemoveSine(s,f,Ev,EvOffset)
%
% Fl ....... line frequency
% x1, x2 ......
% doPLot ...

if nargin<5
    doPlot = false;
end

%% get trials
nTr = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end

% s = spk_AnalogFiltFiltButter(s,6,[10 90],'bandpass');

%% loop channels
nCh = length(s.currentanalog);
hwait = waitbar(0,'removing line noise');
for iCh = 1:nCh
    ChNr = s.currentanalog(iCh);
    
    
    %% get time windows of line summation for each trial
    [bWin,tWin,tVec] = spk_AnalogEventWindow(s,x1,x2);
    % here bWin indicate the bins that come closest to the actuall events
    % tWin are the exact event windows; tVec are the bin times of the
    % analog data matrix, relative to the akignment bin
    
    %% get time parameter
    PrdT = (1/Fl)/(10^s.timeorder);% period of line frequency
    SampleT = (1/s.analogfreq(ChNr))/(10^s.timeorder);% period of sampling
    PrdBinT = 0:SampleT:PrdT;% bin times of a period segment
    PrdBinN = length(PrdBinT);% number of bins in one period
    DoublePrdBinT = 0:SampleT:2*PrdT;% bin times of a two period segment
    DoublePrdBinN = length(DoublePrdBinT);
    
    %% loop thru trials
    LineComponent = zeros(nTr,DoublePrdBinN).*NaN;
    SineComponent = zeros(nTr,DoublePrdBinN).*NaN;
    for iTr = 1:nTr
        
        %% time of first period bin
        T0 = tVec{iCh}(bWin(iTr,1));

        %% loop thru 
        nbWin = PrdBinN;
        L = zeros(nbWin,(PrdBinN*2)-1).*NaN;
        for iB=1:PrdBinN
            cB = bWin(iTr,1)+iB-1;
            [d,SegStartBin] = PeriodSum(s.analog{ChNr}(iTr,:),[cB bWin(iTr,2)],PrdBinN,PrdT,SampleT);
            
            % find temporal shift relative to T0
            cT0 = tVec{iCh}(cB);%
            dPrd = (cT0-T0)/PrdT;
            dPrd = dPrd - floor(dPrd);
            BinShift = round(dPrd*(PrdBinN-1));
            
            L(iB,[(1+BinShift):(PrdBinN+BinShift)]) = d;
        end
        LineComponent(iTr,:) = nanmean(L,1);
        
        %% sine fit to the line of this trial
        omega = 2*pi*Fl;
        [Ahat,Theta,RMS]=sinefit2(LineComponent(iTr,:),omega,0,1/s.analogfreq(ChNr));
        SineComponent(iTr,:) = Ahat*sin(omega*(DoublePrdBinT.*0.001)+Theta);
        SineSignal = Ahat*sin(omega*((tVec{iCh}-T0).*0.001)+Theta);
        
        %% substract line from signal of whole trial
        s.analog{ChNr}(iTr,:) = s.analog{ChNr}(iTr,:)-SineSignal;
        
        waitbar(((iCh-1)*nTr+iTr)/(nCh*nTr),hwait,'removing line noise');
    end

    %% plotting 
    if doPlot
        figure
        set(gcf,'name',s.analogname{ChNr});
        rowN = ceil(sqrt(nTr));
        colN = rowN;
        axWidth = 1/colN;
        axHeight = 1/rowN;
        for iTr = 1:nTr
            [rowNr,colNr] = ind2sub([rowN,colN],iTr);
            axH(iTr) = subplot('position',[0+(colNr-1)*axWidth 1-(rowNr)*axHeight axWidth axHeight]);
            line(DoublePrdBinT([1 end]),[0 0],'color','k','linewidth',0.75);
            line(DoublePrdBinT,LineComponent(iTr,:),'color','k','linewidth',1.2);
            line(DoublePrdBinT,SineComponent(iTr,:),'color','r','linewidth',1.5);
        end
        set(axH(:),'box','on', ...
            'xlim',DoublePrdBinT([1 end]),'xtick',[],'ylim',[-10 10],'ytick',[]);
    end
    
end
close(hwait);


function [d,SegStartBin] = PeriodSum(d,bWin,n,Tp,Ts)
% get index for summation matrix
SegStartBin = round(bWin(1):Tp/Ts:bWin(2));
[x,y] = meshgrid([0:n-1],SegStartBin);
% get analog data
d = d(x+y);
d = d-repmat(nanmean(d,2),[1,size(d,2)]);
d = nanmean(d,1);

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
