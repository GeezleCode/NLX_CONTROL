function s = spk_AnalogCircularDist(s,SigChans,RefChans,ThChanName,RChanName,AbsFlag)

% calculates the circular distance between XY signal S1 and signal S2
% s = spk_AnalogCircularDist(s,SigChans,RefChans,ThChanName,RChanName,AbsFlag)
% SigChans .... cell array of strings with X and Y channel names
% RefChans .... as SigChans or 1x2 vector [Theta R]

%% get the channel index
iSigX = spk_findAnalog(s,SigChans{1});
iSigY = spk_findAnalog(s,SigChans{2});
if isnumeric(RefChans)&&numel(RefChans)==2
    iRefX = NaN;iRefY = NaN;
elseif iscell(RefChans)
    iRefX = spk_findAnalog(s,RefChans{1});
    iRefY = spk_findAnalog(s,RefChans{2});
end

%% copy channel data
[s,iTh] = spk_AnalogCopyChan(s,SigChans{1},ThChanName);
[s,iR] = spk_AnalogCopyChan(s,SigChans{1},RChanName);


if ~isnan(iRefX)&&~isnan(iRefY)
    %% check for consistency of sampling
    if s.analogfreq(iSigX)~=s.analogfreq(iSigY) || s.analogfreq(iRefX)~=s.analogfreq(iRefY)
        error('Sample Frequency of signal is inconsistent!');
    end

    tSigX = spk_AnalogTimeVec(s,SigChans{1});
    % tSigY = spk_AnalogTimeVec(s,SigChans{2});
    nBin = length(tSigX);
    tRefX = spk_AnalogTimeVec(s,RefChans{1});
    % tRefY = spk_AnalogTimeVec(s,RefChans{2});

    %% match time bins of signals
    i = ones(1,nBin);
    for iBin = 1:nBin
        [dummy,i(iBin)] = min(abs(tSigX(iBin)-tRefX));
    end

    %% cart 2 pol
    [RefTh,RefR] = cart2pol(s.analog{iRefX}(:,i),s.analog{iRefY}(:,i));
    [SigTh,SigR] = cart2pol(s.analog{iSigX},s.analog{iSigY});
    
    s.analog{iR} = SigR-RefR;
    s.analog{iTh} = shiftangles(SigTh,RefTh);

else
    [SigTh,SigR] = cart2pol(s.analog{iSigX},s.analog{iSigY});
    
    s.analog{iR} = SigR-RefChans(2);
    s.analog{iTh} = shiftangles(SigTh,RefChans(1));

end

if AbsFlag
    s.analog{iTh} = abs(s.analog{iTh});
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