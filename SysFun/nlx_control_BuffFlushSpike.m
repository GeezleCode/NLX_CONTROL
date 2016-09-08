function spike = nlx_control_BuffFlushSpike(cheetah,cheetahObj,spike,LOGfid)

% Flushes the Neuralynx spike buffer.

if nargin<4
    LOGfid = [];
end

ObjNum = length(cheetahObj);

for i = 1:ObjNum
    
	% reset fields
	spike(i).FlushINCount = 0;
	spike(i).FlushOUTCount = 0;
	spike(i).FlushPauseTime = 0;

    if ~isempty(LOGfid)
        fprintf(LOGfid,'%2.0f\t%12.0f\t%12.0f\t%12.0f\t%12.0f\t%4.0f', ...
            i,spike(i).FlushLoTime,spike(i).FlushHiTime,spike(i).FlushHiTime-spike(i).FlushLoTime,spike(i).RingBuffer(1),spike(i).Index);
    end

    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	% read the cheetah buffer one spike at the time
	% empty cheetah buffer is indicated by -1
	while spike(i).RingBuffer(1)<=spike(i).FlushHiTime
	    
	    % cheetah buffer is NOT empty
	    % read the timestamps
	    if spike(i).RingBuffer(1)>=0
	        spike(i).FlushPauseTime = 0;% reset the max. pause time
	        
	        % check the times of the timestamps
            if spike(i).RingBuffer(1) < spike(i).FlushLoTime
	        	% timestamp is too early, count as nonvalid
	            spike(i).FlushOUTCount = spike(i).FlushOUTCount + 1;
                
            elseif (spike(i).RingBuffer(1) >= spike(i).FlushLoTime) & (spike(i).RingBuffer(1) <= spike(i).FlushHiTime)
	            % timestamp is in time window count as valid
	            spike(i).FlushINCount = spike(i).FlushINCount + 1;
	            spike(i).Index = spike(i).Index+1;% increase the index of the current spike
	            if spike(i).Index>length(spike(i).TimeStamp)
	                spike(i).Index = 1;
	                disp(['SPIKE FLUSH ' cheetahObj{i} ' - overflow']);
	            end
	            
	            spike(i).TimeStamp(spike(i).Index) = spike(i).RingBuffer(1);
	            spike(i).Channel(spike(i).Index) = spike(i).RingBuffer(2);
	            spike(i).Cell(spike(i).Index) = spike(i).RingBuffer(3);
	            
	        end
	    end
	    
	    spike(i).RingBuffer = invoke(cheetah,'GetSpikeDataAsDouble',cheetahObj{i});
	    
        % if cheetah buffer is empty
        if spike(i).RingBuffer(1)<0
            break;
        end
    end
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    %::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
    if ~isempty(LOGfid)
        fprintf(LOGfid,'%4.0f\t%4.0f\t%12.0f\t%4.0f\n',spike(i).FlushINCount,spike(i).FlushOUTCount,spike(i).RingBuffer(1),spike(i).Index);
    end
    
end
