function [s,unknownEv] = spk_readcortex(s,filepath,SpkCodes,response_errors,readEyeFlag)

% reads a cortex file in @al_spk object
% [s,unknownEv] = spk_readcortex(s,filepath,SpkCodes,response_errors)
%
% INPUT
% filepath .......... full path to cortex file
% SpkCodes .......... cortex spike codes to read in different channels ([] reads all)
% response_errors ... response errors to read in ([] reads all)
% readEyeFlag ....... 1/0 flag for reading eye data
%
% OUTPUT
% unknownEv ... encodes not in the cortex encode list according to
%              ctx_encodelist.m

if nargin<5
    readEyeFlag = 0;
    if nargin<4
        response_errors = [];
    end;end

if ~isnumeric(SpkCodes)
    error('spike codes have to be numeric !')
end
%_______________________________________
% set file data
if nargin<2 | isempty(filepath);
    [fName,fPath] = uigetfile('*.*','open a CORTEX data file');
    if fName==0;return;end
    filepath = fullfile(fPath,fName);
end

[fpath,fname,fext] = fileparts(filepath);
fprop = dir(filepath); 

%=========================================================
% read cortex file
[EVT,EOG,EPP,HD] = ctx_read(filepath,[1 readEyeFlag 0]);
%=========================================================

if isempty(response_errors)
    readResErr = logical(ones(1,size(HD,2)));
else
    readResErr = ismember(HD(14,:),response_errors);
    EVT = EVT(:,readResErr);
    HD = HD(:,readResErr);
end
[HDrows,TrialNum] = size(HD);
[ctxEvents,ctxEvEncodes,ctxSpkEncodes] = ctx_encodelist;

selectedSpikeCodes = SpkCodes;
numselectedSpikeCodes = length(selectedSpikeCodes);
%________________________________________
% prepare @al_spk object
s.name = '';
s.tag  = '';
s.subject = '';
% s.file = [fname,fext];
s.file = strrep(filepath,'\','/');
s.channel = cellstr(num2str(selectedSpikeCodes'));
s.date = fprop.date;
s.unittype = '';
s.stimulus = '';
s.eventlabel = []; % temporarily convert event labels to numbers because of cortex encoding
% HEADER: 2 cond_no 3 repeat_no 4 block_no 5 trial_no 12 expected_response 13 response 14 response_error
% 10 eye_storage_rate 11 kHz_resolution 
HeaderIndex = [2 3 4 5 12 13 14];
s.trialcodelabel = {'condition','repeat','block','trial','expected_response','response','response_error'};
s.timeorder = -3;

if readEyeFlag
    s.analogname{1} = 'EOGX';
    s.analogname{2} = 'EOGY';
    s.analogFreq = 1000./unique(HD(10,:));
end

%________________________________________
% loop trials
unknownEv = cell(1,TrialNum);

hwait = waitbar(0,['building @al_spk object from ' s.file ]);
for i = 1:TrialNum
    
    %__________________________________________________
    % read trial properties
    s.trialcode(1:length(HeaderIndex),i) = HD(HeaderIndex,i);
%     s.trialcode(2,i) = HD(3,i);
%     s.trialcode(3,i) = HD(4,i);
%     s.trialcode(4,i) = HD(5,i);
%     s.trialcode(5,i) = HD(12,i);
%     s.trialcode(6,i) = HD(13,i);
%     s.trialcode(7,i) = HD(14,i);
    
    %___________________________________________________
    % check events of this trial
    isSpkChan           = ismember(EVT{i}(:,2),selectedSpikeCodes);
    isSpkEventCode      = ismember(EVT{i}(:,2),ctxSpkEncodes);
    isCTXencode         = ismember(EVT{i}(:,2),ctxEvEncodes);
    
    %__________________________________________________
    % read spikes of the particular channel
    % vertical vector of spike times in each cell
    for j=1:numselectedSpikeCodes
        s.spk{j,i} = EVT{i}(ismember(EVT{i}(:,2),selectedSpikeCodes(j)),1);
    end
    
    %__________________________________________________
    % vertical vector of event times in each cell
    % cortex events
    s = addEvents(s,i,EVT{i}((~isSpkEventCode & isCTXencode),:));
    
    % get the non defined events
    unknownEv{i} = EVT{i}((~isSpkEventCode & ~isCTXencode),:);
    
    
    %__________________________________________________
    % read eye data
    if readEyeFlag
        s.analog{1,i} = EOG{i}(1:2:end-1);
        s.analog{2,i} = EOG{i}(2:2:end);
    end
    
    waitbar(i./TrialNum,hwait);
end

%__________________________________________________
% finish events
waitbar(1,hwait,'make string event label');
numEventTypes = size(s.eventlabel,2);
% eventcolors
s.eventcolors = ones(numEventTypes,3).*NaN;

% ctx events
eventlabel = cell(1,numEventTypes);
[isCTXencode,CTXencodeIndex] = ismember(s.eventlabel,ctxEvEncodes);
if any(isCTXencode);eventlabel(isCTXencode) = ctxEvents(CTXencodeIndex)';end

s.eventlabel = eventlabel;

%__________________________________________________
close(hwait)

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function  s = addEvents(s,i,Ev)

e = unique(Ev(:,2));
for ce = 1:length(e)
    code = e(ce);
    evIndex = (s.eventlabel==code);
    if ~any(evIndex)
        s.eventlabel = [s.eventlabel code];
        evIndex = size(s.eventlabel,2);
    end
    s.events{evIndex,i} = Ev(Ev(:,2)==code ,1);
end
