function s = spk_cat(s,varargin)

% concatenation of @al_spk objects


FileNum = length(varargin);
for i = 1:FileNum
    total = spk_numtrials(varargin{i});
end
currTrialNumadded = 0;

% check analog sample frequency
SFs = unique(cat(2,s.analogfreq,varargin{i}.analogfreq));
if length(SFs)>1;error('Different sampling frequency');end


hwait = waitbar(0,'merge @al_spk objects...');
for i = 1:FileNum;
	s.version = [];
	s.name = '';
	s.tag  = '';
	s.comment  = '';
	s.subject = '';
	s.file = '';
	s.date = '';

	s.currenttrials = [];
	s.stimulus = [];
	s.userdata = [];
	s.binwidth = [];
	s.timewin = [];
	s.plotwin = [];
	s.analysewin = [];% regions of interest, single windows for each trial in rows
	s.baselinewin = [];

	% spike data ------------------------------------------------------
	s.unittype = '';
	s.currentchan = [];
	s.chancolor = [];
	s.timeorder = varargin{i}.timeorder;

	if isempty(s.channel) & isempty(s.spk)
		s.channel = varargin{i}.channel;
		s.spk = varargin{i}.spk;
	else
		oldTrialNum = size(s.spk,2);
		newTrialNum = size(varargin{i}.spk,2);
		[TF,LOC] = ismember(varargin{i}.channel,s.channel);
		s.channel = cat(1,s.channel,varargin{i}.channel(~TF));
		spkToAdd = cell(size(s.spk,1),newTrialNum);
        s.spk = cat(1,s.spk,cell(length(find(~TF)),oldTrialNum));
        for j = 1:length(varargin{i}.channel)
            if TF(j)
                spkToAdd(LOC(j),:) = varargin{i}.spk(j,:);
            end
        end
        spkToAdd = cat(1,spkToAdd,varargin{i}.spk(~TF,:));
        s.spk = cat(2,s.spk,spkToAdd);
    end
    
	% analog data ------------------------------------------------------
    s.currentanalog = [];
    if isempty(s.analog)
        s.analog = varargin{i}.analog;
        s.analogname = varargin{i}.analogname;
        s.analogtime = varargin{i}.analogtime; 
        s.analogfreq = varargin{i}.analogfreq;
        s.analogalignbin = varargin{i}.analogalignbin;
    else
        for k=1:length(s.analog)
            [s.analog{k},AlignBin]  = mergearrays([s.analog(k) varargin{i}.analog(k)],1,[1 s.analogalignbin(k) 1;1 varargin{i}.analogalignbin(k) 1]);
            s.analogalignbin(k) = AlignBin(2);
        end
        
    end
	
	% events ---------------------------------------------------------------
	s.eventcolors = [];
	s.eventmode = '';
	
	if isempty(s.eventlabel) & isempty(s.events)
		s.eventlabel = varargin{i}.eventlabel;
		s.events = varargin{i}.events;
	else
		oldTrialNum = size(s.events,2);
		newTrialNum = size(varargin{i}.spk,2);
		[TF,LOC] = ismember(varargin{i}.eventlabel,s.eventlabel);
		s.eventlabel = cat(2,s.eventlabel,varargin{i}.eventlabel(~TF));
		eventsToAdd = cell(size(s.events,1),newTrialNum);
		s.events = cat(1,s.events,cell(length(find(~TF)),oldTrialNum));
		for j = 1:length(varargin{i}.eventlabel)
			if TF(j)
				eventsToAdd(LOC(j),:) = varargin{i}.events(j,:);
			end
		end
		eventsToAdd = cat(1,eventsToAdd,varargin{i}.events(~TF,:));
		s.events = cat(2,s.events,eventsToAdd);
	end

	% align ---------------------------------------------------------------
	s.alignevent = '';
	s.align = cat(2,s.align,varargin{i}.align);
	
	% trialcode  ---------------------------------------------------------------
	if isempty(s.trialcodelabel) & isempty(s.trialcode)
		s.trialcodelabel = varargin{i}.trialcodelabel;
		s.trialcode = varargin{i}.trialcode;
	else
		oldTrialNum = size(s.trialcode,2);
		newTrialNum = size(varargin{i}.spk,2);
		[TF,LOC] = ismember(varargin{i}.trialcodelabel,s.trialcodelabel);
		s.trialcodelabel = cat(2,s.trialcodelabel,varargin{i}.trialcodelabel(~TF));
		trialcodeToAdd = zeros(size(s.trialcode,1),newTrialNum).*NaN;
		s.trialcode = cat(1,s.trialcode,zeros(length(find(~TF)),oldTrialNum).*NaN);
		for j = 1:length(varargin{i}.trialcodelabel)
			if TF(j)
				trialcodeToAdd(LOC(j),:) = varargin{i}.trialcode(j,:);
			end
		end
		trialcodeToAdd = cat(1,trialcodeToAdd,varargin{i}.trialcode(~TF,:));
		s.trialcode = cat(2,s.trialcode,trialcodeToAdd);
	end

	% add merge info  ---------------------------------------------------------------
	MergeObjectNrIndex = strmatch(upper('MergedObjectNr'),upper(s.trialcodelabel));
	if isempty(MergeObjectNrIndex)
		MergeObjectNrIndex = size(s.trialcodelabel,2)+1;
		s.trialcodelabel(MergeObjectNrIndex) = {'MergedObjectNr'};
	end
	s.trialcode(MergeObjectNrIndex,size(s.trialcode,2)-size(varargin{i}.trialcode,2)+1 : size(s.trialcode,2)) = i;
		
	
	waitbar(i/FileNum,hwait);
end
close(hwait);
return

