classdef nlx_control_SEBuffer
    properties
        Name
        TimeStamp
        Channel
        Cell
        RingBufferIndex
        
        Flush = false;
        LastFlush
        
        FlushTime% neuralynx time in microsec indicating the next flush
        FlushInterval% sec to microsec
        FlushINCount
        FlushOUTCount
        FlushPauseTime
        FlushLoTime
        FlushHiTime
        FlushEcho
        
        % use for requesting NetCom client data 
        NCC_Time
        NCC_Time_Ptr
        NCC_Chan
        NCC_Chan_Ptr
        NCC_Cell
        NCC_Cell_Ptr
        NCC_Feat
        NCC_Feat_Ptr
        NCC_Data
        NCC_Data_Ptr
        NCC_NReturned
        NCC_NReturned_Ptr
        NCC_NDropped
        NCC_NDropped_Ptr
    end
    
    methods
        
        function SE = nlx_control_SEBuffer(SEObj,nRec,FlushInterval)
            % constructor for the nlx_control_SEBuffer class
            if nargin<1
                nRec = 5000;
                FlushInterval = 0.1;% in seconds
            end
            SE.Name = SEObj;
            SE.TimeStamp = zeros(nRec,1);
            SE.Channel = zeros(nRec,1);
            SE.Cell = zeros(nRec,1);
            SE.RingBufferIndex = zeros(1,1);
            SE.LastFlush = 0;

            
            SE.FlushTime = 0;% neuralynx time in microsec indicating the next flush
            SE.FlushInterval = FlushInterval .* 1000000;% sec to microsec
            SE.FlushINCount = 0;
            SE.FlushOUTCount = 0;
            SE.FlushPauseTime = 0;
            SE.FlushLoTime = 0;
            SE.FlushHiTime = 0;
            SE.FlushEcho = false;

            
            % get NetCom client properties
            succ = libisloaded('MatlabNetComClient');
            if succ == 0;error('NetCom library is not loaded!');end
            bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
            spikeSampleWindowSize = calllib('MatlabNetComClient', 'GetSpikeSampleWindowSize');
            maxSpikeFeatures = calllib('MatlabNetComClient', 'GetMaxSpikeFeatures');
            numSubChannels = 1;
            
            %Clear out all of the return values and preallocate space for the variables
            SE.NCC_Time = zeros(1,bufferSize);
            SE.NCC_Chan = zeros(1,bufferSize);
            SE.NCC_Cell = zeros(1,bufferSize);
            SE.NCC_Feat = zeros(1,maxSpikeFeatures * bufferSize);
            SE.NCC_Data = zeros(1,(numSubChannels * spikeSampleWindowSize * bufferSize) );
            SE.NCC_NReturned = 0;
            SE.NCC_NDropped = 0;

            %setup the ref pointers for the function call
            SE.NCC_Time_Ptr = libpointer('int64PtrPtr', SE.NCC_Time);
            SE.NCC_Chan_Ptr = libpointer('int32PtrPtr', SE.NCC_Chan);
            SE.NCC_Cell_Ptr = libpointer('int32PtrPtr', SE.NCC_Cell);
            SE.NCC_Feat_Ptr = libpointer('int32PtrPtr', SE.NCC_Feat);
            SE.NCC_Data_Ptr = libpointer('int16PtrPtr', SE.NCC_Data);
            SE.NCC_NReturned_Ptr = libpointer('int32Ptr', SE.NCC_NReturned);
            SE.NCC_NDropped_Ptr = libpointer('int32Ptr', SE.NCC_NDropped);
        end
        
        function s = SE_BufferSize(SE)
            s = size(SE.TimeStamp,1);
        end
        
        function SE = SE_Flush(SE,SEObjCells,logfid)
            
            % get data stream
            if ~SE.Flush
                fprintf(1,'%s is not ready to flush. Set ''Flush'' property to >true<!\n',SE.Name);
                return;
            end
            [succ,FlushTime] = NlxSendCommand('-GetTimestamp');
            [succ,SEObjName,SE.NCC_Time,SE.NCC_Chan,SE.NCC_Cell,SE.NCC_Feat,SE.NCC_Data,SE.NCC_NReturned,SE.NCC_NDropped] = calllib('MatlabNetComClient', 'GetNewSEData', ...
                SE.Name,SE.NCC_Time_Ptr,SE.NCC_Chan_Ptr,SE.NCC_Cell_Ptr,SE.NCC_Feat_Ptr,SE.NCC_Data_Ptr,SE.NCC_NReturned_Ptr,SE.NCC_NDropped_Ptr);
            
            SE.LastFlush = sscanf(FlushTime{1},'%d');

            % put data in ringbuffer
            if SE.NCC_NReturned>0
                nTot = SE_BufferSize(SE);
                
                Spikeidx = 1:SE.NCC_NReturned;
                
                % pick cell/cluster
                if ~isempty(SEObjCells)
                    Spikeidx = Spikeidx(ismember(SE.NCC_Cell(Spikeidx),SEObjCells));
                    if isempty(Spikeidx);return;end
                    Ridx = 1:length(Spikeidx);
                else
                    Ridx = Spikeidx;
                end
                
                % load into ringbuffer
                RBidx = Ridx + SE.RingBufferIndex;
                while any(RBidx>nTot)
                    RBidx(RBidx>nTot) = RBidx(RBidx>nTot)-nTot;
                end
                SE.RingBufferIndex = RBidx(end);
                SE.TimeStamp(RBidx) = SE.NCC_Time(Ridx);
                SE.Channel(RBidx) = SE.NCC_Chan(Ridx);
                SE.Cell(RBidx) = SE.NCC_Cell(Ridx);
            end

            if SE.FlushEcho&&nargin<3
                logfid = 1;
            end
            if SE.FlushEcho
                fprintf(logfid,'SE_Flush::\t%s\t%4.0f\t%4.0f\t%4.0f\n',SE.Name,SE.NCC_NReturned,SE.NCC_NDropped,SE.RingBufferIndex);
            end
                
        end
        
        function i = SE_findSpike(SE,Win,Cell)
            if ~isempty(Win)&&~isempty(Cell)
                i = find(SE.TimeStamp>=Win(1) & SE.TimeStamp<=Win(2) & ismember(SE.Cell,Cell));
            elseif isempty(Win)&&~isempty(Cell)
                i = find(ismember(SE.Cell,Cell));
            elseif ~isempty(Win)&&isempty(Cell)
                i = find(SE.TimeStamp>=Win(1) & SE.TimeStamp<=Win(2));
            end
        end


    end
    
    
end

