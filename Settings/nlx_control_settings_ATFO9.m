function s = nlx_control_settings_ATFO9

% returns a structure prividing settings for the online data acquisation
% via a cheetah object. Supposed to be run from the CURRENT DIRECTORY in
% matlab and is used by the @al_spk class in spk_nlxget.m

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
s.SpikeObjName = {'Sc1'};        


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

s.EventName(21) =  {'NLX_TESTDIMMED'};    s.EventCode(21) = 17;
s.EventName(22) =  {'NLX_DISTDIMMED'};    s.EventCode(22) = 18;
s.EventName(23) =  {'NLX_BARRELEASED'};   s.EventCode(23) = 19;
s.EventName(24) =  {'NLX_CUE_ON'};        s.EventCode(24) = 20;
s.EventName(25) =  {'NLX_CUE_OFF'};       s.EventCode(25) = 21;

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
s.Cndnum = 28;
s.Blocknum = 8;
s.PresentationNum = 1;
s.CutCortexTrial = 0; % cuts the cortex trial to s.PresentationNum trials in SPK object

% events defining the time window of a single stimulus presentation
s.CndAcqEventsLo = s.EventCode(strmatch('NLX_SUBJECT_START',s.EventName));
s.CndAcqEventsHi = s.EventCode(strmatch('NLX_SUBJECT_END',s.EventName));
s.CndAcqOffset = [-250 250];% in ms

% events and spike data will be aligned to the following events
s.CndAlignEvent = s.EventCode(strmatch('NLX_STIM_ON',s.EventName));
s.CndAlignOffset = 0;% in ms

%---------------------------------------------------------------------
% events signalling sending of parameters
s.SendConditionStart = s.EventCode(strmatch('NLX_TRIALPARAM_START',s.EventName));
s.SendConditionEnd = s.EventCode(strmatch('NLX_TRIALPARAM_END',s.EventName));
s.SendConditionN = 3;
s.SendConditionTag = {'block' 'condition' 'stimcode'};

% 
s.SendParamStart = s.EventCode(strmatch('NLX_STIMPARAM_START',s.EventName));
s.SendParamEnd = s.EventCode(strmatch('NLX_STIMPARAM_END',s.EventName));

%---------- parameters for plot and online analysis----------------------------------------
s.CndPlotGrid = [6 4];
s.StimCodeGrid = [];

s.CndParam = logical(zeros(3,8));
s.CndParam(1,:) = [1 0 1 0 1 0 1 0 ];
s.CndParam(2,:) = [1 1 0 0 1 1 0 0 ];
s.CndParam(3,:) = [0 0 0 0 1 1 1 1 ];
s.CndParamLabel = {'dimsFIRST' 'inRF' 'dir'}; % labels the rows of s.CndParam

s.CndName = {};


s.CurrTrialTimeTicks = [-2000:500:3000];
s.CurrTrialAlignEventName = 'NLX_STIM_ON';

s.RasterTrialNum = 10;
s.RasterDotSize = 1.0;
s.RasterEventSize = 3.0;
s.RasterTimeLim = [-2000 4000];
s.RasterTimeTicks = [-2000:100:5000];
s.RasterAlignEventName = 'NLX_STIM_ON';
s.RasterAlignEventCode = s.EventCode(strmatch('NLX_STIM_ON',s.EventName));
s.RasterAlignOffset = 0;
s.HistBinWidth = 50;
s.HistMode = 3;% 1 counts 2 mean counts 3 mean frequency
s.HistYLim = [0 25];
s.HistYLimMode = 3;% 1 fixed YLim 2 MAX in cnd 3 MAX over all cond
% one cell per axes, column per group, average across rows
% average across dim times, all blocks separately
%      1    29    57    85   113   141   169   197
%      2    30    58    86   114   142   170   198
%      3    31    59    87   115   143   171   199
%      4    32    60    88   116   144   172   200
%      5    33    61    89   117   145   173   201
%      6    34    62    90   118   146   174   202
%      7    35    63    91   119   147   175   203
%      8    36    64    92   120   148   176   204
%      9    37    65    93   121   149   177   205
%     10    38    66    94   122   150   178   206
%     11    39    67    95   123   151   179   207
%     12    40    68    96   124   152   180   208
%     13    41    69    97   125   153   181   209
%     14    42    70    98   126   154   182   210
%
%     15    43    71    99   127   155   183   211
%     16    44    72   100   128   156   184   212
%     17    45    73   101   129   157   185   213
%     18    46    74   102   130   158   186   214
%     19    47    75   103   131   159   187   215
%     20    48    76   104   132   160   188   216
%     21    49    77   105   133   161   189   217
%     22    50    78   106   134   162   190   218
%     23    51    79   107   135   163   191   219
%     24    52    80   108   136   164   192   220
%     25    53    81   109   137   165   193   221
%     26    54    82   110   138   166   194   222
%     27    55    83   111   139   167   195   223
%     28    56    84   112   140   168   196   224
s.Hist2Grid{1,1} = [[1:12 15:26 ]' [29:40 43:54]'];
s.Hist2Grid{1,2} = [[57:68 71:82]' [85:96 99:110]'];
s.Hist2Grid{1,3} = [[113:124 127:138 ]' [141:152 155:166]'];
s.Hist2Grid{1,4} = [[169:180 183:194]' [197:208 211:222]'];
s.Hist2Grid{2,1} = [[13 27]' [41 55]'];
s.Hist2Grid{2,2} = [[69 83]' [97 111]'];
s.Hist2Grid{2,3} = [[125 139]' [153 167]'];
s.Hist2Grid{2,4} = [[181 195]' [209 223]'];
s.Hist2Grid{3,1} = [[14 28]' [42 56]'];
s.Hist2Grid{3,2} = [[70 84]' [98 112]'];
s.Hist2Grid{3,3} = [[126 140]' [154 168]'];
s.Hist2Grid{3,4} = [[182 196]' [210 224]'];
s.Hist2Color = [rgb('normal orange');rgb('pale orange')];