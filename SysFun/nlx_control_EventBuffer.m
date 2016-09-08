classdef nlx_control_EventBuffer
    properties
        Name
        TimeStamp
        TTL
        Flag
        EvID
        BINhi
        BINlo
        String
        Label
        Flush
        FlushEcho
        Pointer % points to the current event while deciding on reaction
        RingBufferIndex % indicates position of last registered event
        
        % use for flushing the NetComClient data stream 
        NCC_Time
        NCC_Time_Ptr
        NCC_EvID
        NCC_EvID_Ptr
        NCC_ttl
        NCC_ttl_Ptr
        NCC_Strg
        NCC_Strg_Ptr
        NCC_NReturned
        NCC_NReturned_Ptr
        NCC_NDropped
        NCC_NDropped_Ptr
    end
 
    methods
        
        function Ev = nlx_control_EventBuffer(EvObj,nRec)
            % constructor for the nlx_control_EventBuffer class
            Ev.Name = EvObj;
            Ev.TimeStamp = zeros(nRec,1);% vector of event times
            Ev.EvID        = zeros(nRec,1);
            Ev.TTL       = zeros(nRec,1);
            Ev.Flag = zeros(nRec,1);
            Ev.BINhi       = char(nRec,8);% event code as binary
            Ev.BINlo       = char(nRec,8);
            Ev.String = cell(nRec,1);
            Ev.Label = cell(nRec,1);
            Ev.Flush = false;
            Ev.FlushEcho = false;
            Ev.Pointer = 0;
            Ev.RingBufferIndex = 0;
            for index = 1:nRec
                Ev.Label = blanks(32);
            end
            
            % get NetCom client properties
            succ = libisloaded('MatlabNetComClient');
            if succ == 0;error('NetCom library is not loaded!');end
            bufferSize = calllib('MatlabNetComClient', 'GetRecordBufferSize');
            maxEventStringLength = calllib('MatlabNetComClient', 'GetMaxEventStringLength');
            STRING_PLACEHOLDER = blanks(maxEventStringLength);  %ensures enough space is allocated for each event string name
	
            Ev.NCC_Time = zeros(1,bufferSize);
            Ev.NCC_EvID = zeros(1,bufferSize);
            Ev.NCC_ttl = zeros(1,bufferSize);
            Ev.NCC_Strg = cell(1,bufferSize);
            for index = 1:bufferSize
                Ev.NCC_Strg{1,index} = STRING_PLACEHOLDER;
            end
            Ev.NCC_NReturned = 0;
            Ev.NCC_NDropped = 0;
            
            Ev.NCC_Time_Ptr = libpointer('int64PtrPtr', Ev.NCC_Time);
            Ev.NCC_EvID_Ptr = libpointer('int32PtrPtr', Ev.NCC_EvID);
            Ev.NCC_ttl_Ptr = libpointer('int32PtrPtr', Ev.NCC_ttl);
            Ev.NCC_Strg_Ptr = libpointer('stringPtrPtr', Ev.NCC_Strg);
            Ev.NCC_NReturned_Ptr = libpointer('int32Ptr', Ev.NCC_NReturned);
            Ev.NCC_NDropped_Ptr = libpointer('int32Ptr', Ev.NCC_NDropped);
        end
        
        function s = Ev_BufferSize(Ev)
            s = size(Ev.TimeStamp,1);
        end
        
        function Ev = Ev_Flush(Ev,JustFlush,logfid)
            if ~Ev.Flush
                fprintf(1,'%s is not ready to flush. Set ''Flush'' property to >true<!',Ev.Name);
            end
            [succ, EvObjName, Ev.NCC_Time, Ev.NCC_EvID, Ev.NCC_ttl, Ev.NCC_Strg, Ev.NCC_NReturned,Ev.NCC_NDropped] = calllib('MatlabNetComClient', 'GetNewEventData', ...
                Ev.Name, Ev.NCC_Time_Ptr, Ev.NCC_EvID_Ptr, Ev.NCC_ttl_Ptr, Ev.NCC_Strg_Ptr, Ev.NCC_NReturned_Ptr,Ev.NCC_NDropped_Ptr );
            
            if Ev.FlushEcho&&nargin<2
                logfid = 1;
            end
            if Ev.FlushEcho
                fprintf(logfid,'Ev_Flush::\t%s\t%4.0f\t%4.0f\t%4.0f\n',Ev.Name,Ev.NCC_NReturned,Ev.NCC_NDropped,Ev.RingBufferIndex);
            end
            
            % check for any events
            if Ev.NCC_NReturned==0 || JustFlush;return;end

            % neuralynx BUG: compensate for negative TTL code (should be
            % solved with Cheetah 5.3 ?!
            % convert negative evTTL, interpreting negative integers as 2's
            % complement
            Ev.NCC_ttl(Ev.NCC_ttl<0) = 2*2^(16-1) + Ev.NCC_ttl(Ev.NCC_ttl<0);

            % register flushed events
            nTot = Ev_BufferSize(Ev);
            Ridx = 1:Ev.NCC_NReturned;
            RBidx = Ridx + Ev.RingBufferIndex;
            while any(RBidx>nTot)
                RBidx(RBidx>nTot) = RBidx(RBidx>nTot)-nTot;
            end
            Ev.RingBufferIndex = RBidx(end);
            Ev.TimeStamp(RBidx) = Ev.NCC_Time(Ridx);
            Ev.EvID(RBidx) = Ev.NCC_EvID(Ridx);
            Ev.TTL(RBidx) = Ev.NCC_ttl(Ridx);
            Ev.Flag(RBidx) = 0;

        end
                    
        function out = Ev_isQueue(Ev)
            % checks if it's eligible to count up the pointer
            nTot = Ev_BufferSize(Ev);
            if Ev.RingBufferIndex==0;out=false;return;end
            if Ev.RingBufferIndex>0&&Ev.Pointer==0;out=true;return;end
            if Ev.Pointer>0 && Ev.Pointer<nTot && Ev.TimeStamp(Ev.Pointer+1)~=0 && Ev.TimeStamp(Ev.Pointer+1)>Ev.TimeStamp(Ev.Pointer)
                out = true;
            elseif Ev.Pointer==nTot && Ev.TimeStamp(1)~=0 && Ev.TimeStamp(1)>Ev.TimeStamp(Ev.Pointer)
                out = true;
            else
                out = false;
            end
        end
        
        function ttl = Ev_currTTL(Ev)
            ttl = Ev.TTL(Ev.Pointer);
        end
        
        function ttl = Ev_nextTTL(Ev)
            if Ev.Pointer==Ev_BufferSize(Ev)
                ttl = Ev.TTL(1);
            else
                ttl = Ev.TTL(Ev.Pointer+1);
            end
        end
        
        function i = Ev_findTTL(Ev,TTLCode,Win,FlagCode)
            if nargin<3 || (isempty(Win)&&isempty(FlagCode))
                i = find(ismember(Ev.TTL,TTLCode) & Ev.TimeStamp>0);
            elseif ~isempty(Win)&&~isempty(FlagCode)
                i = find(ismember(Ev.TTL,TTLCode) & Ev.TimeStamp>=Win(1) & Ev.TimeStamp<=Win(2) & ismember(Ev.Flag,FlagCode));
            elseif isempty(Win)&&~isempty(FlagCode)
                i = find(ismember(Ev.TTL,TTLCode) & ismember(Ev.Flag,FlagCode));
            elseif ~isempty(Win)&&isempty(FlagCode)
                i = find(ismember(Ev.TTL,TTLCode) & Ev.TimeStamp>=Win(1) & Ev.TimeStamp<=Win(2));
            end
        end
        
        function [tf,loc] = Ev_ismemberTTL(Ev,TTLCode,Win,FlagCode)
            if nargin<3 || (isempty(Win)&&isempty(FlagCode))
                i = Ev.TimeStamp>0;
            elseif ~isempty(Win)&&~isempty(FlagCode)
                i = Ev.TimeStamp>=Win(1) & Ev.TimeStamp<=Win(2) & ismember(Ev.Flag,FlagCode);
            elseif isempty(Win)&&~isempty(FlagCode)
                i = ismember(Ev.Flag,FlagCode);
            elseif ~isempty(Win)&&isempty(FlagCode)
                i = Ev.TimeStamp>=Win(1) & Ev.TimeStamp<=Win(2);
            end
            i = find(i);
            [tf,loc] = ismember(TTLCode,Ev.TTL(i));
            if any(loc>0)
                loc(loc>0) = i(loc(loc>0));
            end
        end
        
        function i = Ev_nextN(Ev,n)
            i = Ev.Pointer:Ev.Pointer+(n-1);
            bs = Ev_BufferSize(Ev);
            ix = i>bs;
            i(ix) = i(ix)-bs;
        end
        
        function EvIdx = Ev_nextNonZero(Ev,n)
            % returns the next n events with nonzero TTL and TimeStamp
            % including current pointer position
            EvIdx = zeros(n,1);
            bs = Ev_BufferSize(Ev);
            iEv = 1;
            i = Ev.Pointer;
            while iEv<=n
                if Ev.TimeStamp(i)==0 || Ev.TimeStamp(i)<Ev.TimeStamp(Ev.Pointer)
                    break;
                elseif Ev.TimeStamp(i)>0 && Ev.TTL(i)>0
                    EvIdx(iEv) = i;
                    iEv = iEv+1;
                end
                if i==bs
                    i = 1;
                else
                    i = i+1;
                end
            end
        end
        
        function c = Ev_currTimeStamp(Ev)
            c = Ev.TimeStamp(Ev.Pointer);
        end
        
        function n = Ev_nextTimeStamp(Ev)
            if Ev.Pointer==Ev_BufferSize(Ev)
                n = Ev.TimeStamp(1);
            else
                n = Ev.TimeStamp(Ev.Pointer+1);
            end
        end

        function Ev = Ev_Next(Ev)
            if Ev.Pointer==Ev_BufferSize(Ev)
                Ev.Pointer = 1;
            else
                Ev.Pointer = Ev.Pointer+1;
            end
        end
        
        function i = Ev_Last(Ev,TTLCode)
            
            i = Ev.Pointer;
            if i==0;return;end
            doRewind = true;
            while doRewind
                i = i-1;
                if i<1; i = Ev_BufferSize(Ev); end 
                if nargin<2
                    doRewind = false;
                elseif isempty(TTLCode) && Ev.TTL(i)>0
                    doRewind = false;
                elseif ~isempty(TTLCode) && Ev.TTL(i)==TTLCode
                    doRewind = false;
                end
            end
        end
        
        function Ev_Print(Ev,logfid,NLX_CONTROL_SETTINGS)
            fprintf(logfid,'%5u ',Ev.Pointer);
            fprintf(logfid,'%12.0f ',Ev.TimeStamp(Ev.Pointer));
            fprintf(logfid,'%4u ',Ev.EvID(Ev.Pointer));
            fprintf(logfid,'%4u ',Ev.Flag(Ev.Pointer));
            fprintf(logfid,'%5u ',Ev.TTL(Ev.Pointer));
            %fprintf(logfid,[event.BINhi(Ev.Pointer,:) ' ']);
            %fprintf(logfid,[event.BINlo(Ev.Pointer,:) ' ']);
            fprintf(logfid,'# ');
            
            lastEvent = Ev_Last(Ev,[]);
            if lastEvent>1
                fprintf(logfid,'+ %12.3f ms ',(Ev.TimeStamp(Ev.Pointer)-Ev.TimeStamp(lastEvent)).*0.001);
            else
                fprintf(logfid,'  %12.3f ms ',Ev.TimeStamp(Ev.Pointer).*0.001);
            end
            
            fprintf(logfid,'\t%s',Ev_currLabel(Ev,NLX_CONTROL_SETTINGS));
            fprintf(logfid,'\n');

        end
        
        function l = Ev_currLabel(Ev,NLX_CONTROL_SETTINGS)
            LabelIdx = NLX_CONTROL_SETTINGS.EventCode==Ev.TTL(Ev.Pointer);
            if any(LabelIdx)
                l = NLX_CONTROL_SETTINGS.EventName{LabelIdx};
            else
                l = '';
            end
        end
        
        function [Ev,ParamArray,succeeded] = Ev_getParam(Ev,nParam,TermSeq,logfid)
            Ev.Flag(Ev.Pointer) = 2;
            ParamCount = 0;
            ParamArray = zeros(nParam,1);
            
            % start times are needed to terminate param sequence loop in
            % case of missing the detection or terminal sequence
            EvStartIdx = Ev.Pointer;
            EvStartTime = Ev_currTimeStamp(Ev);
            DetectStartTime = clock;% 
            maxTime = 5;% in sec
            
            % the termination sequence can be integers and zeros, however
            % it should start with an integer
            TermN = length(TermSeq);
            isTermination = logical(zeros(1,TermN));
            
            % loop events
            i = 0;
            paramsendflag = false;
            while ~paramsendflag
                
                if any(Ev_nextNonZero(Ev,1+TermN)==0)
                    % checks if there are at least 1+TermN nonzero events
                    % queued, otherwise flush again
                    Ev = Ev_Flush(Ev,false,logfid);
                else
                    Ev = Ev_Next(Ev);
                    Ev.Flag(Ev.Pointer) = 2;
                    i = i+1;
                    
                    % check for termination
                    if Ev_currTTL(Ev)>0
                        nextidx = Ev_nextNonZero(Ev,TermN);
                        isTermination = TermSeq==Ev.TTL(nextidx);
                        if all(isTermination)
                            paramsendflag = true;
                            Ev.Flag(Ev.Pointer:nextidx(end)) = 2;% change event type of terminalsequence
                            Ev.Pointer = nextidx(end);
                        end
                    end
                    
                    % register param value
                    if ~paramsendflag && Ev_currTTL(Ev)>0 && Ev_currTimeStamp(Ev)>0% Non-Zero event
                        ParamCount = ParamCount+1;
                        ParamArray(ParamCount) = Ev_currTTL(Ev);
                    end
                end
                
                % check time limit
                % if etime(clock,DetectStartTime)>maxTime % absolute time
                if Ev_currTimeStamp(Ev)-EvStartTime>maxTime*1000000
                    disp('TIME OUT while receiving stim. parameter!');
                    break;
                end
                
                % check expected parameter number
                if ParamCount>nParam        
                    disp('UNEXPECTED number of received parameter!');
                    break;
                end
            end
            
            if ~paramsendflag
                succeeded = false;
            else
                succeeded = true;
            end
        end
        
    end
end

