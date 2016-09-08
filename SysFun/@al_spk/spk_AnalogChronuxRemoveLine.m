function s = spk_AnalogChronuxRemoveLine(s,params,f0,method,movingwin,tau)

% applies chronux functions to analog data. s.currentanalog must be set
% s = spk_AnalogChronuxRemoveLine(s,params,f0,method)
%
% method .... 'rmlinesc' or 'rmlinesmovingwinc'

if nargin<4 || isempty(method)
    method = 'rmlinesc';
end

%% Chronux parameter
if isempty(params)
    params.tapers = [3 5];
    params.pad = 0;
    params.Fs = [];
    params.fpass = [];
end

p = [];% p value
plt = 'n';% plot flag
if nargin<5
    movingwin = [];% [window winstep] required for rmlinesmovingwinc
    tau = [];% smoothing parameter
end

%% loop the channels
nChan = length(s.currentanalog);
disp('spk_AnalogChronuxRemoveLine is removing line noise ...');

for iCh = 1:nChan
    ChNr = s.currentanalog(iCh);
    params.Fs = s.analogfreq(ChNr);

    s = spk_AnalogRemoveNaNs(s);
    
    switch method
        case 'rmlinesc'
            s.analog{ChNr} = rmlinesc(s.analog{ChNr}',params,p,plt,f0);
        case 'rmlinesmovingwinc'
            [s.analog{ChNr},datafit,Amps,freqs] = rmlinesmovingwinc(s.analog{ChNr}',movingwin,tau,params,p,plt,f0);
    end
    s.analog{ChNr} = s.analog{ChNr}';
end



