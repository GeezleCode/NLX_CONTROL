function s = spk_NLX_readNCS(s,NCS,NLXWin,analogname,WinMode,AddChannelFlag)

% reads spike data from a neuralynx *.nse file
%
% NCS ..................... NCS structure, see Neuralynx Tools
% NLXWin ............. time window for every trial in NLX time (microsec), trials
%                           along rows.
% analogname .............. tag for this channel

if nargin<6
	AddChannelFlag = 0;
	if nargin<5
		WinMode = 'ABS';
		if nargin<4
			analogname = 'CSC1';
		end;end;end

TimeDimDiff = (-6) - s.timeorder;

% read into SPK object
% get the analog index
numTrials = size(s.events,2);

if AddChannelFlag
	AnalogIndex = length(s.analog)+1;
else
	AnalogIndex = 1;
	s.analog = {};
	s.analogname = {};
	s.analogtime = {};
end

s.analog{AnalogIndex} = [];
s.analogname{AnalogIndex} = analogname;
s.analogtime{AnalogIndex} = [];
s.analogunits{AnalogIndex} = 'digital';

% check sample frequency
currSF = unique(NCS.SF);
if length(currSF)==1
	s.analogfreq(AnalogIndex) = currSF;
else
	error('inconsistent SF information in NCS file!');
end

% loop trials
hwait = waitbar(0,'Extract samples from neuralynx NCS file ...');
for i = 1:numTrials
%     if i==159
%         disp('ok');
%     end
    
	% extract the ncs data
	switch upper(WinMode)
		case 'REL'
			if size(NLXWin,1)>1
				[xxxNCS,Samples,Times] = NLX_extractNCS(NCS,(NLXWin(i,:) + s.align(i))./(10^TimeDimDiff));
			else
				[xxxNCS,Samples,Times] = NLX_extractNCS(NCS,(NLXWin + s.align(i))./(10^TimeDimDiff));
			end
		case 'ABS'
			if size(NLXWin,1)>1
				[xxxNCS,Samples,Times] = NLX_extractNCS(NCS,NLXWin(i,:));
			else
				error('');
			end
			
	end
	Samples = Samples';
	Times = Times';
	Times = Times .* (10^TimeDimDiff) - s.align(i);
	[currAlignTime,CurrTrialAlignBin] = min(abs(Times));
		
	% add to analog data
	if isempty(s.analog{AnalogIndex})
		s.analog{AnalogIndex} = Samples;
		s.analogalignbin(AnalogIndex) = CurrTrialAlignBin;
	else
		[s.analog{AnalogIndex},AlignBin]  = mergearrays([s.analog(AnalogIndex) {Samples}],1,[1 s.analogalignbin(AnalogIndex) 1;1 CurrTrialAlignBin 1]);
		s.analogalignbin(AnalogIndex) = AlignBin(2);
    end
    
% 	fprintf(1,'%03.0f %5.0f %5.0f\n',i,length(Samples),size(s.analog{AnalogIndex},2));
	
    
    waitbar(i/numTrials,hwait);
end

nBins = size(s.analog{AnalogIndex},2);
s.analogtime{AnalogIndex} = (s.analogalignbin(AnalogIndex)-1)*(-1)*(1000/s.analogfreq(AnalogIndex)) : (1000/s.analogfreq(AnalogIndex)) : (nBins-s.analogalignbin(AnalogIndex))*(1000/s.analogfreq(AnalogIndex));
    
close(hwait);

    
    