function out = spk_AnalogSaturation(s,DataLimit,TimeWin,RemoveTrialsFlag)

% detects/removes trials that exceed a range of data
% [SatTrials,s] = spk_AnalogSaturation(s,DataLimit,TimeWin,RemoveTrialsFlag)

SatTrials = [];

% check analog channels
AnaCurr = s.currentanalog;
AnaNum = length(AnaCurr);
if AnaNum<1;return;end


% check trials for saturation in any channels
for i = 1:AnaNum
	[nT,nB] = size(s.analog{AnaCurr(i)});
    
    SatBins = (s.analog{AnaCurr(i)}<=DataLimit(1) | s.analog{AnaCurr(i)}>=DataLimit(2));
            
    if ~isempty(TimeWin)
        TimeData = spk_analogtimematrix(spk_set(s,'currentanalog',s.currentanalog(i)));
        if size(TimeData,2)~=size(s.analog{AnaCurr(i)},2);error('time conflict!');end
        % set bins outside time window back to zeros
        SatBins(:,TimeData<TimeWin(1) | TimeData>TimeWin(2)) = 0;
    end
    
	SatTrials(:,i) = any(SatBins,2);
end

if RemoveTrialsFlag & any(SatTrials(:))
	[s,c] = spk_cuttrials(s,any(SatTrials,2));
end

if RemoveTrialsFlag
	out = s;
else
	out = SatTrials;
end

