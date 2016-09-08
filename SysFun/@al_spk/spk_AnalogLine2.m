function [h,s] = spk_AnalogLine2(s,YSegment,Mapping,varargin)

% plots the current trials of the current ananlog channel
% YSegment ... [Ylow Yhi]
% mapping ... zoom factor of data

NumcTr = length(s.currenttrials);
cAi = s.currentanalog(1);
[nTr,numSamples] = size(s.analog{cAi});
TimeData = spk_AnalogTimeVec(s);

if ~isempty(YSegment) & ~isempty(Mapping)
	TrSpace = (YSegment(2)-YSegment(1))/(NumcTr);
	YData = repmat([YSegment(1)+TrSpace*0.5:TrSpace:YSegment(2)-TrSpace*0.5],[numSamples,1]);
	h = line( ...
		repmat(TimeData,[length(s.currenttrials) 1])', ...
		s.analog{cAi}(s.currenttrials,:)'.*Mapping + YData, ...
		varargin{:});
else
	h = line( ...
		repmat(TimeData,[length(s.currenttrials) 1])', ...
		s.analog{cAi}(s.currenttrials,:)', ...
		varargin{:});
end


