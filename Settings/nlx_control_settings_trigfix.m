function s = nlx_control_settings_trigger

% returns a structure prividing settings for the online data acquisation
% via a cheetah object. Supposed to be run from the CURRENT DIRECTORY in
% matlab and is used by the @al_spk class in spk_nlxget.m
% alwin 07/03/05


s.ServerName = 'LOCALHOST';
s.DoLOGfile = true;
s.NetComEventBuffersize = 1000;
s.NetComSEBuffersize = 8000;
s.EventBuffersize = 1000;
s.SEBuffersize = 8000;
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
s.Cndnum           = 1;
s.Blocknum         = 1;
s.PresentationNum  = 3;
s.CutCortexTrial   = 1; % cuts the cortex trial to s.PresentationNum trials in SPK object

% events defining the time window of a single stimulus presentation
s.CndAcqEventsLo = s.EventCode(strmatch('NLX_STIM_ON',s.EventName));
s.CndAcqEventsHi = s.EventCode(strmatch('NLX_STIM_ON',s.EventName));
s.CndAcqOffset = [-300 550];% in ms

% events and spike data will be aligned to the following events
s.CndAlignEvent = s.EventCode(strmatch('NLX_STIM_ON',s.EventName));
s.CndAlignOffset = 0;% in ms

%---------------------------------------------------------------------
% events signalling sending of parameters
s.SendConditionStart = s.EventCode(strmatch('NLX_TRIALPARAM_START',s.EventName));
s.SendConditionEnd = s.EventCode(strmatch('NLX_TRIALPARAM_END',s.EventName));
% 
s.SendParamStart = s.EventCode(strmatch('NLX_STIMPARAM_START',s.EventName));
s.SendParamEnd = [ ...
    s.EventCode(strmatch('NLX_STIMPARAM_END',s.EventName)), ...
    s.EventCode(strmatch('NLX_STIMPARAM_END',s.EventName))];
S.SendParamN = []; %see below !!!!!

s.SendConditionParNum = 3;
s.SendConditionParName = {'TrialID' 'Block', 'Condition'};
s.SendConditionPresentParName = {'StimulusCode'};
s.SendConditionPresentParRange = [1 2];
%s.SendConditionPresentParLevelNum = [72, 1, 2]; % this is not really used yet, all coding done by StimulusCode
s.SendConditionPresentParNum = length(s.SendConditionPresentParName);
s.SendConditionTrialIDIndex = 1;
s.SendConditionBlockIndex = 2;
s.SendConditionConditionIndex = 3;

s.SendConditionN = s.SendConditionParNum + s.PresentationNum * s.SendConditionPresentParNum;

%---------- parameters for plot and online analysis----------------------------------------
s.CndPlotGrid = [1];
s.StimCodeGrid = [1,2];
s.CndParam = [];
s.CndParamLabel = {}; % labels the rows of s.CndParam
s.CndName = {};


s.CurrTrialTimeTicks = [0:100:1000];
s.CurrTrialAlignEventName = 'NLX_SUBJECT_START';

s.RasterTrialNum = 10;
s.RasterDotSize = 1;
s.RasterEventSize = 3.0;
s.RasterTimeLim = [-300 800];
s.RasterTimeTicks = [0:100:500];
s.RasterAlignEventName = 'NLX_STIM_ON';
s.RasterAlignEventCode = s.EventCode(strmatch('NLX_STIM_ON',s.EventName));
s.RasterAlignOffset = 0;

s.HistBinWidth = 25;
s.HistMode     = 3;% 1 counts 2 mean counts 3 mean frequency
s.HistYLim     = [0 25];
s.HistYLimMode = 3;% 1 fixed YLim 2 MAX in cnd 3 MAX over all cond

s.Hist2Grid    = {[1 2]};
s.Hist2Color   = [rgb('pale yellow'); rgb('pale green')];
