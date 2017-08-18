function s = spk_align(s,aligntimes,mode)

% align all time data
%
% function s = spk_align(s,aligntimes,mode)
%
% INPUT
% aligntimes ... numerical or charcter array. see mode
% mode [1] ..... aligntimes are absolut, substract from timedata, replace s.align
% mode [2] ..... aligntimes are relative, all time data is already aligned,
%                substract from timedata and from s.align
% mode [3] ..... aligntimes is an event name, else as mode 2
% mode [4] ..... reverse alignment. recreate absolute time data using s.align

numChan = size(s.spk,1);
numSPK = size(s.spk,2);
numEvents = size(s.events,1);
numAnalog = length(s.analog);
numTrials = spk_TrialNum(s);

%% switch align mode
switch mode
	case 1
		s.align = aligntimes;
	case 2
		s.align = s.align - aligntimes;
	case 3
		aligntimes = spk_getEvents(s,aligntimes);
        if any(cellfun('prodofsize',aligntimes)>1)
            error('Found more than one align event in a trial!!');
        end
        if any(cellfun('isempty',aligntimes))
            warning('Align event is non existent!');
            aligntimes(cellfun('isempty',aligntimes)) = {NaN};
        end
        aligntimes = cat(2,aligntimes{:});
        if ~isempty(s.align)
            s.align = s.align - aligntimes;
        else
            s.align = aligntimes;
        end
	case 4
		aligntimes = (-1)*s.align;
		s.align = [];
end

%% EVENT data
for i = 1:numTrials
    for e = 1:numEvents
		s.events{e,i} =  s.events{e,i} - aligntimes(i);
	end
end

%% SPIKE data
for i = 1:numSPK
    for k = 1:numChan
        s.spk{k,i} = s.spk{k,i} - aligntimes(i);
    end
end
	
%% ANALOG data
switch mode
    case 1
        warning('This alignment mode is not implemented for ANALOG data yet!');
    case {2 3}
        for a = 1:numAnalog
            binwidth = (1/s.analogfreq(a))/10^s.timeorder;
            alignbins = s.analogalignbin(a) + round(aligntimes./binwidth);
            [s.analog{a},s.analogalignbin(a)] = AlignMat(s.analog{a},alignbins,2,1);
            nBins = size(s.analog{a},2);
            s.analogtime{a} = (s.analogalignbin(a)-1)*(-binwidth) : binwidth : (nBins-s.analogalignbin(a))*binwidth;
        end
    case 4
        %             s.analogtime{a} = s.analogtime{a}
        warning('This alignment mode is not implemented for ANALOG data yet!')
end
	

