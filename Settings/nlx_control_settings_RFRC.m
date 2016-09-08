function s = nlx_control_settings_RFRC

% returns a structure prividing settings for the online data acquisation
% via a cheetah object. Supposed to be run from the CURRENT DIRECTORY in
% matlab and is used by the @al_spk class in spk_nlxget.m
% alwin 07/03/05


s.ServerName = 'LOCALHOST';
s.DoLOGfile = true;
s.NetComEventBuffersize = 1000;
s.NetComSEBuffersize = 8000;
s.NetComCSCBuffersize = 100;
s.EventBuffersize = 1000;
s.SEBuffersize = 8000;
s.CSCBuffersize = 100;
s.CortexBuffersize = 5000;

% ----------------------------- ERRORS --------------------------------------
% Defining the errorcodes used returned by the matlab cheetah interface 
% to indicate empty arrays (-1001) or a missing cheetah object (-101). 
s.ErrorCodes = [-1001 -101];

% -------------------------------------------------------------------------
% name of the spike acquisition object as defined in the cheetah config
% file (e.g. al_1se1csc.cfg, see line >>-Create SEScAcqEnt Sc1)
s.SpikeObjName = {'Sc1' 'Sc2'};        


% -------------------------------------------------------------------------
% colorcode for cheetah clusters
s.SpikeChanNames = {'0' '1' '2' '3' '4' '5' '6' '7'};
s.SpikeChanColor = [ ...
        1 1 1; ...      white
        1 0 0; ...      red
        0 1 0; ...      green
        0 0 1; ...      blue
        1 1 0; ...       yellow
        .5 0 1; ...     purple
        1 .5 0; ...     orange
        0 1 .5; ...     cyan
        0 1 1 ...      light blue
        ]; ...     

%     (slightly, normal, very, extremely)
%     (light/pale, normal, dark)
s.SpikeChanColor(1,:) = rgb('pale orange');
s.SpikeChanColor(2,:) = rgb('pale yellow');
s.SpikeChanColor(3,:) = rgb('pale green');
s.SpikeChanColor(4,:) = rgb('pale blue');
    
% --------------------------- EVENTS ------------------------------------
% name of the event acquisition object as defined in the cheetah config
% file (see Events.cfg)
s.EventObjName = 'Events';

% event encodes and names as used in the timing file
s.EventName(1) =   {'NLX_TRIAL_START'};         s.EventCode(1) = 255;
s.EventName(2) =   {'NLX_RECORD_START'};        s.EventCode(2) = 2;
s.EventName(3) =   {'NLX_SUBJECT_START'};       s.EventCode(3) = 4;
s.EventName(4) =   {'NLX_STIM_ON'};             s.EventCode(4) = 8;
s.EventName(5) =   {'NLX_STIM_OFF'};            s.EventCode(5) = 16;
s.EventName(6) =   {'NLX_SUBJECT_END'};         s.EventCode(6) = 32;
s.EventName(7) =   {'NLX_RECORD_END'};          s.EventCode(7) = 64;
s.EventName(8) =   {'NLX_TRIAL_END'};           s.EventCode(8) = 254;
s.EventName(9) =   {'NLX_READ_DATA'};           s.EventCode(9) = 128;
s.EventName(10) =  {'NLX_TRIALPARAM_START'};    s.EventCode(10) = 253;          
s.EventName(11) =  {'NLX_TRIALPARAM_END'};      s.EventCode(11) = 252;
s.EventName(12) =  {'NLX_STIMPARAM_START'};     s.EventCode(12) = 251;          
s.EventName(13) =  {'NLX_STIMPARAM_END'};       s.EventCode(13) = 250;

s.EventName(14) =  {'NLX_EVENT_1'};       s.EventCode(14) = 9;
s.EventName(15) =  {'NLX_EVENT_2'};       s.EventCode(15) = 10;
s.EventName(16) =  {'NLX_EVENT_3'};       s.EventCode(16) = 11;
s.EventName(17) =  {'NLX_EVENT_4'};       s.EventCode(17) = 12;
s.EventName(18) =  {'NLX_EVENT_5'};       s.EventCode(18) = 13;
s.EventName(19) =  {'NLX_EVENT_6'};       s.EventCode(19) = 14;
s.EventName(20) =  {'NLX_EVENT_7'};       s.EventCode(20) = 15;

% color code for each of the events
s.EventColor = repmat([0 1 1],length(s.EventName),1); % light blue
s.EventColor = repmat([0 1 1],length(s.EventName),1); % light blue

% eventcode that triggers the reading of spike data from the cheetah buffer 
s.ReadDataEvent = s.EventCode(strmatch('NLX_READ_DATA',s.EventName));

% eventcodes that have to occured in a trial up to the read event
% to accept a trial for reading
s.MandatoryEvents = [255 2 4 32 64 128];

% temporal gaps below a minimum are not accepted
s.MinEventGap = 2;% in ms

s.PrintEventEcho = 1;

%----------------- Trail window -------------------------------------
% events signalling the start of a trial and hence e.g. reset the running
% variables of the data acquisition routine or do cleaning up after a trial
s.TrialStartEvent = s.EventCode(strmatch('NLX_TRIAL_START',s.EventName)); 
s.TrialEndEvent = s.EventCode(strmatch('NLX_TRIAL_END',s.EventName));

%---------------------------------------------------------------------
% time window for recording data of a cortex trial, is ideally meant to
% coincide with the collectdata on event in cortex
s.AcqEvents = [s.EventCode(strmatch('NLX_RECORD_START',s.EventName)) s.EventCode(strmatch('NLX_RECORD_END',s.EventName))];
s.AcqOffset = [0 0];% in ms

%---------------------------------------------------------------------
% in case of MULTIPLE STIMULUS presentations in one cortex trial
% nlx_control is able to cut the trial in single condition trials depending
% on the following settings

% number of stimulus presentations in one trial
% number of stimulus presentations in one trial
s.Cndnum = 4;
s.Blocknum = 1;
s.PresentationNum = 1;
s.CutCortexTrial = 0; % cuts the cortex trial to s.PresentationNum trials in SPK object

% events defining the time window of a single stimulus presentation
s.CndAcqEventsLo = s.EventCode(strmatch('NLX_SUBJECT_START',s.EventName));
s.CndAcqEventsHi = s.EventCode(strmatch('NLX_SUBJECT_END',s.EventName));
s.CndAcqOffset = [-250 250];% in ms

% events and spike data will be aligned to the following events
s.CndAlignEvent = s.EventCode(strmatch('NLX_SUBJECT_START',s.EventName));
s.CndAlignOffset = 0;% in ms

%---------------------------------------------------------------------
% events signalling sending of parameters
s.SendConditionStart = s.EventCode(strmatch('NLX_TRIALPARAM_START',s.EventName));
s.SendConditionEnd = s.EventCode(strmatch('NLX_TRIALPARAM_END',s.EventName));
s.SendConditionN = 3;
% 
s.SendParamStart = s.EventCode(strmatch('NLX_STIMPARAM_START',s.EventName));
s.SendParamEnd = [ ...
    s.EventCode(strmatch('NLX_STIMPARAM_END',s.EventName)), ...
    s.EventCode(strmatch('NLX_STIMPARAM_END',s.EventName))];
S.SendParamN = []; %see below !!!!!

%---------- parameters for plot and online analysis----------------------------------------
s.CndPlotGrid = [1];
s.StimCodeGrid = [1];
s.CndParam = [];
s.CndParamLabel = {}; % labels the rows of s.CndParam
s.CndName = {};


s.CurrTrialTimeTicks = [0:500:5000];
s.CurrTrialAlignEventName = 'NLX_SUBJECT_START';
s.RasterTrialNum = 10;
s.RasterDotSize = 1;
s.RasterEventSize = 3.0;
s.RasterTimeLim = [0 5000];
s.RasterTimeTicks = [0:1000:5000];
s.RasterAlignEventName = 'NLX_SUBJECT_START';
s.RasterAlignEventCode = s.EventCode(strmatch('NLX_SUBJECT_START',s.EventName));
s.RasterAlignOffset = 0;
s.HistBinWidth = 50;
s.HistMode = 3;% 1 counts 2 mean counts 3 mean frequency
s.HistYLim = [0 25];
s.HistYLimMode = 3;% 1 fixed YLim 2 MAX in cnd 3 MAX over all cond

%---------- RF map parameter ----------------------------------------
%**********************************************************************
s.RFMapSize = [9 12];% rows cols of map
s.RFDotSpacing = 0.5;
s.RFMapRefPos = [2 -3];
s.RVCOTau = [0 100];
s.RVCOTauBase = 0;
s.RVCOWin = [-50 0];
s.RFDotLum(1:prod(s.RFMapSize)) = 255;
% s.RFDotLum(prod(s.RFMapSize)+1:prod(s.RFMapSize)*2) = 0;
%**********************************************************************

s.RFStimSeqDecodingMethod = 2;% 1 Index of current sequence; 2 Index of all stimuli
s.RFStimSeqIndex_TotalNum = 1;
s.RFStimSeqIndex_FirstValidNr = 2;
s.RFStimSeqIndex_ValidSEQNum = 3;
s.RFStimSeqIndex_SEQStart = 4;
s.SendParamN = prod(s.RFMapSize)/s.Cndnum+s.RFStimSeqIndex_SEQStart-1;

s.RFMapRowNr = repmat([1:s.RFMapSize(1)]',[1 s.RFMapSize(2)]);
s.RFMapColNr = repmat([1:s.RFMapSize(2)],[s.RFMapSize(1) 1]);
s.RFMapRowNr = [s.RFMapRowNr(:)'];
s.RFMapColNr = [s.RFMapColNr(:)'];
s.RFDotPosX = repmat([(s.RFMapSize(2)-1)*s.RFDotSpacing/-2:s.RFDotSpacing:(s.RFMapSize(2)-1)*s.RFDotSpacing/2],[s.RFMapSize(1) 1]);
s.RFDotPosY = repmat([(s.RFMapSize(1)-1)*s.RFDotSpacing/2:-s.RFDotSpacing:(s.RFMapSize(1)-1)*s.RFDotSpacing/-2]',[1 s.RFMapSize(2)]);
s.RFDotPosX = [s.RFDotPosX(:)'] + s.RFMapRefPos(1);
s.RFDotPosY = [s.RFDotPosY(:)'] + s.RFMapRefPos(2);
s.RFMapImageResizeFactor = 5;
s.RFMapImageResizeInterpolation = 'bilinear'; % nearest bilinear bicubic
s.RFMapImageResizeFilterOrder = 3;
s.RFMapZScoreFlag = true;
s.RFMapCLim = [];% if empty clim is min/max of spike count
s.RFColormap = usercolormap(rgb('blue'),[1 1 1],rgb('yellow'),rgb('orange'));
s.RFColormap = jet;
