function [OK,message] = nlx_control_checkTrial(Ev,CTX,NLX_CONTROL_SETTINGS)

message = '';
OK = false;

if CTX.Pointer==0
    message = 'WARNING: *** OMIT trial due to cortex pointer (CTX.Pointer) is zero ***';
    return;
end

% mandatory events
FoundMandatory = Ev_ismemberTTL(Ev,NLX_CONTROL_SETTINGS.MandatoryEvents,[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
AcqWin1_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.AcqEvents(1),[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
AcqWin2_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.AcqEvents(2),[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);

if NLX_CONTROL_SETTINGS.CutCortexTrial == 1
    CndAcqWin1_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.CndAcqEventsLo,[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
    CndAcqWin2_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.CndAcqEventsHi,[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
else
    CndAcqWin1_EvIdx = NaN;
    CndAcqWin2_EvIdx = NaN;
end

if any(~FoundMandatory)
    message = ['WARNING: *** OMIT trial due to MISSING EVENTS ***' num2str(NLX_CONTROL_SETTINGS.MandatoryEvents(~FoundMandatory)) ' !'];
    
elseif (length(CTX.StimulusCodes(CTX.Pointer,:)) ~= NLX_CONTROL_SETTINGS.PresentationNum*NLX_CONTROL_SETTINGS.SendConditionPresentParNum && NLX_CONTROL_SETTINGS.CutCortexTrial == 1)
    message = ['WARNING: *** OMIT trial due to NON EXPECTED NUMBER OF PRESENTATIONS ! ***'];

elseif ( ~checkStimCodeParameter(CTX.StimulusCodes(CTX.Pointer,:),NLX_CONTROL_SETTINGS) && NLX_CONTROL_SETTINGS.CutCortexTrial == 1)
    message = ['WARNING: *** OMIT trial due to NON EXPECTED VALUE OF STIMCODE parameter ! ***'];

elseif ( (length(CndAcqWin1_EvIdx)~=NLX_CONTROL_SETTINGS.PresentationNum) || (length(CndAcqWin2_EvIdx)~=NLX_CONTROL_SETTINGS.PresentationNum) ) && NLX_CONTROL_SETTINGS.CutCortexTrial == 1
    message = ['WARNING: *** OMIT trial due to FALSE NUMBER OF CND-ACQUISITION WINDOW EVENTS ! ***'];

elseif (length(CTX.Condition(CTX.Pointer))~=1) || ~(CTX.Condition(CTX.Pointer)>0 && CTX.Condition(CTX.Pointer)<=NLX_CONTROL_SETTINGS.Cndnum)    
    message = ['WARNING: *** OMIT trial due to FALSE CONDITION NR ! ***'];

elseif (length(CTX.Block(CTX.Pointer))~=1) || ~(CTX.Block(CTX.Pointer)>0 && CTX.Block(CTX.Pointer)<=NLX_CONTROL_SETTINGS.Blocknum);   
    message = ['WARNING: *** OMIT trial due to FALSE BLOCK NR ! ***'];
    
elseif (length(AcqWin1_EvIdx)~=1) || (length(AcqWin2_EvIdx)~=1)
    message = ['WARNING: *** OMIT trial due to FALSE NUMBER OF ACQUISITION WINDOW EVENTS ! ***'];
    
elseif (size(CTX.ParamArray{CTX.Pointer},1)>0) && ~(all(isnan(CTX.ParamArray{CTX.Pointer}))) && (size(CTX.ParamArray{CTX.Pointer},1)~=NLX_CONTROL_SETTINGS.SendParamN)
    message = ['WARNING: *** OMIT trial due to UNEXPECTED NUMBER OF PARAMETER ! ***'];
    
else
    message = '';
    OK = true;
end


function ok = checkStimCodeParameter(StimCodeArray,s)
StimCodeArray = reshape(StimCodeArray,s.SendConditionPresentParNum,s.PresentationNum);
for i=1:s.SendConditionPresentParNum
    ok = all( StimCodeArray(i,:)>=s.SendConditionPresentParRange(i,1) & StimCodeArray(i,:)<=s.SendConditionPresentParRange(i,2));
    if ~ok
        break
    end
end
