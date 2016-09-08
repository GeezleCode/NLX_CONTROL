function s = spk_AnalogChanSum(s,Mode,S1Chan,S2Chan,NewChan,InverseFlag)

% Sum or multiply two analog channels. First one is reference SF
% spk_AnalogChanSum(s,Mode,S1Chan,S2Chan,NewChan,InverseFlag)
% Mode ..... 'SUM','SUB','PROD','RATIO
% S1,S2 .... cell array of strings with X and Y channel names
% NewChan .... new name of channel
% InverseFlag ... reverses S1 and S2 in case of 'SUB' 'RATIO'

%% check input
if nargin<5
    InverseFlag = false;
end

%% get the channel index
iS1 = spk_findAnalog(s,S1Chan);
iS2 = spk_findAnalog(s,S2Chan);

%% copy channel data
[s,iChan] = spk_AnalogCopyChan(s,S1Chan,NewChan);

%% get time vector
tS1 = spk_AnalogTimeVec(s,S1Chan);
tS2 = spk_AnalogTimeVec(s,S1Chan);
nBin = length(tS1);

%% match time bins of signals
i = ones(1,nBin);
for iBin = 1:nBin
    [dummy,i(iBin)] = min(abs(tS1(iBin)-tS2));
end

%% calc
switch Mode
    case 'SUM'
        s.analog{iChan} = s.analog{iS1} + s.analog{iS2}(:,i);
    case 'SUB'
        if InverseFlag
            s.analog{iChan} = s.analog{iS2}(:,i) - s.analog{iS1};
        else
            s.analog{iChan} = s.analog{iS1} - s.analog{iS2}(:,i);
        end
    case 'PROD'
        s.analog{iChan} = s.analog{iS1} .* s.analog{iS2}(:,i);
    case 'RATIO'
        if InverseFlag
            s.analog{iChan} = s.analog{iS2}(:,i) ./ s.analog{iS1};
        else
            s.analog{iChan} = s.analog{iS1} ./ s.analog{iS2}(:,i);
        end
end         
