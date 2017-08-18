function spk_AnalogPlotOverview(s,TrialCodeLabel,Chan)

% plots all the trials of an analog channel grouped by trialcode labels

% check conditions
CodeIdx = ismember(s.trialcodelabel,TrialCodeLabel);
[Cnds,dummy,TrialCnd] = unique(s.trialcode(CodeIdx,:)','rows');
NumCnd = size(Cnds,1);
NumCycles = zeros(size(Cnds));
for i=1:NumCnd
    NumCycles(i) = sum(TrialCnd==i);
end
maxNumCycles = max(NumCycles);


if nargin>=3;s.currentanalog = Chan;end
t = spk_analogtimematrix(s);
ylim = max(abs([max(s.analog{s.currentanalog}(:)) min(s.analog{s.currentanalog}(:))]));

% prepare figure
for iCnd = 1:NumCnd
    hf(iCnd) = figure('numbertitle','off','name',sprintf('%1.0f ',Cnds(iCnd,:)),'units','normalized','paperorientation','landscape');
    cCndTr = find(TrialCnd == iCnd);
    for iCyc=1:length(cCndTr)
        ha(iCyc) = subaxes(hf(iCnd),[maxNumCycles 1],[iCyc 1],[0.01 0],[0.1 0.1 0.1 0.1]);
        h = line(t',s.analog{s.currentanalog}(cCndTr(iCyc),:)', ...
            'color','k','linewidth',0.75,'clipping','off');
        set(gca,'xlim',[t(1) t(end)],'ylim',[-ylim ylim],'visible','on');
        text(t(1),ylim,sprintf('%1.0f ',cCndTr(iCyc)),'horizontalalignment','left','verticalalignment','top','fontsize',10);
    end
end

