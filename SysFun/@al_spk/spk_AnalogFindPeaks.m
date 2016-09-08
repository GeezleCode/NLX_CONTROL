function [maxT,maxV,minT,minV,platT,platV,mxi,mni,pli] = spk_AnalogFindPeaks(s,TW,ChanName,endflag)

% finds extrem values as well as plateaus
% [maxT,maxV,minT,minV,platT,platV,mxi,mni,pli] = spk_AnalogFindPeaks(s,TW,ChanName,endflag)
%
%


%% get the channel index
iChan = spk_FindAnalog(s,ChanName);
s.currentanalog = iChan;

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
nTr = length(s.currenttrials);

%% get window
tVec = spk_AnalogTimeVec(s);
if ~isempty(TW)
    BW = find(tVec>=TW(1)&tVec<=TW(2));
else
    BW = 1:length(tVec);
end

%% find peaks and valleys
for iTr=1:nTr
    Y = s.analog{iChan}(s.currenttrials(iTr),BW);
    dY = diff(Y,1,2);
    not_plateau_ind = find(dY~=0);
    mxi{iTr} = find( ([dY(:,not_plateau_ind) 0]<0) & ([0 dY(:,not_plateau_ind)]>0) );
    mni{iTr} = find( ([dY(:,not_plateau_ind) 0]>0) & ([0 dY(:,not_plateau_ind)]<0) );
    mxi{iTr} = not_plateau_ind(mxi{iTr});
    mni{iTr} = not_plateau_ind(mni{iTr});
    
    if endflag
        if Y(1)>Y(2);mxi{iTr} = [1 mxi{iTr}];end
        if Y(end)>Y(end-1);mxi{iTr} = [mxi{iTr} length(Y)];end
        if Y(1)<Y(2);mni = [1 mni{iTr}];end
        if Y(end)<Y(end-1);mni = [mni{iTr} length(Y)];end
    end
    
    
    mxi{iTr} = mxi{iTr}+BW(1)-1;
    mni{iTr} = mni{iTr}+BW(1)-1;
    
    maxT{iTr} = tVec(mxi{iTr});
    maxV{iTr} = s.analog{iChan}(s.currenttrials(iTr),mxi{iTr});
    minT{iTr} =  tVec(mni{iTr});
    minV{iTr} = s.analog{iChan}(s.currenttrials(iTr),mni{iTr});
    
    % get plateau starts and ends
    if ~any(dY==0)
        pli{iTr} = [];
        platT{iTr} = [];
        platV{iTr} = [];
    else
        pli{iTr}(:,1) = find(diff([0 dY==0],1,2)==1);
        pli{iTr}(:,2) = find(diff([dY==0 0],1,2)==-1) + 1;
        pli{iTr} = pli{iTr}+BW(1)-1;
        platT{iTr} =  tVec(pli{iTr});
        platV{iTr} = s.analog{iChan}(s.currenttrials(iTr),pli{iTr}(:,1));
    end

end

