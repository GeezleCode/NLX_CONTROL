function s = spk_AnalogMultiply(s,Factor,ChanName,Units)

% Multiply an analog channel by a given factor
% Acts on selected trials, if currentrials is not empty.
% s = spk_AnalogMultiply(s,Factor,Units,ChanName)
%
% INPUT:
% Factor
% Units ... cell array of strings
% ChanName

%% get the channel index
if nargin<3 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_FindAnalog(s,ChanName);
end
nChan = length(iChan);

%% loop channels
for iCh = 1:nChan
    
    if isempty(s.currenttrials)
        s.analog{iChan(iCh)} = s.analog{iChan(iCh)}.*Factor;
    else
        s.analog{iChan(iCh)}(s.currenttrials,:) = s.analog{iChan(iCh)}(s.currenttrials,:).*Factor;
    end
    
    if nargin>=4 && length(Units)==nChan
        if isempty(s.analogunits)
            s.analogunits = cell(1,length(s.analogname));
        end
        s.analogunits{iChan(iCh)} = Units{iCh};
    end
end