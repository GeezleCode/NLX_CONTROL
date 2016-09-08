function [i,sf] = spk_findAnalog(s,ChanName,PatternFlag)

% finds an analog channel, or channels featuring a pattern
% i = spk_findAnalog(s,ChanName,PatternFlag)
% i ... logical array for PatternFlag==true
%       indices of length ChanName for PatternFlag==false

if nargin<3
    PatternFlag = false;
end

if PatternFlag
    nCh = length(s.analogname);
    i = false(1,nCh);
    for iCh = 1:nCh
        k = strfind(s.analogname{iCh},ChanName);
        if ~isempty(k)
            i(iCh) = true;
        end
    end
            
else
    if ischar(ChanName)
        ChanName = {ChanName};
    end
    i = [];
    for iCh = 1:length(ChanName)
        CurrIndex = strmatch(ChanName{iCh},s.analogname,'exact');
        if isempty(CurrIndex)
            i(iCh) = NaN;
        else
            i(iCh) = CurrIndex;
        end
    end
end

sf = ones(1,length(i)).*NaN;
sf(~isnan(i)) = s.analogfreq(i(~isnan(i)));
    