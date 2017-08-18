function pooled_s = spk_poolchannels(s,poolChan)

% pool the spikes of different channels
% spike times in s.spk cells must be horizontal vectors
% s = spk_poolchannels(s,poolChan)
%
% poolChan .... cell array, can be numeric (index to s.spk) or characters (strmatch to s.channels 
%               in different rows); channels not contained in poolChan will
%               be deleted

[numChan,numTrials] = size(s.spk);
NumNewChan = length(poolChan);

% prepare output
pooled_s = s;
pooled_s.spk = cell(NumNewChan,numTrials);
pooled_s.channel = {''};

% transform channel names into indices
for i = 1:NumNewChan
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
    
    for k = 1:numTrials
        pooled_s.spk{i,k} = sort(cat(2,s.spk{ChanIndex,k}));
    end
    
    pooled_s.channel{i,1} = strvcat(s.channel{ChanIndex});
    pooled_s.channel{i,1} = ['M' num2str(i)];
end
