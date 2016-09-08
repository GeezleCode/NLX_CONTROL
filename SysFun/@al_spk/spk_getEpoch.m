function [EpWin,AlignTimes,s] = spk_getEpoch(s,Ev,EvNr)

%---------------------------------------
% check input
%---------------------------------------
[EpNum,EpEdgeNum] = size(Ev);

%---------------------------------------
% trials
%---------------------------------------
TrialNum = spk_numtrials(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:TrialNum;
end
CurrTrialNum = length(s.currenttrials);

%---------------------------------------
% allocate output
%---------------------------------------
EpWin = ones(CurrTrialNum,2,EpNum).*NaN;
AlignTimes = ones(CurrTrialNum,1,EpNum).*NaN;

%---------------------------------------
%  lo
%---------------------------------------
EvIndex = spk_findeventlabel(s,Ev(:,1));
for i = 1:CurrTrialNum
    cLowEvents = s.events(EvIndex,s.currenttrials(i));
    if any(cellfun('prodofsize',cLowEvents)>1);
        error('multiple events');
    end
    cLowEvents(cellfun('isempty',cLowEvents)) = {NaN};
    EpWin(i,1,:) = permute(cat(1,cLowEvents{:}),[2 3 1]);
end
    
%---------------------------------------
%  hi
%---------------------------------------
for iEp = 1:EpNum
    if isnumeric(Ev{iEp,2})
        EpWin(:,[1 2],iEp) = [EpWin(:,1,iEp)+Ev{iEp,2}(1) EpWin(:,1,iEp)+Ev{iEp,2}(2)];
    elseif ischar(Ev{iEp,2})
        cEvIndex = spk_findeventlabel(s,Ev{iEp,2});
        for i = 1:CurrTrialNum
            cEv = s.events{cEvIndex,s.currenttrials(i)};
            if length(cEv)>1 & isempty(EvNr)
                warning(['Unexpected number of event ''' Ev{iEp,2} ''' in trial ' sprintf('%4.0f',i) '. Take earliest one.']);
                EpWin(i,2,iEp) = cEv(1);
            else
                EpWin(i,2,iEp) = cEv;
            end
                
        end
    end
end

%---------------------------------------
%  aligntimes
%---------------------------------------
AlignTimes(:,1) = s.align(s.currenttrials)';
