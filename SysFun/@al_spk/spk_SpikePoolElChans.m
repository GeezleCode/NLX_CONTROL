function [s,iChPool] = spk_SpikePoolElChans(s,El,Elsuffix,UnitTypes,ClusterNr)

% pools all the channels recorded from a given electrode
% s = spk_SpikePoolElChans(s,El,Elsuffix,UnitTypes)
% El .......... cell/char of the format "[El].[ClusterNr]" (e.g. 'Sc1.1')
% Elsuffix .... will be attached to the new pooled channel name
% UnitTypes ... Unittypes to include
% ClusterNr ... ClusterNr to include

%% check input
if nargin<5
    ClusterNr = [];
    if nargin<4
        UnitTypes = [];
        if nargin<3
            Elsuffix = [];
            if nargin<2
                El = {};
            end;end;end;end

if ~isempty(El) && ischar(El);El = {El};end% make sure El is cell

%% check existing channels
[chElNames,chClusterNr] = spk_SpikeDecodeChanName(s);
if isempty(El)
    El = unique(chElNames);
else
    El = El(ismember(El,chElNames));
end
nEl = length(El);
nCh = length(chElNames);

%% allocate
iChPool = cell(1,nEl);
PoolChLabel = cell(1,nEl);

%% loop electrodes
for ie=1:nEl
    
    isEl = strcmpi(El(ie),chElNames);
    if isempty(UnitTypes);isUnit = true(1,nCh);else isUnit = ismember(upper(s.unittype),upper(UnitTypes));end
    if isempty(ClusterNr);isClust = true(1,nCh);else isClust = ismember(chClusterNr,ClusterNr);end
    
    
    iChPool{ie}=find(isEl&isUnit&isClust);
    PoolChLabel{ie}=[El{ie} Elsuffix];
end

s = spk_SpikePoolChans(s,iChPool,PoolChLabel);