function [s,TrialNr] = spk_addTrialData(s,TrialNr,varargin)

% Add trial data for several datatypes
%
% [s,TrialNr] = spk_AddTrialData(s,TrialNr,'DataLabel1',Data1, ...)
%
% TrialNr ..... if [] pads trial data to end of arrays
% Data ........ Data Label/Value (char/cell) pairs
% 
% DataLabel: 
% 'spk' ......... {1} {SpikeTimes} nCh x n       {2} [ChannelIndex]
% 'analog' ...... {1} {n x SampleVector} 1 x nCh {2} [ChannelIndex] {3} [AlignBin]
% 'events' ...... {1} {EventTimes} nEv x 1       {2} [EventIndex]
% 'align' ....... {1} [aligntimes] 1 x n
% 'trialcode' ... {1} [trialcodes] 1 x n         {2} [TrialcodeLabelIndex]
% 'stimulus' .... {1} [] 1 x n

%% check input
if rem(length(varargin),2)~= 0
     error('Arguments must be Property/Value pairs !');
end
numProp = length(varargin)./2;

if isempty(TrialNr)
    TrialNr = spk_numtrials(s);
    TrialNr = TrialNr+1;
end

%% spk
isCurrData = strcmp(varargin(1:2:end),'spk');
if any(isCurrData)
    cDataPacketIndex = (find(isCurrData)-1)*2+1;
    cDataPacketNum = length(varargin{cDataPacketIndex});
    if cDataPacketNum>1
        cChanIndex = varargin{cDataPacketIndex}{2};
        s.spk(cChanIndex,TrialNr) = varargin{cDataPacketIndex}{1};
    else
        s.spk(:,TrialNr) = varargin{cDataPacketIndex}{1};
    end
end    
   
%% analog
isCurrData = strcmp(varargin(1:2:end),'analog');
if any(isCurrData)
    cDataPacketIndex = (find(isCurrData)-1)*2+1;
    cChanIndex = varargin{cDataPacketIndex}{2};
    for iCh = 1:length(cChanIndex)
        s.analogalignbin{cChanIndex(iCh)} = mergearrays( ...
            [s.analog(cChanIndex(iCh)) varargin{cDataPacketIndex}(1)], ...
            1, ...
            [1 s.analogalignbin(cChanIndex(iCh)) 1; 1 varargin{cDataPacketIndex}{3} 1], ...
            {TrialNr});
    end
end    

%% events
isCurrData = strcmp(varargin(1:2:end),'events');
if any(isCurrData)
    cDataPacketIndex = (find(isCurrData)-1)*2+1;
    cDataPacketNum = length(varargin{cDataPacketIndex});
    if cDataPacketNum>1
        cEvIndex = varargin{cDataPacketIndex}{2};
        s.events(cEvIndex,TrialNr) = varargin{cDataPacketIndex}{1};
    else
        s.events(:,TrialNr) = varargin{cDataPacketIndex}{1};
    end
end    

%% align
isCurrData = strcmp(varargin(1:2:end),'align');
if any(isCurrData)
    cDataPacketIndex = (find(isCurrData)-1)*2+1;
    s.align(:,TrialNr) = varargin{cDataPacketIndex}{1};
end    

%% trialcode
isCurrData = strcmp(varargin(1:2:end),'trialcode');
if any(isCurrData)
    cDataPacketIndex = (find(isCurrData)-1)*2+1;
    cDataPacketNum = length(varargin{cDataPacketIndex});
    if cDataPacketNum>1
        cEvIndex = varargin{cDataPacketIndex}{2};
        s.trialcode(cEvIndex,TrialNr) = varargin{cDataPacketIndex}{1};
    else
        s.trialcode(:,TrialNr) = varargin{cDataPacketIndex}{1};
    end
end    

%% stimulus
isCurrData = strcmp(varargin(1:2:end),'stimulus');
if any(isCurrData)
    cDataPacketIndex = (find(isCurrData)-1)*2+1;
    s.stimulus(:,TrialNr) = varargin{cDataPacketIndex}{1};
end    

%%
TrialNr = spk_TrialNum(s);