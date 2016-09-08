
ServerName = 'localhost';
SEObj = 'SE2';

%% connect
succ = NlxConnectToServer(ServerName);
if succ ~= 1
    fprintf('FAILED connect to %s. Exiting script.\r',ServerName);
    return;
else
    fprintf('Connected to %s.\r', ServerName);
end

%% get info
NlxSetApplicationName('NLX_CONTROL');
[succ,CheeObj,CheeTyp] = NlxGetCheetahObjectsAndTypes();
for i=1:length(CheeObj)
    fprintf('can see %s %s\r',CheeObj{i},CheeTyp{i});
end

[succ,val] = NlxSendCommand(sprintf('-SetNetComDataBufferingEnabled %s true',SEObj));
[succ,val] = NlxSendCommand(sprintf('-GetNetComDataBufferSize %s',SEObj));
fprintf(1,'%10s\tNetCom buffer enabled @%s\n',SEObj,val{1});
[succ,val] = NlxSendCommand(sprintf('-SetNetComDataBufferSize %s %1.0f',SEObj,5000));
[succ,val] = NlxSendCommand(sprintf('-GetNetComDataBufferSize %s',SEObj));
fprintf(1,'%10s\tNetCom buffer enabled @%s\n',SEObj,val{1});
succ = NlxOpenStream(SEObj);


for i=1:3
    [succ, SE.dataArray, SE.timeStampArray, SE.spikeChannelNumberArray, SE.cellNumberArray, SE.featureArray, SE.numRecordsReturned, SE.numRecordsDropped ] = NlxGetNewSEData(SEObj);
    if succ ~= 1
        fprintf('FAILED get new data\r',ServerName);
        return;
    else
        fprintf('%s: returned %1.0f dropped %1.0f\r',SEObj,SE.numRecordsReturned,SE.numRecordsDropped);
    end
    pause(4);
    
end

succ = NlxCloseStream(SEObj);
if succ == 1, fprintf('CLOSED stream\r',ServerName);end
succ = NlxDisconnectFromServer();
if succ == 1, fprintf('DISCONNECT from server\r',ServerName);end
