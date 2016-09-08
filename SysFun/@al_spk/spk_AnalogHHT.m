function C = spk_AnalogHHT(s,ChanName,TimeWin,SpecMethod,varargin)

%FreqBandPass,FreqBinWidth,maxIMFiteration)

% computes the Hilbert-Huang Transform for selected analog channels/trials

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

%% loop channels and trials
hwait = waitbar(0,'');
for iCh = 1:nCh
    cCh = s.currentanalog(iCh);
    Tn = size(s.analog{cCh},2);
    Ts = 1/s.analogfreq(cCh);
    Ti = 0-(s.analogalignbin(cCh)-1)*Ts : Ts : (Tn-s.analogalignbin(cCh))*Ts;
    
    C(iCh).Name = s.analogname{cCh};
    C(iCh).Ts = Ts;
    C(iCh).T = Ti;
    C(iCh).idx = false(nTr,Tn);
    C(iCh).iTr = s.currenttrials;
    C(iCh).FreqBandPass = FreqBandPass;
    C(iCh).FreqBinWidth = FreqBinWidth;
    C(iCh).maxIMFiteration = maxIMFiteration;    
    
    C(iCh).imf = cell(1,nTr);
    C(iCh).imfAmp = cell(1,nTr);
    C(iCh).imfF = cell(1,nTr);
    C(iCh).imfT = cell(1,nTr);

    C(iCh).SpecS = cell(1,nTr);
    C(iCh).SpecT = cell(1,nTr);
    C(iCh).SpecF = cell(1,nTr);
    
    for iTr = 1:nTr
        waitbar(((iCh-1)*nTr+iTr-1)/(nCh*nTr),hwait,sprintf('computing HHT  - Trial %1.0f(%1.0f) Chan %1.0f(%1.0f)',iTr,nTr,iCh,nCh));
        cTr = s.currenttrials(iTr);
        x = s.analog{cCh}(cTr,:);
        ix = ~isnan(x);
        nx = sum(ix);
        C(iCh).imfT{iTr} = Ti(ix);
        [C(iCh).SpecS{iTr}, C(iCh).SpecT{iTr}, C(iCh).SpecF{iTr}, C(iCh).imf{iTr}, C(iCh).imfAmp{iTr}, C(iCh).imfF{iTr}] = HHT(x(ix),Ts,maxIMFiteration,FreqBandPass,FreqBinWidth);
        C(iCh).SpecT{iTr} = C(iCh).SpecT{iTr} + C(iCh).imfT{iTr}(1);
        C(iCh).idx(iTr,:) = ix;
        waitbar(((iCh-1)*nTr+iTr)/(nCh*nTr),hwait,sprintf('computing HHT  - Trial %1.0f(%1.0f) Chan %1.0f(%1.0f)',iTr,nTr,iCh,nCh));
    end
end
close(hwait);

%%
% --------------------------------------------------------------------
% ------------------------- subfunctions -----------------------------
% --------------------------------------------------------------------

function [Spec,SpecT,SpecF,imf,imfAmp,imfF] = HHT(x,Ts,maxIMFiteration,fPass,fBinWidth)
% Hilbert Huang Transfrom for one trial

% Empirical Mode Decomposition (SIFTING).
[imf,imfAmp] = EmpModeDecomp(x,maxIMFiteration);

% Hilbert Transformation
[ns,nm] = size(imf);
imfF = zeros(ns-1,nm).*NaN;
for k = 1:nm
    th   = angle(hilbert(imf(:,k)'));
    imfF(:,k) = diff(th')/Ts/(2*pi);
end

% transform into Spectrogram using envelope of rectified imf
[Spec,SpecT,SpecF] = AmplitudeSpec(imfAmp(1:end-1,:),imfF,Ts,fPass,fBinWidth);

function [S,t,f] = AmplitudeSpec(A,F,Ts,fPass,fBinWidth)

% combines frequency and amplitude information
% a ... [:,n] amplitude information
% f ... [:,n] frequency information

[Ns,imfnum] = size(A);
[Ns,imfnum] = size(F);

t = linspace(0,Ns*Ts,Ns);
fb = fPass(1):fBinWidth:fPass(2);
f = fb(1:end-1)+fBinWidth/2;
Nf = length(f);

S = zeros(Nf,Ns);
nS = zeros(Nf,Ns);

% convert frequency to bin number
F = F-fPass(1);
F = ceil(F./fBinWidth);

% loop thru spectrum
for iLoop = 1:[Ns * imfnum]
    [it,iimf] = ind2sub([Ns,imfnum],iLoop);
    if F(it,iimf)>0 && F(it,iimf)<=Nf
        nS(F(it,iimf),it) = nS(F(it,iimf),it) + 1;
        S(F(it,iimf),it) = S(F(it,iimf),it) + A(it,iimf);
    end
end
nS(nS==0) = NaN;
S = S./nS;

function [imf,Amp,Env] = EmpModeDecomp(x,maxIt)
% Empiricial Mode Decomposition
% imf = emd(x)
% x ........ signal vector 
% maxIt .... max number of iteration
% imf ...... intrinsic mode functions 
if nargin<2
    maxIt = inf;
end
x   = transpose(x(:));
n = length(x);
imfAllocNum = 50;
imf = zeros(n,imfAllocNum).*NaN;
cnt = 0;
while ~ismonotonic(x)
    x1 = x;
    sd = Inf;
    i = 0;
    while (sd > 0.1) | ~isimf(x1)
        s1 = getspline(x1);
        s2 = -getspline(-x1);
        x2 = x1-(s1+s2)/2;
        
        sd = sum((x1-x2).^2)/sum(x1.^2);
        x1 = x2;
        i = i+1;
        if i>maxIt;
            break;
        end
    end
    
    if i<=maxIt
        cnt = cnt+1;
        imf(:,cnt) = x1';
        x          = x-x1;
    else
        fprintf(1,'Empirical Mode Decomp.: reached max. number (%1.0f) of iterations!\n',i);
        break;
    end
end
imf(:,cnt+1) = x';
imf(:,cnt+2:imfAllocNum) = [];

% amplitude: spline interpolated positive envelope of the imf
if nargout==2
    Amp = zeros(size(imf,1),size(imf,2),1);
    for i = 1:size(imf,2)
        Amp(:,i,1) = getspline(abs(imf(:,i))')';
    end
end

% positive and negative envelope of imf
if nargout==3
    Env = zeros(size(imf,1),size(imf,2),2);
    for i = 1:size(imf,2)
        Env(:,i,1) = getspline(imf(:,i)')';
        Env(:,i,2) = -getspline(-imf(:,i)')';
    end
end


function u = ismonotonic(x)

u1 = length(findpeaks(x))*length(findpeaks(-x));
if u1 > 0, u = 0;
else,      u = 1; end

function u = isimf(x)

N  = length(x);
u1 = sum(x(1:N-1).*x(2:N) < 0);
u2 = length(findpeaks(x))+length(findpeaks(-x));
if abs(u1-u2) > 1, u = 0;
else,              u = 1; end

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