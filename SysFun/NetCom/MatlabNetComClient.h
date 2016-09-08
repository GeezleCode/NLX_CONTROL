#pragma once

//client functions
extern "C" __declspec(dllexport) bool ConnectToServer(char* serverName);
extern "C" __declspec(dllexport) bool DisconnectFromServer();
extern "C" __declspec(dllexport) bool OpenStream(char* cheetahObjectName);
extern "C" __declspec(dllexport) bool CloseStream(char* cheetahObjectName);
extern "C" __declspec(dllexport) bool SendCommand(char* command, char* &reply);

//setter functions
extern "C" __declspec(dllexport) bool SetApplicationName(char* myApplicationName);
//extern "C" __declspec(dllexport) bool SetLogFileName(string filename);

//getter functions
extern "C" __declspec(dllexport) bool GetCheetahObjectsAndTypes(char** cheetahObjects, char** cheetahTypes);

//getter status functions
extern "C" __declspec(dllexport) char* GetServerPCName();
extern "C" __declspec(dllexport) char* GetServerIPAddress();
extern "C" __declspec(dllexport) char* GetServerApplicationName();
extern "C" __declspec(dllexport) bool AreWeConnected();

//setup functions for data retrieval
extern "C" __declspec(dllexport) int GetRecordBufferSize(void);
extern "C" __declspec(dllexport) bool SetRecordBufferSize(int numRecordsToBuffer);
extern "C" __declspec(dllexport) int GetMaxCSCSamples(void);
extern "C" __declspec(dllexport) int GetSpikeSampleWindowSize(void);
extern "C" __declspec(dllexport) int GetMaxSpikeFeatures(void);
extern "C" __declspec(dllexport) int GetMaxEventStringLength(void);


//data retrieval functions
extern "C" __declspec(dllexport) bool GetNewCSCData(char* acqEntName, __int64* &timeStamps, int* &channelNumbers, int* &samplingFrequency, int* &numValidSamples, short* &samples, int &numRecordsReturned, int &numDroppedRecords);
extern "C" __declspec(dllexport) bool GetNewSEData(char* acqEntName, __int64* &timeStamps, int* &scNumbers, int* &cellNumbers, int* &featureValues, short* &samples, int &numRecordsReturned, int &numDroppedRecords); 
extern "C" __declspec(dllexport) bool GetNewSTData(char* acqEntName, __int64* &timeStamps, int* &scNumbers, int* &cellNumbers, int* &featureValues, short* &samples, int &numRecordsReturned, int &numDroppedRecords); 
extern "C" __declspec(dllexport) bool GetNewTTData(char* acqEntName, __int64* &timeStamps, int* &scNumbers, int* &cellNumbers, int* &featureValues, short* &samples, int &numRecordsReturned, int &numDroppedRecords); 
extern "C" __declspec(dllexport) bool GetNewEventData(char* acqEntName, __int64* &timeStamps, int* &eventIDs, int* &ttlValues, char** eventStrings, int &numRecordsReturned, int &numDroppedRecords);
extern "C" __declspec(dllexport) bool GetNewVTData(char* acqEntName, __int64* &timeStamps, int* &extractedLocations, int* &extractedAngles, int &numRecordsReturned, int &numDroppedRecords);
