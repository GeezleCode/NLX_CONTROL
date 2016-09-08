function spike = nlx_control_BuffResetSpike(spike,time)

ObjNum = length(spike);

for i = 1:ObjNum

	if nargin<2
	    spike(i).TimeStamp(:) = 0;
	    spike(i).Channel(:) = 0;
	    spike(i).Cell(:) = 0;
	    spike(i).Index = 0;
	elseif time>0
	    KeepIndex = find(spike(i).TimeStamp>=time);
	    KeepIndexN = length(KeepIndex);
	    if KeepIndexN == 0
	        spike(i).TimeStamp(:) = 0;
	        spike(i).Channel(:) = 0;
	        spike(i).Cell(:) = 0;
	        spike(i).Index = 0;
	    else
	        spike(i).TimeStamp(1:KeepIndexN) = spike(i).TimeStamp(KeepIndex);
	        spike(i).Channel(1:KeepIndexN) = spike(i).Channel(KeepIndex);
	        spike(i).Cell(1:KeepIndexN) = spike(i).Cell(KeepIndex);
	        
	        spike(i).TimeStamp(KeepIndexN:end) = 0;
	        spike(i).Channel(KeepIndexN:end) = 0;
	        spike(i).Cell(KeepIndexN:end) = 0;
	        spike(i).Index = KeepIndexN;
	    end
	        
	end
end
