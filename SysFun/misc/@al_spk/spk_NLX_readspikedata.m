function s = spk_nlxreadspikedata(s,nlxFile,SpikeAcqWin,SpikeAcqWinOffset,EventNr)

% reads spike data from a neuralynx *.nse file
%
% s = spk_nlxreadspikedata(s,nlxFile,SpikeAcqWin,SpikeAcqWinOffset,EventNr)
%
% nlxFile ................ complete path to file, empty to force gui to pull
%                          up
% SpikeAcqWin ............ cell array of eventlabels in s.eventlabel {lo event, hi event]
%                          default: {'NLX_RECORD_START' 'NLX_RECORD_END'}
% SpikeAcqWinOffset ...... offset to window in ms
% EventNr ................ trialcodelabel indicating the number of an event if an event occured several times within a trial 

if nargin<5
    EventNr = '';
    if nargin<4
        SpikeAcqWinOffset = [0 0];
        if nargin<3
            SpikeAcqWin = {'NLX_RECORD_START' 'NLX_RECORD_END'};
        end;end;end
if nargin<2 | isempty(nlxFile)
    [nlxFile,nlxPath] = uigetfile('*.NSE','load NEURALYNX *.NSE - file');
    if nlxFile==0;return;end
    nlxFile = fullfile(nlxPath,nlxFile);
end

% clear object from spike data
numTrials = size(s.spk,2);
s.spk = {};
s.channel = {};
currChannels = [];

% loop trials
hwait = waitbar(0,'Extract spikes from neuralynx NSE file ...');
for i = 1:numTrials
    WinLo = spk_getevents(s,SpikeAcqWin{1},i);
    WinHi = spk_getevents(s,SpikeAcqWin{2},i);
    Event_index = 1;
    if length(WinLo{1}) ~= length(WinLo{1})
    elseif length(WinLo{1})>1 & length(WinLo{1})>1
        Event_index = spk_gettrialcodes(s,EventNr,i);
    end
    
    AcqWin = [WinLo{1}(Event_index)+SpikeAcqWinOffset(1)+s.align(i) ...
            WinHi{1}(Event_index)+SpikeAcqWinOffset(2)+s.align(i)].*1000;
    
    %----------------------------------------------------------
    % read Neuralynx File
    % Extraction Modes
    %     1. Extract All - This will extract every record from the file into the matlab environment;
    %     2. Extract Record Index Range = This will extract every Record whos index is within a range specified by Paramter 5.
    %     3. Extract Record Index List = This will extract every Record whos index in the file is the same index that is specified by Paramter 5.
    %     4. Extract Timestamp Range = This will extract every Record whos timestamp is within a range specified by Paramter 5.
    %     5. Extract Timestamp List = This will extract every Record with the same timestamp that is specified by Paramter 5.
    %     [TimeStamps, ScNumbers, CellNumbers, Params, DataPoints, NlxHeader] = Nlx2MatSpike_v3( ...
    [TimeStamps, ScNumbers, CellNumbers] = Nlx2MatSpike_v3( ...
        nlxFile, ...
        [1 1 1 0 0], ... Timestamps,Sc Numbers,Cell Numbers,Params,Data Points
        0, ... extract header
        4, ... extraction mode
        AcqWin ... mode array
    );
    %----------------------------------------------------------

    % load spike times into object
    for j = unique(CellNumbers)
        if ~ismember(num2str(j),s.channel)
            s.channel = [s.channel;{num2str(j)}];
        end
        chanInd = find(ismember(s.channel,num2str(j)));
        s.spk{chanInd,i} =  TimeStamps(CellNumbers==j) .* 0.001 - s.align(i);
    end
        
    
    waitbar(i/numTrials,hwait);
end
close(hwait);

    
    