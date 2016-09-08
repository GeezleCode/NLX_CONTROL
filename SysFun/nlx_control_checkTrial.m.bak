function [OK,message] = nlx_control_checkTrial(Ev,CTX,NLX_CONTROL_SETTINGS)

message = '';
OK = false;

% mandatory events
FoundMandatory = Ev_ismemberTTL(Ev,NLX_CONTROL_SETTINGS.MandatoryEvents,[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
AcqWin1_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.AcqEvents(1),[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
AcqWin2_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.AcqEvents(2),[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);

if any(~FoundMandatory)
    message = ['WARNING: *** OMIT trial due to MISSING EVENTS ***' num2str(NLX_CONTROL_SETTINGS.MandatoryEvents(~FoundMandatory)) ' !'];
    
elseif (length(CTX.StimulusCodes(CTX.Pointer,:)) ~= NLX_CONTROL_SETTINGS.PresentationNum && NLX_CONTROL_SETTINGS.CutCortexTrial == 1)
    message = ['WARNING: *** OMIT trial due to NON EXPECTED NUMBER OF PRESENTATIONS ! ***'];

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
