function s = spk_AddSumChannel(s,SumChan,LeaveChanFlag)

% pool spikes of different channels
% s = spk_AddSumChannel(s,SumChan,LeaveChanFlag)
%
% SumChan ......... can be channel names (cell array of strings) or index
% LeaveChanFlag ... leave the pooled channels

[numChan,numTrials] = size(s.spk);

%--------------------------------------
% get the indices of channels
%--------------------------------------
if iscell(SumChan)
	SumChanIndex = spk_findchannel(s,SumChan);
elseif isnumeric(SumChan)
	SumChanIndex = SumChan;
end
SumChanIndex(isnan(SumChanIndex)) = [];
if isempty(SumChanIndex);warning('Can''t sum channels!');return;end

nSumChan = length(SumChanIndex);

%--------------------------------------
% prepare the new spike cell array
%--------------------------------------
if LeaveChanFlag
    AddChanIndex = nSumChan+1;
    SPK = cell(nSumChan+1,numTrials);
	SPK(1:nSumChan,:) = s.spk(SumChanIndex,:);
	s.channel = s.channel(SumChanIndex);
	s.channel(AddChanIndex) = {'SUM'};
else
    AddChanIndex = 1;
    SPK = cell(1,numTrials);
	s.channel = {'SUM'};
end
    
%--------------------------------------
% sum channels
%--------------------------------------
for i=1:numTrials
    SPK{AddChanIndex,i} = sort(cat(2,s.spk{SumChanIndex,i}));
end

%--------------------------------------
% assign new spike cell array to object
%--------------------------------------
s.spk = SPK;