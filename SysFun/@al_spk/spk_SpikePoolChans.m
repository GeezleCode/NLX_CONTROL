function o = spk_SpikePoolChans(s,poolChan,poolLabel)

% pool the spikes of different channels
% spike times in s.spk cells must be horizontal vectors
% o = spk_SpikePoolChans(s,poolChan,poolLabel)
%
% poolChan .... cell array, can be numeric (index to s.spk) or characters (strmatch to s.channels 
%               in different rows); channels not contained in poolChan will
%               be deleted !
% poolLabel ... new channel names in s.channel

[numChan,numTrials] = size(s.spk);
NumNewChan = length(poolChan);

%% prepare output
o = s;
o.spk = cell(NumNewChan,numTrials);
o.channel = {''};
o.unittype = {};
o.unittype(1:NumNewChan) = {'MUA'};

%% transform channel names into indices
for i = 1:NumNewChan
    
    % get the channel index from input
    ChanIndex = [];
    if iscell(poolChan{i})
        for k = 1:length(poolChan{i})
            ci = strmatch(poolChan{i}{k},s.channel);
            if ~isempty(ci)
                ChanIndex = cat(2,ChanIndex,ci);
            end
        end
    elseif isnumeric(poolChan{i})
        ChanIndex = poolChan{i};
    end
    
    % concatenate channels
    for k = 1:numTrials
        o.spk{i,k} = sort(cat(2,s.spk{ChanIndex,k}));
    end
    
    % rename channels
    if nargin<3 | isempty(poolLabel)
        o.channel{i,1} = strvcat(s.channel{ChanIndex});
        o.channel{i,1} = ['M' num2str(i)];
    else
        o.channel{i,1} =  poolLabel{i};
    end
end
