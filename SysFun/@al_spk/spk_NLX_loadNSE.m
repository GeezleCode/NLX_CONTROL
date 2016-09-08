function [s,P] = spk_NLX_loadNSE(s,NSE,varargin)

% loads spike data from a NSE structure
%
% s = spk_NLX_loadNSE(s,NSE, ...)
% NSE ................ NSE structure, see Neuralynx Tools
%
% s = spk_NLX_loadNSE(s,NSE,prop1,val1, ...)
% properties:
% NLXClusterNr ....... vector of cluster nr, default: all clusters
% SPKChanLabel ....... label for new channels, {'label1' ...} 
% SPKUnittype ........ unittype for new channels, {'MUA' ...}
% NLXWin ............. time window for every trial in NLX time (microsec),
%                      trials along rows. default: see NLXWinEvents
% NLXWinEvents ....... events defining a time window {'Event1' 'Event2'},
%                      default: earliest and lates event found in each
%                      trial.
% NLXWinOffset ....... time added to the NLXWinEvents (actually added to NLXWin)
% ClearChannels ...... true: clear all existing channels, false: replace
%                      all existing ones

%% settings structure
P.NLXClusterNr = [];% default: all clusters
P.SPKChanLabel = {};% default: NSE name + NLXClusterNr
P.SPKUnittype = {};% default: 'n/a'
P.NLXWin = [];
P.NLXWinEvents = {};% default: earliest and latest event of trials
P.NLXWinOffset = [0 0];% default: 0
P.ClearChannels = false;
P.LoadWaveform = false;
P.WaveFormBins = [1:32];
P = StructUpdate(P,varargin{:});

%% other settings
TimeDimDiff = (-6) - s.timeorder;
numTrials = size(s.events,2);

if P.LoadWaveform&&isempty(NSE.SpikeWaveForm)
    error('No waveform loaded!!');
    P.LoadWaveform = false;
end

%% get trial time windows
if isempty(P.NLXWin)
    if ~isempty(P.NLXWinEvents)
        [P.NLXWin,TrialAlignTimes] = spk_TrialEventWindow(s,P.NLXWinEvents(1),P.NLXWinEvents(2));
    else
        [P.NLXWin,TrialAlignTimes] = spk_TrialEventLimit(s);
    end
    P.NLXWin = P.NLXWin + repmat(TrialAlignTimes,[1,2]);
    P.NLXWin(:,1) = P.NLXWin(:,1)+P.NLXWinOffset(1);
    P.NLXWin(:,2) = P.NLXWin(:,2)+P.NLXWinOffset(2);
    P.NLXWin = P.NLXWin * 1000;
end

%% organise channels

% NLXClusterNr
if isempty(P.NLXClusterNr)
    P.NLXClusterNr = unique(NSE.ClusterNr);
    if any(P.NLXClusterNr<0|P.NLXClusterNr>100)
        P.NLXClusterNr(P.NLXClusterNr<0|P.NLXClusterNr>100) = [];
        warning('Unlikely cluster-Nr found! Not loaded');
    end
end
nClust = length(P.NLXClusterNr);

% SPKChanLabel
if isempty(P.SPKChanLabel)
    [NSEDir,NSEName,NSEExt] = fileparts(NSE.Path);
    for iCl = 1:nClust
        P.SPKChanLabel{iCl} = sprintf('%s.%1.0f',NSEName,P.NLXClusterNr(iCl));
    end
end

% SPKUnittype
if isempty(P.SPKUnittype)
    for iCl = 1:nClust
        P.SPKUnittype{iCl} = '';
    end
end

if nClust~=length(P.SPKChanLabel) || nClust~=length(P.SPKUnittype)
    error('Number of clusters and channel names must be equal!');
end

if P.ClearChannels
    s.spk = cell(nClust,numTrials);
    s.channel = cell(1,nClust);
    s.unittype = cell(1,nClust);
    ChNr = 1:nClust;
else
    % replace existing ones 
    ChNr = 1:nClust;
    NumChan = spk_SpikeChanNum(s);
    [isExistChan,ReplaceIndex] = ismember(P.SPKChanLabel,s.channel);
    NumRepChan = sum(isExistChan);
    ChNr(isExistChan) = ReplaceIndex(isExistChan);   
    
    % add non existing ones
    NumAddChan = sum(~isExistChan);
    if ischar(s.channel); s.channel= {};end
    s.channel(NumChan+1:NumChan+NumAddChan) = {''};
    if ischar(s.unittype); s.unittype= {};end
    s.unittype(NumChan+1:NumChan+NumAddChan) = {''};
    AddChanNr = find(~isExistChan);
    for i = 1:NumAddChan
        ChNr(AddChanNr(i)) = NumChan+i;
    end
end

%% loop trials
% hwait = waitbar(0,'Extract spikes from neuralynx NSE file ...');
TSidx = false(length(NSE.TimeStamps),1);
for j = 1:nClust
    s.channel(ChNr(j)) = P.SPKChanLabel(j);
    s.unittype(ChNr(j)) = P.SPKUnittype(j);
    for i = 1:numTrials
        
        TSidx = NSE.ClusterNr==P.NLXClusterNr(j) & NSE.TimeStamps>=P.NLXWin(i,1) & NSE.TimeStamps<=P.NLXWin(i,2);
        
        s.spk{ChNr(j),i} =  NSE.TimeStamps(TSidx);
        s.spk{ChNr(j),i} =  s.spk{ChNr(j),i} .* (10^TimeDimDiff) - s.align(i);
        
        if P.LoadWaveform
            s.spkwave{ChNr(j),i} = permute(NSE.SpikeWaveForm(P.WaveFormBins,:,TSidx),[3,1,2]);
        end
        
%         waitbar(((j-1)*numTrials+i)/(nClust*numTrials),hwait,sprintf('Extract spikes for channel %s',s.channel{ChNr(j)}));
    end
end
% close(hwait);

    
    