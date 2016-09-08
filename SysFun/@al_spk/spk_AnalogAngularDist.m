function s = spk_AnalogAngularDist(s,S1Chans,S2Chans,NewChanName)

% calculates the angular distance between signal S1 to S2
% s = spk_AnalogAngularDist(s,S1Chans,S2Chans,NewChanName)
% S1Chans .... char an existing analog channel or a 
% S2Chans .... Reference, as S1 or scalar

%% get the channel index
iSig1 = spk_findAnalog(s,S1Chans);
if isnumeric(S2Chans)&&numel(S2Chans)==1
   iSig2 = NaN;
else
    iSig2 = spk_findAnalog(s,S2Chans);
end

%% copy channel data
[s,iNew] = spk_AnalogCopyChan(s,S1Chans,NewChanName);

if ~isnan(iSig2)
    %% check for consistency of sampling
    if s.analogfreq(iSig1)~=s.analogfreq(iSig2) || s.analogfreq(iSig1)~=s.analogfreq(iSig2)
        error('Sample Frequency of signal is inconsistent!');
    end

    tSig1 = spk_AnalogTimeVec(s,S1Chans);
    nBin = length(tSig1);

    tSig2 = spk_AnalogTimeVec(s,S2Chans);

    %% match time bins of signals
    i = ones(1,nBin);
    for iBin = 1:nBin
        [dummy,i(iBin)] = min(abs(tSig1(iBin)-tSig2));
    end

    s.analog{iNew} = shiftangles(s.analog{iSig1}(:,i),s.analog{iSig2}(:,i));
    
else
    s.analog{iNew} = shiftangles(s.analog{iSig1},S2Chans);
end

%% -------------- subfunctions -------------------------------
function out = shiftangles(in,center)

% function out = shiftangles(in,center)
%
% shifts an array of angles to the period [-pi pi]
% center becomes 0

out = in - center;

i = find(out<-pi);
f = ceil(abs(ceil(out(i)./pi))./2);
out(i) = out(i)+f.*(2*pi);

i = find(out>pi);
f = ceil(abs(floor(out(i)./pi))./2);
out(i) = out(i)-f.*(2*pi);
