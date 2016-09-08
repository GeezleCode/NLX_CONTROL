classdef nlx_control_CSCBuffer
    properties
        Name
        Data
        TimeStamp
        ChannelNr
        SamplingFreq
        NumValidSamples
        RingBufferIndex
        maxCSCSamples
        
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
        NCC_dataArray
        NCC_timeStampArray
        NCC_channelNumberArray
        NCC_samplingFreqArray
        NCC_numValidSamplesArray
        NCC_numRecordsReturned
        NCC_numRecordsDropped
        NCC_dataArrayPtr
        NCC_timeStampArrayPtr
        NCC_channelNumberArrayPtr
        NCC_samplingFreqArrayPtr
        NCC_numValidSamplesArrayPtr
        NCC_numRecordsReturnedPtr
        NCC_numRecordsDroppedPtr
        
    end
    
    methods
        
        function CSC = nlx_control_CSCBuffer(CSCObj,nRec,FlushInterval)
            % constructor for the nlx_control_SEBuffer class
            if nargin<1
                nRec = 1000;
                FlushInterval = 0.1;% in seconds
            end
            CSC.Name = CSCObj;
            CSC.Data = zeros(512,nRec);
            CSC.TimeStamp = zeros(512,nRec);
            CSC.ChannelNr = zeros(nRec,1);
            CSC.SamplingFreq = zeros(nRec,1);
            CSC.NumValidSamples = zeros(nRec,1);
            CSC.RingBufferIndex = zeros(1,1);
            CSC.LastFlush = 0;
            
            CSC.FlushTime = 0;% neuralynx time in microsec indicating the next flush
            CSC.FlushInterval = FlushInterval .* 1000000;% sec to microsec
            CSC.FlushINCount = 0;
            CSC.FlushOUTCount = 0;
            CSC.FlushPauseTime = 0;
            CSC.FlushLoTime = 0;
            CSC.FlushHiTime = 0;
            CSC.FlushEcho = false;

            
            % get NetCom client properties
            succ = libisloaded('MatlabNetComClient');
            if succ == 0;error('NetCom library is not loaded!');end
            bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
            CSC.maxCSCSamples = calllib('MatlabNetComClient', 'GetMaxCSCSamples');

            
            %Clear out all of the return values and preallocate space for the variables
            CSC.NCC_dataArray = zeros(1,(CSC.maxCSCSamples * bufferSize) );
            CSC.NCC_timeStampArray = zeros(1,bufferSize);
            CSC.NCC_channelNumberArray = zeros(1,bufferSize);
            CSC.NCC_samplingFreqArray = zeros(1,bufferSize);
            CSC.NCC_numValidSamplesArray = zeros(1,bufferSize);
            CSC.NCC_numRecordsReturned = 0;
            CSC.NCC_numRecordsDropped = 0;

            %setup the ref pointers for the function call
            CSC.NCC_dataArrayPtr = libpointer('int16PtrPtr', CSC.NCC_dataArray);
            CSC.NCC_timeStampArrayPtr = libpointer('int64PtrPtr', CSC.NCC_timeStampArray);
            CSC.NCC_channelNumberArrayPtr = libpointer('int32PtrPtr', CSC.NCC_channelNumberArray);
            CSC.NCC_samplingFreqArrayPtr = libpointer('int32PtrPtr', CSC.NCC_samplingFreqArray);
            CSC.NCC_numValidSamplesArrayPtr = libpointer('int32PtrPtr', CSC.NCC_numValidSamplesArray);
            CSC.NCC_numRecordsReturnedPtr = libpointer('int32Ptr', CSC.NCC_numRecordsReturned);
            CSC.NCC_numRecordsDroppedPtr = libpointer('int32Ptr', CSC.NCC_numRecordsDropped);
        end
        
        function s = CSC_BufferSize(CSC)
            s = size(CSC.TimeStamp,1);
        end
        
        function CSC = CSC_Flush(CSC,CSCObjCells,logfid)
            
            % get data stream
            if ~CSC.Flush
                fprintf(1,'%s is not ready to flush. Set ''Flush'' property to >true<!\n',CSC.Name);
                return;
            end
            [succ,FlushTime] = NlxSendCommand('-GetTimestamp');

            [succ, CSCObjName, CSC.NCC_timeStampArray, CSC.NCC_channelNumberArray, CSC.NCC_samplingFreqArray,CSC.NCC_numValidSamplesArray, CSC.NCC_dataArray, CSC.NCC_numRecordsReturned, CSC.NCC_numRecordsDropped ] = calllib('MatlabNetComClient', 'GetNewCSCData', ...
                CSC.Name, CSC.NCC_timeStampArrayPtr, CSC.NCC_channelNumberArrayPtr, CSC.NCC_samplingFreqArrayPtr, CSC.NCC_numValidSamplesArrayPtr, CSC.NCC_dataArrayPtr, CSC.NCC_numRecordsReturnedPtr,CSC.NCC_numRecordsDroppedPtr );

            
            CSC.LastFlush = sscanf(FlushTime{1},'%d');

            % put data in ringbuffer
            if CSC.NCC_numRecordsReturned>0
                nTot = CSC_BufferSize(CSC);
                
                Recidx = 1:CSC.NCC_numRecordsReturned;
                
                % pick cell/cluster
                if ~isempty(CSCObjCells)
                    Recidx = Recidx(ismember(CSC.NCC_channelNumberArray(Recidx),CSCObjCells));
                    if isempty(Recidx);return;end
                    Ridx = 1:length(Recidx);
                else
                    Ridx = Recidx;
                end
                
                % load into ringbuffer
                RBidx = Ridx + CSC.RingBufferIndex;
                while any(RBidx>nTot)
                    RBidx(RBidx>nTot) = RBidx(RBidx>nTot)-nTot;
                end
                CSC.RingBufferIndex = RBidx(end);
                CSC.Data(:,RBidx) = reshape(CSC.NCC_dataArray(1:(CSC.NCC_numRecordsReturned * CSC.maxCSCSamples)),[512 CSC.NCC_numRecordsReturned]);
                CSC.TimeStamp(:,RBidx) = CSC.NCC_timeStampArray(Ridx) + [0:512-1]' .* (1e6/CSC.NCC_samplingFreqArray(Ridx));
                CSC.ChannelNr(RBidx) = CSC.NCC_channelNumberArray(Ridx);
                CSC.SamplingFreq(RBidx) = CSC.NCC_samplingFreqArray(Ridx);
                CSC.NumValidSamples(RBidx) = CSC.NCC_numValidSamplesArray(Ridx);

            end

            if CSC.FlushEcho&&nargin<3
                logfid = 1;
            end
            if CSC.FlushEcho
                fprintf(logfid,'SE_Flush::\t%s\t%4.0f\t%4.0f\t%4.0f\n',CSC.Name,CSC.NCC_numRecordsReturned,CSC.NCC_numRecordsDropped,CSC.RingBufferIndex);
            end
                
        end
        
        function i = CSC_findData(CSC,Win)
            BuffSize = size(CSC.TimeStamp,1);
            ShiftSize = BuffSize-CSC.RingBufferIndex;
            CSC.TimeStamp = circshift(CSC.TimeStamp,[0 ShiftSize]);
            CSC.Data = circshift(CSC.Data,[0 ShiftSize]);
            i = find(CSC.TimeStamp>=Win(1) & CSC.TimeStamp<Win(2));
        end

    end
    
    
end

