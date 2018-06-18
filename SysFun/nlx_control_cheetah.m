function s = nlx_control_cheetah

% This is the Core function. It connects to Cheetah 5 and reads out the
% buffered neuralynx events and spikes

global NLX_CONTROL_GET_CHEETAH; % the "handbrake", stops the "while"-loop
global SPK; % this is the data container (al_spk objectas defined in @al_spk)
global NLX_CONTROL_SETTINGS; % these paradigm specific settings

NLX_CONTROL_GET_CHEETAH = 1;

%% get selected spike channels
[ClusterName,SEObj] = nlx_control_gui_getSelectedChannel;
SEObjCells = cell(size(SEObj));
for i=1:length(ClusterName)
    [El,CellNr] = strread(ClusterName{i},'%s%d','delimiter','.');
    SEObjCells(strmatch(El,SEObj)) = {cat(1,SEObjCells{strmatch(El,SEObj)},CellNr)};
end
ChNum = length(ClusterName);
ElNum = length(SEObj);
NLX_CONTROL_SETTINGS.SpikeObjName = SEObj;


%% CONNECT to Cheetah  NetCom Server
if NlxAreWeConnected() == 1
    fprintf(1,'disconnect from %s first ...\n',NLX_CONTROL_SETTINGS.ServerName);
    succ = NlxDisconnectFromServer();
end

fprintf(1,'connecting to %s ...\n',NLX_CONTROL_SETTINGS.ServerName);
if NlxAreWeConnected() ~= 1
    succ = NlxConnectToServer(NLX_CONTROL_SETTINGS.ServerName);
    if succ ~= 1
        fprintf(1,'FAILED connect to %s. Exiting script.\n',NLX_CONTROL_SETTINGS.ServerName);
        return;
    else
        fprintf(1,'Connected to %s.\n', NLX_CONTROL_SETTINGS.ServerName);
    end
end
NlxSetApplicationName('NLX_CONTROL');

% ask user if cheetah is ready to record
h = msgbox('Make sure to RECORD the CHEETAH DATA !!! (PUSH RED BUTTON)','NEURALYNX control','warn');
% set(h,'units','normalized','position',[0,0.05,0.3,0.2]);
uiwait;

%% check existing CHEETAH OBJECTS
[succ,CheeObj,CheeTyp] = NlxGetCheetahObjectsAndTypes();

% get event object
EVObj = CheeObj{strmatch('EventAcqEnt',CheeTyp,'exact')};

% get SE objects
isObj = ismember(SEObj,CheeObj);
if ~any(isObj)
    fprintf('FAILED; the acquisition entity ''%s'' does not exist.\n', SEObj{~isObj});
    NlxDisconnectFromServer();
    return;
end

%% create default data structure for data storage and online analysis
SPK = nlx_control_defaultSPK(ClusterName); 

%% get the current time
currtime = now;
[succ,val] = NlxSendCommand('-GetTimestamp');
CheetahStartTime = sscanf(val{1},'%d');
currdate = datestr(now,30);

%% ++++++++++++++++++++++ prepare logfile +++++++++++++++++++++++++++++++++++++
logfilename = ['NLXLOG_' currdate '.txt'];
logfilepath = fullfile(nlx_control_getLogDir,logfilename);
if NLX_CONTROL_SETTINGS.DoLOGfile
    logfid = fopen(logfilepath,'w');
    disp(['logfilepath: ' logfilepath]);
else
    logfid = 1;
end
fprintf(logfid,['\n']);
fprintf(logfid,['-------------------------------------------------------------------------------\n']);
fprintf(logfid,['log file opened: ' datestr(currtime,0) ' NLX time: %12.0f\n'],CheetahStartTime);
fprintf(logfid,['-------------------------------------------------------------------------------\n']);



%% OPEN streams +++++++++++++++++++++++++++++++++++++++++++++++++++++++
SEObjNum = length(SEObj);

succ = NlxOpenStream(EVObj);
[succ,val] = NlxSendCommand(sprintf('-SetNetComDataBufferingEnabled %s true',EVObj));
[succ,val] = NlxSendCommand(sprintf('-SetNetComDataBufferSize %s %1.0f',EVObj,NLX_CONTROL_SETTINGS.NetComEventBuffersize));
[succ,val] = NlxSendCommand(sprintf('-GetNetComDataBufferSize %s',EVObj));
fprintf(1,'%10s\tNetCom buffer enabled @%s\n',EVObj,val{1});

for iSEObj = 1:SEObjNum
    succ = NlxOpenStream(SEObj{iSEObj});
    [succ,val] = NlxSendCommand(sprintf('-SetNetComDataBufferingEnabled %s true',SEObj{iSEObj}));
    [succ,val] = NlxSendCommand(sprintf('-SetNetComDataBufferSize %s %1.0f',SEObj{iSEObj},NLX_CONTROL_SETTINGS.NetComSEBuffersize));
    [succ,val] = NlxSendCommand(sprintf('-GetNetComDataBufferSize %s',SEObj{iSEObj}));
    fprintf(1,'%10s\tNetCom buffer enabled @%s\n',SEObj{iSEObj},val{1});
end

% objects to buffer trial data
for iSEObj = 1:SEObjNum
    SE{iSEObj} = nlx_control_SEBuffer(SEObj{iSEObj},NLX_CONTROL_SETTINGS.SEBuffersize,0.1);
end
Ev = nlx_control_EventBuffer('Events',NLX_CONTROL_SETTINGS.EventBuffersize);
CTX = nlx_control_CortexBuffer(NLX_CONTROL_SETTINGS.CortexBuffersize,1,1);
Ev.Flush = true;
Ev.FlushEcho = false;

for iSEObj = 1:SEObjNum
    SE{iSEObj}.Flush = true;
    SE{iSEObj}.FlushEcho = false;
end

%% prepare ONLINE ANALYSES ++++++++++++++++++++++++++++++++++++
% start the analyses function with empty data
nlx_control_callAnalyse(nlx_control_getSelectedAnalyses,1,[]);

%% +++++++++++++++++++ Start Data Acquisition ++++++++++++++++++++++++++++++++
disp('NLX_CONTROL : start flushing buffers :::::::::::::::::::::::::::::::::::::::');
OK_trial = false;
while NLX_CONTROL_GET_CHEETAH
    
    % there is a  valid event in ringbuffer, TimeStamp>0 TTL~=0
    while Ev_isQueue(Ev)
        
        Ev = Ev_Next(Ev);
        if Ev_currTTL(Ev)>0
            Ev_Print(Ev,logfid,NLX_CONTROL_SETTINGS);
        end
        
        % REACT to the according to the registered event
        switch Ev_currTTL(Ev)
            
            case NLX_CONTROL_SETTINGS.TrialStartEvent
                CTX.TrialStartedFlag = 1;
                CTX.TrialStartedCount = CTX.TrialStartedCount + 1;
                CTX.Pointer = CTX.TrialStartedCount;
                CTX.TrialStartTime(CTX.Pointer,1) = Ev_currTimeStamp(Ev);
                
            case NLX_CONTROL_SETTINGS.SendConditionStart
                TermSeq = NLX_CONTROL_SETTINGS.SendConditionEnd;
                nParam = NLX_CONTROL_SETTINGS.SendConditionN;
                
                [Ev,ParamArray,succeeded] = Ev_getParam(Ev,nParam,TermSeq,logfid);
                
                CTX.TrialID(CTX.Pointer,:) = ParamArray(strcmp(NLX_CONTROL_SETTINGS.SendConditionParName,'TrialID'));
                CTX.Block(CTX.Pointer,:) = ParamArray(strcmp(NLX_CONTROL_SETTINGS.SendConditionParName,'Block'));
                CTX.Condition(CTX.Pointer,:) = ParamArray(strcmp(NLX_CONTROL_SETTINGS.SendConditionParName,'Condition'));
                CTX.StimulusCodes(CTX.Pointer,:) = ParamArray(NLX_CONTROL_SETTINGS.SendConditionParNum+1:nParam)';
                
                disp(['TRIALID     ' num2str(CTX.TrialID(CTX.Pointer,:))]);
                disp(['BLOCK     ' num2str(CTX.Block(CTX.Pointer,:))]);
                disp(['CONDITION ' num2str(CTX.Condition(CTX.Pointer,:))]);
                disp(['STIMCODE  ' num2str(CTX.StimulusCodes(CTX.Pointer,:))]);
                ParamArray = [];
                
            case NLX_CONTROL_SETTINGS.SendParamStart
                TermSeq = NLX_CONTROL_SETTINGS.SendParamEnd(:);
                nParam = NLX_CONTROL_SETTINGS.SendParamN;
                [Ev,CTX.ParamArray{CTX.Pointer},succeeded] = Ev_getParam(Ev,nParam,TermSeq,logfid);
                disp(['RECEIVED ' num2str(length(CTX.ParamArray{CTX.Pointer})) ' parameter :' num2str(CTX.ParamArray{CTX.Pointer}')]);
                
            case NLX_CONTROL_SETTINGS.ReadDataEvent
                
                % Flush again if last was before event 
                for iSEObj = 1:SEObjNum
                    if SE{iSEObj}.LastFlush<Ev_currTimeStamp(Ev)
                        SE{iSEObj} = SE_Flush(SE{iSEObj},SEObjCells{iSEObj});
                    end
                end

                % check for correct trial
                [OK_trial,message] = nlx_control_checkTrial(Ev,CTX,NLX_CONTROL_SETTINGS);
                if ~OK_trial
                    CTX.TrialOmittedCount = CTX.TrialOmittedCount + 1;
                    if logfid~=1
                        disp(message);
                    end
                    fprintf(logfid,message);
                    fprintf(logfid,'\n');
                else
                    disp('READ CHEETAH DATA');
                    
                    % get data acquisition windows
                    [AcqWin,AlignTime]  = nlx_control_getTrialAcqWin(Ev,CTX);
                    
                    % load data into structure
                    [SPK,TrialIndex] = nlx_control_SPKaddTrial(SPK,ClusterName,SEObj,SE,Ev,CTX,AcqWin,AlignTime);
                    CTX.TrialReadCount = CTX.TrialReadCount + 1;
                    CTX.ReadFlag(CTX.Pointer) = true;
                    
                    % analyse data
                    tic;
                    nlx_control_callAnalyse(nlx_control_getSelectedAnalyses,1,TrialIndex);
                    tAnalyse = toc;
                    fprintf(1,'t analyse: %1.6f s\n', tAnalyse);
                end
                
            case NLX_CONTROL_SETTINGS.TrialEndEvent
                CTX.TrialEndedCount = CTX.TrialEndedCount + 1;
                CTX.TrialStartedFlag = 0;
                disp('TRIAL END ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::');
                if OK_trial
                    SPK = spk_addEvent(SPK,'NLX_TRIAL_END',{[Ev_currTimeStamp(Ev).*0.001-AlignTime(end).*0.001;Ev_currTTL(Ev)]},TrialIndex(end));
                    OK_trial = false;
                end
                
        end
        
        %% flush SPIKE BUFFERS +++++++++++++++++++++++++++++++
        for iSEObj = 1:SEObjNum
            SE{iSEObj} = SE_Flush(SE{iSEObj},SEObjCells{iSEObj});
        end
        
    end
    
    %% flush SPIKE BUFFERS +++++++++++++++++++++++++++++++
    for iSEObj = 1:SEObjNum
        SE{iSEObj} = SE_Flush(SE{iSEObj},SEObjCells{iSEObj});
    end
    
    %% flush Event BUFFERS +++++++++++++++++++++++++++++++
    while ~Ev_isQueue(Ev)
        pause(0.1);
        Ev = Ev_Flush(Ev,false);
        if NLX_CONTROL_GET_CHEETAH == 0;break;end
    end

	
end

%% close NetCom streams
succ = NlxCloseStream(EVObj);
if succ
    fprintf(logfid,'SUCCeeded to close ''%s'' NetCom stream\n',EVObj);
else
    fprintf(logfid,'FAILed to close ''%s'' NetCom stream\n',EVObj);
end

for iSEObj = 1:SEObjNum
    succ = NlxCloseStream(SEObj{iSEObj});
    if succ
        fprintf(logfid,'SUCCeeded to close ''%s'' NetCom stream\n',SEObj{iSEObj});
    else
        fprintf(logfid,'FAILed to close ''%s'' NetCom stream\n',SEObj{iSEObj});
    end
end

[succ,currCheetahTime] = NlxSendCommand('-GetTimestamp');

%% disconnect
succ = NlxDisconnectFromServer();
if succ
    fprintf(logfid,'SUCCeeded to disconnect NetCom server\n');
    if logfid>1
        fprintf(1,'SUCCeeded to disconnect NetCom server\n');
    end
else
    fprintf(logfid,'FAILed to disconnect NetCom server\n');
    if logfid>1
        fprintf(1,'FAILed to disconnect NetCom server\n');
    end
end

%% close log file
fprintf(logfid,['-------------------------------------------------------------------------------\n']);
fprintf(logfid,['log file closed: ' datestr(now,0) ' NLX time: %s\n'],currCheetahTime{1});
fprintf(logfid,['-------------------------------------------------------------------------------\n']);
if logfid>1
    fclose(logfid);
end


