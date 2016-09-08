function [SatTrials,isSat] = spk_AnalogIsSaturated(s,DataThresh,SatBinNum,Ev1,Ev2,DoPlot)

% detects trials exceeding a range of analog values
% [s,SatTrials,isSat] = spk_AnalogIsSaturated(s,DataThresh,Ev1,Ev2,AllowPeaksFlag,DoPlot)
% INPUT
% DataThresh ... [lower boundary , upper boundary]
% SatBinNum .... number of consecutive bins consisting with criterion
% Ev1,Ev2 ...... Event Window
% DoPlot ....... plot detected analog data, one channel per figure
% OUTPUT
% SatTrials .... logical, index of saturated trials 
% isSat ........ logical, index of saturated bins 

if nargin<3
    Ev1='';Ev2='';DoPlot=true;AllowPeaksFlag=false;
end
SatTrials = false(0,0);

%% check analog channels
nCh = length(s.currentanalog);

%% loop channels
for iCh = 1:nCh
    ChNr = s.currentanalog(iCh);
    [nT,nB] = size(s.analog{ChNr});
    
    %% check maximum value
    MaxVal = max(s.analog{ChNr}(:));
    MinVal = min(s.analog{ChNr}(:));
    disp(['Check for saturated bins in channel Ch. ' num2str(ChNr) ' max: ' num2str(MaxVal) ' min: ' num2str(MinVal)]);

    %% detect saturated
    if isempty(DataThresh)
        iMin = IsSaturated(s.analog{ChNr}'.*(-1),SatBinNum);
        iMax = IsSaturated(s.analog{ChNr}',SatBinNum);
    elseif length(DataThresh) == 2
        iMin = IsClipped(s.analog{ChNr}'.*(-1),DataThresh(1).*(-1),SatBinNum);
        iMax = IsClipped(s.analog{ChNr}',DataThresh(2),SatBinNum);
    end
    isSat{iCh} = iMin'|iMax';
    
    %% set bins outside time window back to zeros
    if ~isempty(Ev1) && ~isempty(Ev2) && any(isSat{iCh}(:))
        
        if ~iscell(Ev1)&&~iscell(Ev2)
            Ev1 = {Ev1};Ev2 = {Ev2};
        end
        
        isWinSat = false(size(isSat{iCh}));
        for iWin = 1:length(Ev1)
            [bWin,tWin,t] = spk_AnalogEventWindow(s,Ev1{iWin},Ev2{iWin});
            isWin = false(1,nB);
            for iTr = 1:nT
                isWinSat(iTr,bWin(iTr,1):bWin(iTr,2)) = isSat{iCh}(iTr,bWin(iTr,1):bWin(iTr,2));
            end
        end
        isSat{iCh} = isWinSat;
    end
    
    %% check for any saturations in this trial
    SatTrials(:,iCh) = any(isSat{iCh},2);
    
    %% plot this channel
    if DoPlot && any(isSat{iCh}(:)) 
        n = sum(SatTrials(:,iCh));
        t = spk_AnalogTimeVec(s,ChNr);
        figure
        line(repmat(t',[1 n]),[s.analog{ChNr}(SatTrials(:,iCh),:)+repmat([0:n-1]',[1 nB])*DataThresh(2)]','color','b');
    end
    
end

function i = IsSaturated(M,SatBinNum)
[nBins,nRuns] = size(M);
mx = max(M(:));% assumes common maximum for whole data matrix
i = M>=mx;
for iB = 1:nBins-(SatBinNum-1)
    i(iB,~all(   i(iB:iB+(SatBinNum-1),:)   ,1)) = false;
end

function i = IsClipped(M,ClipVal,AllowPeaksFlag)

% returns index of saturated values
% data series in columns

dims = size(M);
i = false(size(M));
i = M>=ClipVal;

if AllowPeaksFlag
    di = diff(i,[],1);
    PeakIndex = (cat(1,zeros(1,dims(2)),di)>0 & cat(1,di,zeros(1,dims(2)))<0);
    i(PeakIndex) = false;
end

