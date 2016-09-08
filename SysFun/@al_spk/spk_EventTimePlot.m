function s = spk_EventTimePlot(s,Eventlabel,yLim,mode,varargin)

% plots events on an x time axis

% select all trials if none selected

error('UNDER CONSTRUCTION');

[out,s] = spk_CheckCurrentTrials(s,1);

[numEv,numTr] = size(s.events);

if isempty(Eventlabel)
	EventIndex = 1:numEv;
else
	EventIndex = find(ismember(s.eventlabel,Eventlabel));
end

if isempty(EventIndex)
	warning('No events to plot!');
end

e = s.events(EventIndex,s.trialselection);
[numEv,numTr] = size(e);
eNum = cellfun('length',e); 

switch upper(mode)
	case 'TRIALS'
		
	case 'MEAN'
		for i=1:numEv
			ci = (eNum(i,:)==1);
			cn = sum(ci);
			cat(2,e{i,ci});
		end
		
end
