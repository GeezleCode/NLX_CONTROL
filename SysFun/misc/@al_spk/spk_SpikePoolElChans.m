function [s,iChPool] = spk_SpikePoolElChans(s,El,NewElSuffix,ChanProp,NewUnittype)

% pools channels of a electrode
% expects the channel names to be of the format "[El].[ClusterNr]" (e.g. 'Sc1.1')
% s = spk_SpikePoolElChans(s,El,NewElSuffix,UnitTypes)
%
% El ............. Electrode name "[El].[ClusterNr]" (e.g. 'Sc1' when 'Sc1.1')
% NewElSuffix .... will be attached to the new pooled channel name
% ChanProp ....... {1,...,n} cell array corresponding to n new channels
%                  numeric -> ClusterNr (e.g. #1 in 'Sc.1)
%                  cell-> unittype
% NewUnittype .... new entries for s.unittype

%% check input
if nargin<5
    ClusterNr = [];
    if nargin<4
        UnitTypes = [];
        if nargin<3
            NewElSuffix = [];
            if nargin<2
                El = {};
            end;end;end;end

if ~isempty(El) && ischar(El);El = {El};end% make sure El is cell

nChProp = length(ChanProp);

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
iChPool = cell(1,nEl*nChProp);
PoolChLabel = cell(1,nEl*nChProp);

%% loop electrodes
for ie=1:nEl
    isEl = strcmpi(El(ie),chElNames);
    for iProp = 1:nChProp
        
        %% apply properties
        if isnumeric(ChanProp{iProp})
            % select channel according to cluster nr
            isProp = ismember(chClusterNr,ChanProp{iProp});
        elseif iscell(ChanProp{iProp})
            % select channel according to unittype
            isProp = ismember(upper(s.unittype),upper(ChanProp{iProp}));
        else
            error('Content of ChanProp cells must be cells or numerical.');
        end
        iPool = iProp+(ie-1)*nChProp;
        iChPool{iPool}=find(isEl&isProp);
        
        %% construct new channel label
        if ~isempty(NewElSuffix)
            if ischar(NewElSuffix)
                PoolChLabel{iPool}=[El{ie} NewElSuffix];
            elseif iscell(NewElSuffix)
                PoolChLabel{iPool}=[El{ie} NewElSuffix{iProp}];
            end
        else % use new channel number 
             PoolChLabel{iPool}=sprintf('%s.%d',El{ie},iProp);
        end

    end
end

%% to pool use spk_SpikePoolChans method
okPool = ~cellfun('isempty',iChPool);
s = spk_SpikePoolChans(s,iChPool(okPool),PoolChLabel(okPool),NewUnittype(okPool));