function [s,P] = spk_NLX_loadNCS(s,NCS,varargin)

% loads spike data from a NCS structure
%
% [s,P] = spk_NLX_loadNSE(s,NSE, ...)
% NSE ................ NSE structure, see Neuralynx Tools
%
% [s,P] = spk_NLX_loadNSE(s,NSE,prop1,val1, ...)
% properties:
% AnalogChanLabel .... label for new channels, {'label1' ...} 
% NLXWin ............. time window for every trial in NLX time (microsec),
%                      trials along rows. default: see NLXWinEvents
% NLXWinEvents ....... events defining a time window {'Event1' 'Event2'},
%                      default: earliest and lates event found in each
%                      trial.
% NLXWinOffset ....... time added to the NLXWinEvents (actually added to NLXWin)
% ClearChannels ...... true: clear all existing channels, false: replace
%                      all existing ones

%% settings structure
P.AnalogChanLabel = {};% default: NSE name + NLXClusterNr
P.NLXWin = [];
P.NLXWinEvents = {};% default: earliest and latest event of trials
P.NLXWinOffset = [0 0];% default: 0
P.ClearChannels = false;
P = StructUpdate(P,varargin{:});

%% other settings
TimeDimDiff = (-6) - s.timeorder;
numTrials = size(s.events,2);

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

% AnalogChanLabel
if isempty(P.AnalogChanLabel)
    [NCSDir,NCSName,NCSExt] = fileparts(NCS.Path);
    P.AnalogChanLabel = {NCSName};
end

if P.ClearChannels
    s.analog = {};
    s.analogname = {};
    s.analogtime = {};
    s.analogunits = {};
    ChNr = 1;
else
    % replace existing ones 
    ChNr = 1;
    NumChan = spk_AnalogCheckChan(s);
    [isExistChan,ReplaceIndex] = ismember(P.AnalogChanLabel,s.analogname);
    if isExistChan
        ChNr = ReplaceIndex;
    else
        ChNr = NumChan+1;
        s.analogname{ChNr} = '';
        s.analogtime{ChNr} = [];
        s.analogunits{ChNr} = '';
        s.analogfreq(ChNr) = NaN;
    end
end

%% check sample frequency
currSF = unique(NCS.SF);
if length(currSF)==1
	s.analogfreq(ChNr) = currSF;
else
	error('inconsistent SF information in NCS file!');
end

%% loop trials and extract data
hwait = waitbar(0,'Extract samples from neuralynx NCS file ...');
Samples = cell(1,numTrials);
CurrTrialAlignBin = ones(1,numTrials).*NaN;
for i = 1:numTrials
    [xxxNCS,Samples{i},Times] = NLX_extractNCS(NCS,P.NLXWin(i,:));
    if isempty(Samples{i})
        Samples{i} = NaN;
        CurrTrialAlignBin(1,i) = 1;
    else
        Samples{i} = Samples{i}';
        Times = Times' .* (10^TimeDimDiff) - s.align(i);
        [AlignPrecision,CurrTrialAlignBin(1,i)] = min(abs(Times));
    end
    waitbar(i/numTrials,hwait);
end
close(hwait);

%% set SPK fields
s.analogname(ChNr) = P.AnalogChanLabel;
s.analogunits{ChNr} = 'digital';

% merge cells to matrix
AlignArray = [ones(numTrials,1) CurrTrialAlignBin' ones(numTrials,1)];
AlignDimension = 1;
[s.analog{ChNr},AlignBin]  = mergearrays(Samples,AlignDimension,AlignArray);
s.analogalignbin(ChNr) = AlignBin(2);

% compute timebins
nBins = size(s.analog{ChNr},2);
s.analogtime{ChNr} = (s.analogalignbin(ChNr)-1)*(-1)*(1000/s.analogfreq(ChNr)) : (1000/s.analogfreq(ChNr)) : (nBins-s.analogalignbin(ChNr))*(1000/s.analogfreq(ChNr));



    
    