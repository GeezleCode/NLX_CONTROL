function [x,T,bwidth,bwin] = spk_getAnalog(s,TimeWin,ChanName,Event)
% extracts analog data from the object.
%
% [x,T,bwidth,bwin] = spk_getAnalog(s,TimeWin,RemoveNaNs,ChanName,Event)
%
% TimeWin .... [lo hi] time window in units of s.timeorder, relative to
%              Event
% ChanName ... can be channel name or index, leave empty to use
%              s.currentanalog
% Event ...... char - event name, gets event timestamps as reference for
%              the time window.
%              column vector - reference time for time window, length must
%              be 1 or number of s.currenttrials
%              [] - reference is current alignment of object
%
% x .............. analog data [trials x bins] in cells per channel 
% T .............. time data [trials x bins]
% bwidth ......... temporal gap between bins
% bwin ........... bin boundaries of analog data
%
% if ther is only one channel x and T are converted to numerical arrays

%% if ChanName exists as input, overwrite s.currentanalog
if nargin>=3 && ~isempty(ChanName)
    if iscell(ChanName) || ischar(ChanName)
        s.currentanalog = spk_findAnalog(s,ChanName);
    elseif isnumeric(ChanName);
        s.currentanalog = ChanName;
    end
end
if isempty(s.currentanalog)
    s.currentanalog = 1:length(s.analog);
end
nChan = length(s.currentanalog);

%% get current trials
nTrTot = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:nTrTot;
end
nTr = length(s.currenttrials);

bwin = spk_AnalogEventWindow(s,Event,TimeWin);


%% loop channels
for iCh = 1:nChan
    cChNr = s.currentanalog(iCh);
    bwidth(iCh) = (1/s.analogfreq(cChNr))/(10^s.timeorder);
    blength{iCh} = diff(bwin(:,:,iCh),[],2)+1;
    
    x{iCh} = ones(nTr,max(blength{iCh})).*NaN;
    T{iCh} = ones(nTr,max(blength{iCh})).*NaN;
    
    t = spk_AnalogTimeVec(s,cChNr);

    %% get data
    for iTr = 1:nTr
        x{iCh}(iTr,1:blength{iCh}(iTr)) = s.analog{cChNr}(s.currenttrials(iTr),bwin(iTr,1,iCh):bwin(iTr,2,iCh));
        T{iCh}(iTr,1:blength{iCh}(iTr)) = t(1,bwin(iTr,1,iCh):bwin(iTr,2,iCh));% take time window of first trial!!
    end
    
end

if nChan==1
    x = x{1};
    T = T{1};
end

