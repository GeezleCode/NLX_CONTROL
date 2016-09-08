function s = spk_nlxget(s,p,dofun)

% connects to a cheetah data acquisition software and writes data into a
% @al_spk object
% object is continously assigned the base workspace as variable SPK or is
% written into the figures ('tag','nlx_control') userdata.
%
% s ....... @al_spk object
% p ....... cheetah acquisition settings (struct)
% dofun ... cell array with functions to evaluate after every trial
%           first cell of a row is the function, every other cell of the
%           are the input arguments of the function

% 18/5/05 changed channel naming from '1'=unclassified to '0'=unclassified

global DO_GET_NLX_DATA


%++++++++++++++++++++++ connect to cheetah +++++++++++++++++++++++++++++++++
cheetah = actxserver('Cheetah.ExperimentControl');

h = msgbox('Make sure to RECORD the CHEETAH DATA by starting the CheetahEventResponder executable or by pushing the RED record button manually !!!','NEURALYNX control','warn');
uiwait;
%++++++++++++++++++++++ prepare logfile+++++++++++++++++++++++++++++++++++++
currtime = now;
currdate = datestr(now,30);
logfilename = ['NLXLOG_' currdate '.txt'];
logfilepath = fullfile([fileparts(which('nlx_control')) '\log'],logfilename);
logfid = fopen(logfilepath,'w');

fprintf(1,['\n']);
fprintf(1,['-------------------------------------------------------------------------------\n']);
fprintf(1,(strrep(['write to ' fullfile(cd,logfilepath) ' !'],'\','/')));
fprintf(1,['\n']);
fprintf(1,['-------------------------------------------------------------------------------\n']);
fprintf(logfid,['\n']);
fprintf(logfid,['-------------------------------------------------------------------------------\n']);
fprintf(logfid,['log file opened: ' datestr(currtime,0) ' NLX time: %12.0f\n'],invoke(cheetah,'GetTimeStampAsDouble'));
fprintf(logfid,['-------------------------------------------------------------------------------\n']);


%++++++++++++++++++++++ flush spike buffer from useless spike data
flushwin = [0 invoke(cheetah,'GetTimeStampAsDouble')];

[spikedata,flushnum] = flushspikes(cheetah,p.SpikeObjName{1},flushwin);
fprintf(1,['\nSPIKES: %5u flushed \t%12.0f %12.0f'],flushnum,flushwin(1),flushwin(2));
fprintf(logfid,['\nSPIKES: %5u flushed \t%12.0f %12.0f'],flushnum,flushwin(1),flushwin(2));

[eventdata,flushnum] = flushevents(cheetah,p.EventObjName,flushwin);
fprintf(1,['\nEVENTS: %5u flushed \t%12.0f %12.0f\n'],flushnum,flushwin(1),flushwin(2));
fprintf(logfid,['\nEVENTS: %5u flushed \t%12.0f %12.0f\n'],flushnum,flushwin(1),flushwin(2));

%++++++++++++++++++++++ check object +++++++++++++++++++++++++++++++++
spk_CortexBlockInd = spk_findtrialcodelabel(s,'CortexBlock');
if isempty(spk_CortexBlockInd)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'CortexBlock'});
    spk_CortexBlockInd = length(s.trialcodelabel);
end
%--------------------------------------------------------------------
spk_CortexConditionInd = spk_findtrialcodelabel(s,'CortexCondition');
if isempty(spk_CortexConditionInd)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'CortexCondition'});
    spk_CortexConditionInd = length(s.trialcodelabel);
end
%--------------------------------------------------------------------
spk_CortexPresentationNrInd = spk_findtrialcodelabel(s,'CortexPresentationNr');
if isempty(spk_CortexPresentationNrInd)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'CortexPresentationNr'});
    spk_CortexPresentationNrInd = length(s.trialcodelabel);
end
%--------------------------------------------------------------------
spk_StimulusCodeInd = spk_findtrialcodelabel(s,'StimulusCode');
if isempty(spk_StimulusCodeInd)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'StimulusCode'});
    spk_StimulusCodeInd = length(s.trialcodelabel);
end
%--------------------------------------------------------------------
spk_cortextrialcountind = spk_findtrialcodelabel(s,'CortexTrialCount');
if isempty(spk_cortextrialcountind)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'CortexTrialCount'});
    spk_cortextrialcountind = length(s.trialcodelabel);
end
%--------------------------------------------------------------------
spk_startedtrialcountind = spk_findtrialcodelabel(s,'StartedTrialCount');
if isempty(spk_startedtrialcountind)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'StartedTrialCount'});
    spk_startedtrialcountind = length(s.trialcodelabel);
end
%--------------------------------------------------------------------
spk_TrialInd = spk_findtrialcodelabel(s,'trialnr');
if isempty(spk_TrialInd)
    s.trialcodelabel = cat(2,s.trialcodelabel,{'trialnr'});
    spk_TrialInd = length(s.trialcodelabel);
end
s = spk_set(s,'currenttrials',[]);
TRIALCNTinObj2 = spk_gettrialcodes(s,'trialnr');
if isempty(TRIALCNTinObj2)
    TRIALCNTinObj2 = 0;
else
    s = spk_set(s,'currenttrials',[]);
    TRIALCNTinObj2 = max(spk_gettrialcodes(s,'trialnr'));
end
%--------------------------------------------------------------------
if isempty(s.channel)
    s.channel = {'0' '1' '2' '3' '4' '5'};
    s.chancolor = [ ...
            1 1 1; ...      white
            1 0 0; ...      red
            0 1 0; ...      green
            0 0 1; ...      blue
            1 1 0; ...       yellow
            .5 0 1 ...     purple;
        ];
end
ChanIndex = spk_findchannel(s,{'0' '1' '2' '3' '4' '5'});
ChanIndex(isnan(ChanIndex)) = [];
ChanIndexNum = length(ChanIndex);

%--------------------------------------------------------------------
if isempty(s.eventlabel)
    s.eventlabel = p.EventName;
end
%--------------------------------------------------------------------
if isempty(s.date)
    s.date = datestr(now,30);
end
%--------------------------------------------------------------------
% timestmaps in milliseconds
s.timeorder = -3;



%+++++++++++++++++++++ initialise ++++++++++++++++++++++++++++++++
spkTime     = zeros(1,3000);
spkChannel  = zeros(1,3000);
spkCell     = zeros(1,3000);
%--------------------------------------------------------------------
% event codes encoding process flow of trial
evcnt = 0;% event counter for the current trial
evTime      = zeros(1,500);% vector of event times
evID        = zeros(1,500);
evTTL       = zeros(1,500);
evBINhi       = char(500,8);% event code as binary
evBINlo       = char(500,8);
evType = zeros(1,500).*NaN;

%--------------------------------------------------------------------
currCortexBlock = NaN;
currCortexCnd = NaN;
currStimCode = NaN;
currPresentationNum = 0;
ConditionParam = [];
%--------------------------------------------------------------------
TRIALCNTinObj = spk_numtrials(s);% trial counter of READ trials for the current loop
% dont uncomment !! TRIALCNTinObj2 is trial counter for data object
TRIALCNTstarted = 0;% counts cortex trial starts in this session
currTRIALinObj = zeros(1,p.PresentationNum).*NaN;% current presented array of READ trials in Object

if ~isempty(s.trialcode)
    TRIALCNTcortex = max(s.trialcode(spk_cortextrialcountind,:));% counts cortex trials
else
    TRIALCNTcortex = 0;
end

%--------------------------------------------------------------------
TRIAL_HANDBRAKE = 1;% is set by the trial start and stop events
%--------------------------------------------------------------------
spkcnt = 0;
paramcnt = 0;
do_READ_flag = 1;
is_READ_flag = 0;
FH = findobj('type','figure','tag','nlx_control');

%++++++++++++++ prepare plots and analyses ++++++++++++++++++++++++++++++++++++
for f = 1:size(dofun,1)
    feval(dofun{f,:},s,[],p);
end


%+++++++++++++++++++++ collect data ++++++++++++++++++++++++++++++++

while DO_GET_NLX_DATA
    
    %______________________________________________________________________
    % wait for event
    while (eventdata(1) < 0) | (eventdata(3) == 0) 
        pause(.01);
        eventdata = invoke(cheetah,'GetEventDataAsDouble',p.EventObjName);
        if ~DO_GET_NLX_DATA;break;end %DO_GET_NLX_DATA is set by nlx_control gui !!
    end
    if ~DO_GET_NLX_DATA;break;end

    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % trial start event
    % only reset variables !!!
    if eventdata(3)==p.TrialStartEvent
        TRIAL_HANDBRAKE = 0;
        
        % reset runnning variables
        TRIALCNTstarted = TRIALCNTstarted + 1;
        currTRIALinObj = zeros(1,p.PresentationNum).*NaN;
        do_READ_flag = 1;
        is_READ_flag = 0;
        currCortexBlock = NaN;
        currCortexCnd = NaN;
        currStimCode = NaN;
        currPresentationNum = 0;
        ConditionParam = [];
        
        evcnt = 0;
        evTime(:) = 0;evID(:) = 0;evTTL(:) = 0;evBINhi(:) = '0';evBINlo(:) = '0';evType(:) = 0;
        paramcnt = 0;
        paramArray = [];
        
        
        fprintf(1,'\n\nTRIALS READ %u TRIALS STARTED %u TRIALS IN OBJECT %u',TRIALCNTinObj,TRIALCNTstarted,TRIALCNTinObj2);
        fprintf(logfid,'\n\nTRIALS READ %u TRIALS STARTED %u TRIALS IN OBJECT %u',TRIALCNTinObj,TRIALCNTstarted,TRIALCNTinObj2);
        fprintf(1,'\n\nNEW TRIAL');
        fprintf(logfid,'\n\nNEW TRIAL');

%         % flush all spike before trial start
%         flushwin = [0 eventdata(3)];
%         [spikedata,flushnum] = flushspikes(cheetah,p.SpikeObjName{1},flushwin);
%         fprintf(1,['\nSPIKES: %5u flushed \t%12.0f %12.0f'],flushnum,flushwin(1),flushwin(2));
%         fprintf(logfid,['\nSPIKES: %5u flushed \t%12.0f %12.0f'],flushnum,flushwin(1),flushwin(2));
        
    end
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    
    
    
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % register event
    [eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt] = registerevent(eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt);
    evType(evcnt) = 0;
    printeventmessage(logfid,evTime,evID,evTTL,evBINhi,evBINlo,evType,p,evcnt);
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
    
    
    
    %++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    % choose action depending on the event
    if  eventdata(3)==p.SendConditionStart
        
        paramcnt = 0;
        eventdata(1:3) = -1001;
        
        % read upcoming events as parameter values
        while (eventdata(1) < 0) | (eventdata(3) ~= p.SendConditionEnd)
            eventdata = invoke(cheetah,'GetEventDataAsDouble',p.EventObjName);
            if (eventdata(1) < 0);
                pause(.01);
            elseif (eventdata(1) > 0 & eventdata(3) ~= 0);
                [eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt] = registerevent(eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt);
                if (eventdata(3)~= p.SendConditionEnd) % read as condition number
                    evType(evcnt) = 2;
                    printeventmessage(logfid,evTime,evID,evTTL,evBINhi,evBINlo,evType,p,evcnt);
                elseif (eventdata(3)== p.SendConditionEnd) % read as event
                    evType(evcnt) = 1;
                    printeventmessage(logfid,evTime,evID,evTTL,evBINhi,evBINlo,evType,p,evcnt);
                    break;
                end
            end
        end
        
        % reset condition and block array
        currCortexBlock = NaN;
        currCortexCnd = NaN;
        currStimCode = NaN;
        currPresentationNum = 0;
        ConditionParam = [];
        
        ConditionParam = evTTL(evType==2);
        if isempty(ConditionParam)
            do_READ_flag = 0;
        else
            currCortexBlock = ConditionParam(1);
            currCortexCnd = ConditionParam(2);
            if length(ConditionParam)>2
                currStimCode = ConditionParam(3:end);
            end
            currPresentationNum = length(currStimCode);
        end
        
        fprintf(1,'\nBLOCK ');fprintf(1,'%u ',currCortexBlock);
        fprintf(1,'\nCONDITION ');fprintf(1,'%u ',currCortexCnd);
        fprintf(1,'\nSTIMULUS ');fprintf(1,'%u ',currStimCode);
        
        fprintf(logfid,'\nBLOCK ');fprintf(logfid,'%u ',currCortexBlock);
        fprintf(logfid,'\nCONDITION ');fprintf(logfid,'%u ',currCortexCnd);
        fprintf(logfid,'\nSTIMULUS ');fprintf(logfid,'%u ',currStimCode);
        
    elseif eventdata(3)== p.SendParamStart%-------------------------------------------------------------------------------------------------
        paramcnt = 0;
        eventdata(1:3) = -1001;
        paramsendflag = 0;
        pausetime = 0;
        while ~paramsendflag
            eventdata = invoke(cheetah,'GetEventDataAsDouble',p.EventObjName);
            % read upcoming events as parameter values
           if (eventdata(1) < 0);
                pause(.01);
                pausetime = pausetime + .01;
                if pausetime>1;
                    fprintf(1,'\nWARNING: waited more than 1 second for parameter value !');
                    fprintf(logfid,'\nWARNING: waited more than 1 second for parameter value !');
                    break;
                end
            elseif (eventdata(1) > 0 & eventdata(3) ~= 0)
                pausetime = 0;
                [eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt] = registerevent(eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt);
                % detect end of stimparameter (pattern: p.SendParamEnd 0 p.SendParamEnd)
                if (evcnt>=2) & (evTTL(evcnt-1)==p.SendParamEnd & evTTL(evcnt)==p.SendParamEnd)
                    evType(evcnt) = 1;
                    printeventmessage(logfid,evTime,evID,evTTL,evBINhi,evBINlo,evType,p,evcnt);
                    paramsendflag = 1;
                    break;
                else
                    evType(evcnt) = 3;
                    printeventmessage(logfid,evTime,evID,evTTL,evBINhi,evBINlo,evType,p,evcnt);
                end
                
            end
        end
        
        paramArray = NaN;
        paramArray = [evTime(evType==3)' evTTL(evType==3)'];
        % neglect last entries (stop event)
        paramArray = paramArray(1:end-1,:);
        paramcnt = size(paramArray,1);
        
        fprintf(1,'\n==> ');fprintf(1,'(%u values): ',paramcnt);fprintf(1,'%u ',paramArray(:,2)');
        fprintf(logfid,'\n==> ');fprintf(logfid,'(%u values): ',paramcnt);fprintf(logfid,'%u ',paramArray(:,2)');
        
        % first parameter should give numbers of parameter
        if paramcnt~=paramArray(1,2)
            fprintf(1,'\nWARNING: unexpected number of parameter -> do_READ_flag = 0!');
            fprintf(logfid,'\nWARNING: unexpected number of parameter -> do_READ_flag = 0!');
            do_READ_flag = 0; % dont read data if there are any
            %irregularities in the number of parameters
        end
        
    elseif eventdata(3)== p.TrialEndEvent%-------------------------------------------------------------------------------------------------
        
        % add trial end event to @al_spk object
        if is_READ_flag
            currTRIALinObj = currTRIALinObj(~isnan(currTRIALinObj));
            for i = currTRIALinObj
                s.events{p.EventCode == p.TrialEndEvent,i} = evTime(evTTL==p.TrialEndEvent & (evType==0|evType==1)).*0.001 - s.align(i);
            end
        end

        currTRIALinObj = zeros(1,p.PresentationNum).*NaN; 
        evcnt = 0;
        fprintf(logfid,'\nEND OF TRIAL');
        fprintf(1,'\nEND OF TRIAL');
        
        TRIAL_HANDBRAKE = 1;
        
    elseif eventdata(3)== p.ReadDataEvent%-------------------------------------------------------------------------------------------------
        
        % check for save reading of trial data
        if any(~ismember(p.MandatoryEvents,evTTL(evType==0|evType==1))) 
            fprintf(1,['\nWARNING: *** OMIT trial due to MISSING EVENTS *** ' num2str(p.MandatoryEvents(~ismember(p.MandatoryEvents,evTTL(evType==0|evType==1)))) ' !']);
            fprintf(logfid,['\nWARNING: *** OMIT trial due to MISSING EVENTS *** ' num2str(p.MandatoryEvents(~ismember(p.MandatoryEvents,evTTL(evType==0|evType==1)))) ' !']);
        elseif (currPresentationNum ~= p.PresentationNum & p.CutCortexTrial == 1)
            fprintf(1,['\nWARNING: *** OMIT trial due to NON EXPECTED NUMBER OF PRESENTATIONS ! ***']);
            fprintf(logfid,['\nWARNING: *** OMIT trial due to NON EXPECTED NUMBER OF PRESENTATIONS ! ***']);
        elseif ~do_READ_flag    
            fprintf(1,['\nWARNING: *** OMIT trial due to do_READ_flag=0 ! ***']);
            fprintf(logfid,['\nWARNING: *** OMIT trial due to do_READ_flag=0 ! ***']);
        elseif ~(currCortexCnd>0 & currCortexCnd<=p.Cndnum)    
            fprintf(1,['\nWARNING: *** OMIT trial due to FALSE CONDITION NR ! ***']);
            fprintf(logfid,['\nWARNING: *** OMIT trial due to FALSE CONDITION NR! ***']);
        elseif ~(currCortexBlock>0 & currCortexBlock<=p.Blocknum)   
            fprintf(1,['\nWARNING: *** OMIT trial due to FALSE BLOCK NR ! ***']);
            fprintf(logfid,['\nWARNING: *** OMIT trial due to FALSE BLOCK NR ! ***']);
        elseif (sum(evTTL==p.AcqEvents(1) & (evType==0|evType==1))~=1) | (sum(evTTL==p.AcqEvents(2) & (evType==0|evType==1))~=1)
            fprintf(1,['\nWARNING: *** OMIT trial due to FALSE NUMBER OF ACQUISITION WINDOW EVENTS ! ***']);
            fprintf(logfid,['\nWARNING: *** OMIT trial due to FALSE NUMBER OF ACQUISITION WINDOW EVENTS ! ***']);
        else
            
            % set flag for 
            is_READ_flag = 1;
            
            %*********************************************************************************************************
            currSpikeTime = spikedata(1);% current data in spikedata
            
            % define data acquisition window for spikes
            spkacqwin = [evTime(evTTL==p.AcqEvents(1) & (evType==0|evType==1)) + p.AcqOffset(1).*1000 , ...
                    evTime(evTTL==p.AcqEvents(2) & (evType==0|evType==1)) + p.AcqOffset(2).*1000];
            fprintf(1,'\nSPIKES: 1st spike @%12.0f, acq win %12.0f - %12.0f = %12.0f',currSpikeTime,spkacqwin(1),spkacqwin(2),spkacqwin(2)-spkacqwin(1));
            fprintf(logfid,'\nSPIKES: 1st spike @%12.0f, acq win %12.0f - %12.0f = %12.0f',currSpikeTime,spkacqwin(1),spkacqwin(2),spkacqwin(2)-spkacqwin(1));
            
            % get spikes within the data acquisition window
            spkcnt = 0;
            spkTime(:)      = 0;
            spkChannel(:)   = 0;
            spkCell(:)      = 0;
        
            flushnum = 0;
            pausetime = 0;
            pausetimeTotal = 0;
            spkreadloopcnt = 0;
            
            while   (spikedata(1) <= spkacqwin(2)) &  (pausetime<3)
                
                Cheetah_Error_Check(spikedata(1));
                
                spkreadloopcnt = spkreadloopcnt +1;
                
                if spikedata(1) == -1001 % no spikes in cheetah
                    pause(.01);
                    pausetime = pausetime + .01;
                    pausetimeTotal = pausetimeTotal +.01;
                    
                elseif (spikedata(1) >= 0) & (spikedata(1) < spkacqwin(1)) % spike not in window
                    flushnum = flushnum+1;
                    
                elseif spikedata(1) >= spkacqwin(1) % read spike
                    
                    % reset pause time
                    pausetime = 0;
                    
                    % add current spike to array
                    spkcnt = spkcnt + 1;
                    spkTime(spkcnt) = spikedata(1);
                    spkChannel(spkcnt) = spikedata(2);
                    spkCell(spkcnt) = spikedata(3);
                    
                end
                
                % get next spike
                spikedata = invoke(cheetah,'GetSpikeDataAsDouble',p.SpikeObjName{1});
            end
            
            % message
            if pausetime>=3
                fprintf(1,'\nWARNING: waited more than 3 seconds to read valid spike data from cheetah!');
                fprintf(logfid,'\nWARNING: waited more than 3 seconds to read valid spike data from cheetah!');
            end
            
            fprintf(1,'\nSPIKES: %5u flushed, %5u read, %u iterations',flushnum,spkcnt,spkreadloopcnt);
            fprintf(logfid,'\nSPIKES: %5u flushed, %5u read, %u iterations',flushnum,spkcnt,spkreadloopcnt);
            
            %*********************************************************************************************************
                        
            
            %++++++++++++++ read data into structure ++++++++++++++++++++++++++++++++++++
            %#####################################
            %##### convert times to MILLISECONDS #
            %#####################################
            evTime = evTime.*0.001;
            spkTime = spkTime.*0.001;
            
            TRIALCNTcortex = TRIALCNTcortex+1;
            
            if p.CutCortexTrial == 0
                NumCuts = 1;
                LoWin = spkacqwin(1).*0.001;
                HiWin = spkacqwin(2).*0.001;
                AlignTime = evTime(evTTL==p.CndAlignEvent & (evType==0|evType==1)) + p.CndAlignOffset;
                AlignTime = AlignTime(1);
                
            elseif p.CutCortexTrial == 1
                NumCuts = p.PresentationNum;
                
                %----------------------------------------------------------
                % specific windows for each single condition/presentation
                % get condition specific acquisition times
                LoWin = evTime(ismember(evTTL,p.CndAcqEventsLo) & (evType==0|evType==1)) + p.CndAcqOffset(1);% use 'ismember' here in case of more than one event defining an acquisition window
                HiWin = evTime(ismember(evTTL,p.CndAcqEventsHi) & (evType==0|evType==1)) + p.CndAcqOffset(2);
                AlignTime = evTime(evTTL==p.CndAlignEvent & (evType==0|evType==1)) + p.CndAlignOffset;
                % make sure you get as many windows as pesented conditions
                LoWin = LoWin(1:NumCuts);
                HiWin = HiWin(1:NumCuts);
                AlignTime = AlignTime(1:NumCuts);
                % set spike acquisition limits for conditions of first and last stimulus
                % presentation, to make sure to get ALL spikes in p.AcqEvents
                LoWin(1) = evTime(evTTL==p.AcqEvents(1) & (evType==0|evType==1))+p.AcqOffset(1);
                HiWin(end) = evTime(evTTL==p.AcqEvents(2) & (evType==0|evType==1))+p.AcqOffset(2);
                %----------------------------------------------------------
            end
            
            
            % read data into @al_spk object
            for i = 1:NumCuts
                TRIALCNTinObj = TRIALCNTinObj+1;
                TRIALCNTinObj2 = TRIALCNTinObj2 + 1;
                currTRIALinObj(i) = TRIALCNTinObj2;
                s.trialcode(spk_CortexBlockInd,TRIALCNTinObj) = currCortexBlock;
                s.trialcode(spk_CortexConditionInd,TRIALCNTinObj) = currCortexCnd;
                if p.CutCortexTrial == 0
                    s.trialcode(spk_StimulusCodeInd,TRIALCNTinObj) = NaN;
                    s.trialcode(spk_CortexPresentationNrInd,TRIALCNTinObj) = NaN;
                elseif p.CutCortexTrial == 1
                    s.trialcode(spk_StimulusCodeInd,TRIALCNTinObj) = currStimCode(i);
                    s.trialcode(spk_CortexPresentationNrInd,TRIALCNTinObj) = i;
                end
                s.trialcode(spk_TrialInd,TRIALCNTinObj) = TRIALCNTinObj2;
                s.trialcode(spk_cortextrialcountind,TRIALCNTinObj) = TRIALCNTcortex;
                s.trialcode(spk_startedtrialcountind,TRIALCNTinObj) = TRIALCNTstarted;
                s.align(TRIALCNTinObj) = AlignTime(i);
                % every trial in data structure has ALL the events of a
                % cortex trial
                fprintf(logfid,'\nSPIKES: pres.# %u acq win %12.0f - %12.0f = %12.0f',i,LoWin(i).*1000,HiWin(i).*1000,HiWin(i)-LoWin(i).*1000);
                for j=1:length(p.EventCode)
                    s.events{j,TRIALCNTinObj} = evTime(evTTL==p.EventCode(j) & (evType==0|evType==1)) - s.align(TRIALCNTinObj);
                end
                for k = 1:ChanIndexNum
                    % get the spikes within the current condition/presentation window
                    if (HiWin(i)-LoWin(i))>0
                        s.spk{k,TRIALCNTinObj} = spkTime(spkCell==str2num(s.channel{ChanIndex(k)}) & spkTime>=LoWin(i) & spkTime<=HiWin(i)) - s.align(TRIALCNTinObj);
                    end
                end
                s.stimulus{TRIALCNTinObj} = paramArray;
            end
            
            %#####################################
            %##### convert times to MICROSECONDS #
            %#####################################
            evTime = evTime.*1000;
            spkTime = spkTime.*1000;
            
            spkacqwin = [0 0]; % reset spike acq window

            %++++++++++++++ analyse data ++++++++++++++++++++++++++++++++++++
            for f = 1:size(dofun,1)
                feval(dofun{f,:},s,[TRIALCNTinObj-(NumCuts-1):TRIALCNTinObj],p);
            end
        end%read end
        
        
    else
    end% end switch
    
    eventdata(1) = -1001;
    
    s.userdata.NLXsettings = p;
    
    if isempty(FH)
        assignin('base','SPK',s);
    else
        set(FH,'userdata',s);
    end
end

currtime = now;

fprintf(logfid,'\n');
fprintf(logfid,['-------------------------------------------------------------------------------\n']);
fprintf(logfid,['log file closed: ' datestr(currtime,0) ' NLX time: %12.0f\n'],invoke(cheetah,'GetTimeStampAsDouble'));
fprintf(logfid,['-------------------------------------------------------------------------------\n']);
fprintf(logfid,'\n');
fprintf(logfid,'\n');
fclose(logfid);

delete(cheetah);
% release(cheetah);

return
           
%==========================================================================
function [eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt] = registerevent(eventdata,evTime,evID,evTTL,evBINhi,evBINlo,evcnt)
if eventdata(1)<0
    return;
elseif eventdata(3)<0
    eventdata(3) = 2*2^(16-1) + eventdata(3);% convert negative evTTL, interpreting negative integers as 2's complement
end
if eventdata(3)>0
    evcnt = evcnt + 1;
    evTime(evcnt)   = eventdata(1);
    evID(evcnt)     = eventdata(2);
    evTTL(evcnt)    = eventdata(3);
    currBinary       = fliplr(dec2bin(eventdata(3),16));
    evBINhi(evcnt,1:8)       =  fliplr(currBinary(9:16));
    evBINlo(evcnt,1:8)       =  fliplr(currBinary(1:8));
end

%==========================================================================
function printeventmessage(logfid,evTime,evID,evTTL,evBINhi,evBINlo,evType,p,evcnt)
    %______________________________________________________________________
    % print event message
    if ~isempty(p) & (p.PrintEventEcho==0)
        return;
    end
    fprintf(logfid,'\n');
    fprintf(logfid,'%5u ',evcnt);
    fprintf(logfid,'%12.0f ',evTime(evcnt));
    fprintf(logfid,'%4u ',evID(evcnt));
    fprintf(logfid,'%4u ',evType(evcnt));
    fprintf(logfid,'%5u ',evTTL(evcnt));
    fprintf(logfid,[evBINhi(evcnt,:) ' ']);
    fprintf(logfid,[evBINlo(evcnt,:) ' ']);
    fprintf(logfid,'# ');

    lastEvent = find(evTime<evTime(evcnt) & evTTL~=0);
    if evcnt>1 & ~isempty(lastEvent)
        fprintf(logfid,'+ %12.3f ms ',(evTime(evcnt)-evTime(lastEvent(end))).*0.001);
    else
        fprintf(logfid,'  %12.3f ms ',evTime(evcnt).*0.001);
    end
    if (~isempty(p)) & (evType(evcnt)==0|evType(evcnt)==1)
        fprintf(logfid,['    ' p.EventName{p.EventCode==evTTL(evcnt)}]);
    end

%==========================================================================
function [spikedata,flushnum] = flushspikes(cheetah,cheetahobjname,flushwin)
flushnum = 0;
pausetime = 0;
spikedata = -1001;

spikedata = invoke(cheetah,'GetSpikeDataAsDouble',cheetahobjname);
if spikedata(1)==-101;error('no cheetah object available ...');end

while (spikedata(1) == -1001) | (spikedata(1)>=flushwin(1) & spikedata(1)<=flushwin(2))
    if spikedata(1) == -1001            % no spikes in object
        pause(0.01);                    % wait a bit
        pausetime = pausetime + .01;    % increment pause time
        if pausetime>1;break;end        % check for pause limit
    else
        flushnum = flushnum +1;         % add current spike to flush number
        pausetime = 0;                  % reset pause time
    end
    spikedata = invoke(cheetah,'GetSpikeDataAsDouble',cheetahobjname);
end

%==========================================================================
function [eventdata,flushnum] = flushevents(cheetah,cheetahobjname,flushwin)
flushnum = 0;
pausenum = 0;
eventdata = -1001;
eventdata = invoke(cheetah,'GetEventDataAsDouble',cheetahobjname);
if eventdata(1)==-101
    error('no cheetah object available ...');
end
while (eventdata(1) == -1001) | (eventdata(1)>=flushwin(1) & eventdata(1)<=flushwin(2))
    if eventdata(1) == -1001
        pause(0.01);
        pausenum = pausenum +1;
        if pausenum>2;break;end
    else
        flushnum = flushnum +1;
    end
    eventdata = invoke(cheetah,'GetEventDataAsDouble',cheetahobjname);
end

%---------------------------------------------------------------------------------------------------------
% This function is passed a parameter that is a value returned from a call to cheetah.  The value is tested
% for a negative value that would indicate that an error has been recieved since all timestamps are positive.
% However the error code of -1001 is overlooked because this is the empty buffer code and is dealt with within
% the caller function is its own manner.
%---------------------------------------------------------------------------------------------------------
function Cheetah_Error_Check(value)

    if ( value < 0 ) & ( value ~= -1001 ) 
        disp(value);
        r = input('Cheetah returned the above error, press enter to proceed, any other key to exit ','s');
   
        if ~isempty(r)  %if return has been hit, ret will be empty and the program will continue, else it will terminate
            return
        end
    end
