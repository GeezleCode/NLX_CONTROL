function s = spk_Align(s,AlignValue,mode,DoAnalogAlign)

% align all time data, set s.align property
%
% function s = spk_align(s,Ta,mode)
%
% INPUT
% AlignValue ... numerical or charcter array. see mode
% mode 'Tabs'    [1] ..... aligntimes are absolut, SUBSTRACT from timedata,
%                       REPLACE s.align
% mode 'Trel'    [2] ..... aligntimes are relative, all time data is already aligned,
%                       substract from timedata and from s.align
% mode 'Event'   [3] ..... aligntimes is an event name, else as mode 2
% mode 'Reverse' [4] ..... reverse alignment. recreate absolute time data using s.align

numChan = size(s.spk,1);
numTrSPK = size(s.spk,2);
numEvents = size(s.events,1);
numAnalog = length(s.analog);
numTrials = spk_TrialNum(s);

s.currenttrials = [];

if nargin<4
    DoAnalogAlign = false;
end

%% backwards compatibility
if isnumeric(mode)
    switch mode
        case 0; mode='TABS';
        case 1; mode='TABS';
        case 2; mode='TREL';
        case 3; mode='EVENT';
        case 4; mode='REVERSE';
    end
end

%% switch align mode
switch upper(mode)
	case 'TABS'
        Ta = AlignValue;
		s.align = Ta;
	case 'TREL'
        Ta = AlignValue;
		s.align = s.align - Ta;
	case 'EVENT'
        s.alignevent = AlignValue;
		Ta = spk_getEvents(s,AlignValue);
        if any(cellfun('prodofsize',Ta)>1)
            error('Found more than one align event in a trial!!');
        end
        if any(cellfun('isempty',Ta))
            warning('Found trials missing the event "%s". Trial data will be set to NaN !!!',AlignValue);
            Ta(cellfun('isempty',Ta)) = {NaN};
        end
        Ta = cat(2,Ta{:});
        if ~isempty(s.align)
            s.align = s.align - Ta;
        else
            s.align = Ta;
        end
	case 'REVERSE'
		Ta = (-1)*s.align;
		s.align = zeros(1,numTrials);
end

%% EVENT data
for i = 1:numTrials
    for e = 1:numEvents
		s.events{e,i} = s.events{e,i} - Ta(i);
	end
end

%% SPIKE data
for i = 1:numTrSPK
    for k = 1:numChan
        s.spk{k,i} = s.spk{k,i} - Ta(i);
    end
end
	
%% ANALOG data
if numAnalog>0 && DoAnalogAlign
    hwait = waitbar(0,'Aligning analog data ...');
    for iACh = 1:numAnalog
        switch mode
            case 'EVENT'
                BinWidth = (1/s.analogfreq(iACh))/10^s.timeorder;
                NewAlignBin = s.analogalignbin(iACh) + round(Ta./BinWidth);
                [s.analog{iACh},s.analogalignbin(iACh)] = AlignMat(s.analog{iACh},NewAlignBin,2,1);
                nBins = size(s.analog{iACh},2);
                s.analogtime{iACh} = (s.analogalignbin(iACh)-1)*(-BinWidth) : BinWidth : (nBins-s.analogalignbin(iACh))*BinWidth;
            case 'REVERSE'
                s.analogfreq(iACh) = NaN;
                s.analogalignbin(iACh) = NaN;
                s.analog{iACh} = [];
                s.analogtime{iACh} = [];
            otherwise
                error('This alignment mode is not implemented for ANALOG data yet!');
        end
        waitbar(numAnalog/iACh);
    end
    close(hwait);
end
	

