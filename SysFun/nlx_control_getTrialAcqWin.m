function [AcqWin,AlignTime] = nlx_control_getTrialAcqWin(Ev,CTX)

% returns the trial window and align time

global NLX_CONTROL_SETTINGS


%% data acquisition window for spikes 
AcqWin1_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.AcqEvents(1),[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
AcqWin2_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.AcqEvents(2),[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
AcqWin(1,1) = Ev.TimeStamp(AcqWin1_EvIdx) + NLX_CONTROL_SETTINGS.AcqOffset(1).*1000;
AcqWin(1,2) = Ev.TimeStamp(AcqWin2_EvIdx) + NLX_CONTROL_SETTINGS.AcqOffset(2).*1000;

%% Cut cortex trial
if NLX_CONTROL_SETTINGS.CutCortexTrial == 0

    Align_EvIdx = Ev_findTTL(Ev,NLX_CONTROL_SETTINGS.CndAlignEvent,[CTX.TrialStartTime(CTX.Pointer) Ev_currTimeStamp(Ev)],0);
    AlignTime = Ev.TimeStamp(Align_EvIdx) + NLX_CONTROL_SETTINGS.CndAlignOffset.*1000;

elseif NLX_CONTROL_SETTINGS.CutCortexTrial == 1
%     
%     %----------------------------------------------------------
%     % specific windows for each single condition/presentation
%     % get condition specific acquisition times
%     LoWin = Ev.TimeStamp(ismember(Ev.TTL,NLX_CONTROL_SETTINGS.CndAcqEventsLo) & (Ev.Type==0)) + NLX_CONTROL_SETTINGS.CndAcqOffset(1).*1000;% use 'ismember' here in case of more than one Ev defining an acquisition window
%     HiWin = Ev.TimeStamp(ismember(Ev.TTL,NLX_CONTROL_SETTINGS.CndAcqEventsHi) & (Ev.Type==0)) + NLX_CONTROL_SETTINGS.CndAcqOffset(2).*1000;
%     AlignTime = Ev.TimeStamp(Ev.TTL==NLX_CONTROL_SETTINGS.CndAlignEvent & (Ev.Type==0)) + NLX_CONTROL_SETTINGS.CndAlignOffset.*1000;
%     % make sure you get as many windows as pesented conditions
%     LoWin = LoWin(1:NLX_CONTROL_SETTINGS.PresentationNum);
%     HiWin = HiWin(1:NLX_CONTROL_SETTINGS.PresentationNum);
%     AlignTime = AlignTime(1:NLX_CONTROL_SETTINGS.PresentationNum);
%     % set spike acquisition limits for conditions of first and last stimulus
%     % presentation, to make sure to get ALL spikes in NLX_CONTROL_SETTINGS.AcqEvents
%     LoWin(1) = spkacqwin(1);
%     HiWin(end) = spkacqwin(2);
%     %----------------------------------------------------------
%     
%     AcqWin = zeros(NLX_CONTROL_SETTINGS.PresentationNum,2);
%     AcqWin(1,1) = spkacqwin(1);
%     AcqWin(NLX_CONTROL_SETTINGS.PresentationNum,2) = spkacqwin(2);
%     
%     % check gaps between presentations
%     for i = 1:NLX_CONTROL_SETTINGS.PresentationNum-1
%         if LoWin(i+1)>HiWin(i) % if there is a gap between to sub trials
%             AcqWin(i,2)    = HiWin(i) + (LoWin(i+1)-HiWin(i))/2;
%             AcqWin(i+1,1)  = HiWin(i) + (LoWin(i+1)-HiWin(i))/2;
%         elseif LoWin(i+1)<=HiWin(i) % attention: can duplicate spikes 
%             AcqWin(i,2)    = HiWin(i);
%             AcqWin(i+1,1)  = LoWin(i+1);
%         end
%     end
end
