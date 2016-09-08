function s = spk_nlxreadspikedata2(s,NLXFileName,NLXTrialWin,NLXFileWin)

% reads spike data from a neuralynx *.nse file
%
% s = spk_nlxreadspikedata2(s,NLXFileName,NLXTrialWin,NLXFileWin)
%
% NLXFileName ............ complete path to file, empty to force gui to pull up
% NLXTrialWin ............. time window for every trial in NLX time, trials along rows.
% NLXFileWin .............. time window in NLX time to extract data from NLX file

% read Neuralynx File
if nargin<2 | isempty(NLXFileName)
    [NLXFileName,nlxPath] = uigetfile('*.NSE','load NEURALYNX *.NSE - file');
    if NLXFileName==0;return;end
    NLXFileName = fullfile(nlxPath,NLXFileName);
end

%----------------------------------------------------------
% Extraction Modes
%     1. Extract All - This will extract every record from the file into the matlab environment;
%     2. Extract Record Index Range = This will extract every Record whos index is within a range specified by Paramter 5.
%     3. Extract Record Index List = This will extract every Record whos index in the file is the same index that is specified by Paramter 5.
%     4. Extract Timestamp Range = This will extract every Record whos timestamp is within a range specified by Paramter 5.
%     5. Extract Timestamp List = This will extract every Record with the same timestamp that is specified by Paramter 5.
%     [TimeStamps, ScNumbers, CellNumbers, Params, DataPoints, NlxHeader] = Nlx2MatSpike_v3( ...
[TimeStamps, ScNumbers, CellNumbers] = Nlx2MatSpike_v3( ...
    NLXFileName, ...
    [1 1 1 0 0], ... Timestamps,Sc Numbers,Cell Numbers,Params,Data Points
    0, ... extract header
    4, ... extraction mode
    NLXFileWin);% ... mode array

NLXcells = unique(CellNumbers);
NLXcellNum = length(NLXcells);
%----------------------------------------------------------

% clear object from spike data
numTrials = size(s.spk,2);
% s.spk = {};
s.channel = {};
currChannels = [];
    

% loop trials
hwait = waitbar(0,'Extract spikes from neuralynx NSE file ...');
for i = 1:numTrials
    
    % load spike times into object
    for j = 1:NLXcellNum
        
        if ~ismember(num2str(NLXcells(j)),s.channel)
            s.channel = [s.channel;{num2str(NLXcells(j))}];
        end
        chanInd = find(ismember(s.channel,num2str(NLXcells(j))));
        
        s.spk{chanInd,i} =  TimeStamps(CellNumbers==NLXcells(j) & TimeStamps>=NLXTrialWin(i,1) & TimeStamps<=NLXTrialWin(i,2)) .* 0.001 - s.align(i);
    if i == 214
        s.spk{chanInd,i} =  TimeStamps(CellNumbers==NLXcells(j) & TimeStamps>=NLXTrialWin(i,1) & TimeStamps<=6761000000) .* 0.001 - s.align(i);
    end
        
    end
        
    
    waitbar(i/numTrials,hwait);
end
close(hwait);

    
    