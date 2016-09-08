function o = spk_SpikePoolChans(s,poolChan,poolLabel,poolUnitTypes)

% pool the spikes of different channels
% spike times in s.spk cells must be horizontal vectors
% o = spk_SpikePoolChans(s,poolChan,poolLabel)
%
% poolChan .... cell array, can be numeric (index to s.spk) or characters (strmatch to s.channels 
%               in different rows); channels not contained in poolChan will
%               be deleted !
% poolLabel ... new channel names in s.channel

if isempty(poolChan)
    poolChan = {1:size(s.spk,1)};
end
    
[numChan,numTrials] = size(s.spk);
NumNewChan = length(poolChan);

%% prepare output
o = s;
o.spk = cell(NumNewChan,numTrials);
o.channel = {''};
o.unittype = {};
o.unittype(1:NumNewChan) = {'MUA'};

%% transform channel names into indices
ChanIndex = cell(1,NumNewChan);
for i = 1:NumNewChan
    % get the channel index from input
    if iscell(poolChan{i})
        for k = 1:length(poolChan{i})
            ci = strmatch(poolChan{i}{k},s.channel);
            if ~isempty(ci)
                ChanIndex{i} = cat(2,ChanIndex,ci);
            end
        end
    elseif isnumeric(poolChan{i})
        ChanIndex{i} = poolChan{i};
    end
end
    
%% concatenate channels
if ~isempty(s.spkwave)
    for i = 1:NumNewChan
        for k = 1:numTrials
            [o.spk{i,k},sortindex] = sort(cat(1,s.spk{ChanIndex{i},k}));
            o.spkwave{i,k} = cat(1,s.spkwave{ChanIndex{i},k});
            o.spkwave{i,k} = o.spkwave{i,k}(sortindex,:);
        end
    end
else
    for i = 1:NumNewChan
        for k = 1:numTrials
            [o.spk{i,k},sortindex] = sort(cat(1,s.spk{ChanIndex{i},k}));
        end
    end
end
    
%% rename channels
for i = 1:NumNewChan
    if nargin<3 || isempty(poolLabel)
        o.channel{i,1} = strvcat(s.channel{ChanIndex});
        o.channel{i,1} = ['M' num2str(i)];
    else
        o.channel{i,1} =  poolLabel{i};
    end
end

%% rename channels
for i = 1:NumNewChan
    if nargin<4 || isempty(poolUnitTypes)
        o.unittype{i,1} = 'POOLED';
    else
        o.unittype{i,1} =  poolUnitTypes{i};
    end
end