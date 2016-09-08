function [v,t,i,terr] = spk_findAnalogEventBin(s,ChanName,EventLabel)

% returns analog data for a given event
% uses s.currenttrials. 
% v ...... [nChans x nTrials] analog value 
% t ...... [nChans x nTrials] event time 
% i ...... [nChans x nTrials] bin number  
% terr ... [nChans x nTrials] time error of bin in reference to event 

%% get the channel index
if nargin<2 || isempty(ChanName)
    if isempty(s.currentanalog);
        iChan = 1:size(s.analog,2);
    else
        iChan = s.currentanalog;
    end
else
    iChan = spk_findAnalog(s,ChanName);
end
nChan = length(iChan);


%% get time vector for this channel
for iCh = 1:nChan
    s.currentanalog = iChan(iCh);
    tVec{iCh} = spk_AnalogTimeVec(s);
end

%% set current trials
if isempty(s.currenttrials)
    s.currenttrials = 1:size(s.analog{iChan},1);
end
nTr = length(s.currenttrials);

%% get event index
iEv = strmatch(EventLabel,s.eventlabel,'exact');

%% loop trials and chans
v = zeros(nChan,nTr).*NaN;
t = zeros(nChan,nTr).*NaN;
i = zeros(nChan,nTr).*NaN;
for iCh = 1:nChan
    cnt = 0;
    for iTr = s.currenttrials
        cnt=cnt+1;
        if isempty(s.events{iEv,iTr})
            error('Can''t find event %s!!',EventLabel);
        elseif numel(s.events{iEv,iTr})>1
            error('Too many events of >%s<!!',EventLabel);
        end
        t(iCh,cnt) = s.events{iEv,iTr};
        [dummy,i(iCh,cnt)] = min(abs(tVec{iCh}-t(iCh,cnt)));
        terr(iCh,cnt) = tVec{iCh}(i(iCh,cnt))-t(iCh,cnt);
        v(iCh,cnt) = s.analog{iChan(iCh)}(iTr,i(iCh,cnt));
    end
end
        

        




    