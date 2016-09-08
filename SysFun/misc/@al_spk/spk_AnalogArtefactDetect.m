function [i] = spk_AnalogArtefactDetect(s,Ev1,Ev2,DoPlot,CritMethod,varargin)

% detects artefact in trials
%
% [i] = spk_AnalogArtefactDetect(s, ... )
% returns trial indices (i)
%
% ... = spk_AnalogArtefactDetect(s,Ev1,Ev2,DoPlot, ... )
% Ev1,Ev2: detection window
% DoPlot: plot detection results
%
% ... = spk_AnalogArtefactDetect(s,...,'OUTLIER_FFT',zThresh
% Applies FFT, Power-Z-Score are thresholded


%% check analog channels
nCh = length(s.currentanalog);
[currenttrials,s] = spk_CheckCurrentTrials(s,true);
nTr = length(s.currenttrials);

%% loop channels
for iCh = 1:nCh
    ChNr = s.currentanalog(iCh);
    [nT,nB] = size(s.analog{ChNr});
    
    [bWin,tWin,t] = spk_AnalogEventWindow(s,Ev1,Ev2);
    
    switch CritMethod
        case 'OUTLIER_FFT'
            for iTr = 1:nTr
                [PS(:,iTr),F,fft_N] = fftspectrumc(s.analog{ChNr}(s.currenttrials(iTr),bWin(iTr,1):bWin(iTr,2))',s.analogfreq(ChNr),1024);
            end
            PSmean = nanmean(PS,2);
            PSstd = nanstd(PS,0,2);
            PSz = (PS-repmat(PSmean,1,nTr))./repmat(PSstd,1,nTr);
            iF = F>=varargin{2} & F<=varargin{3};
            iTr = find(any(PSz(iF,:)>=varargin{1},1));
            i = s.currenttrials(iTr);
            if DoPlot
                ytick = [0:25:500];
                for iy = 1:length(ytick)
                    [d,ytickb(iy)] = min(abs(F-ytick(iy)));
                end
                nTr = length(iTr);
                
                figure;
                imagesc(PSz);
                set(gca,'ytick',ytickb,'yticklabel',ytick);
                line(iTr,repmat(1,1,nTr),'linestyle','none','marker','v','markerfacecolor','r','markersize',6,'clipping','off')
                
                figure
                s = spk_set(s,'currentanalog',ChNr,'currenttrials',i);
                [h,TrialSpread] = spk_AnalogLine(s,[],tWin(iTr,:),200,'color','b');
                
            end
    end
end


