function [h,tWF,iWF] = spk_SpikeWavePlot(s,DataOpt,varargin)

% plots spike waveform data
% DataOpt ... 'Mean' plots mean waveform
%             [n] plots n number of random waveforms 

nTr = spk_TrialNum(s);
nCh = spk_SpikeChanNum(s);

%% prepare channels
if isempty(s.currentchan)
    s.currentchan = 1:nCh;
end

%% prepare trials
if isempty(s.currenttrials)
    s.currenttrials = 1:nTr;
end
if ~iscell(s.currenttrials)
    s.currenttrials = {s.currenttrials};
end

%% loop plots
tWF = [];
for iCh = 1:length(s.currentchan)
    cCh = s.currentchan(iCh);
    
    for iTrGrp = 1:length(s.currenttrials)
        
        % get all waveforms
        cWF = cat(1,s.spkwave{cCh,s.currenttrials{iTrGrp}});
        [nWF,nSP] = size(cWF);
        if nWF==0;
            h{iCh,iTrGrp} = [];
            iWF{iCh,iTrGrp} = [];
            continue;
        end
        
        % get time
        tWF = [0:1/s.spkwavefreq:(nSP-1)*(1/s.spkwavefreq)];
        tWF = (tWF-tWF(s.spkwavealign))*1000;
        
        
        
        if ischar(DataOpt)
            switch upper(DataOpt)
                case 'MEAN'
                   cWFmean = nanmean(cWF,1);
                   cWFstd = nanstd(cWF,0,1);
                   h{iCh,iTrGrp}(1) = line(tWF,cWFmean,'linewidth',2,varargin{:});
                   h{iCh,iTrGrp}(2) = line(tWF,cWFmean+cWFstd,'linewidth',0.75,varargin{:});
                   h{iCh,iTrGrp}(3) = line(tWF,cWFmean-cWFstd,'linewidth',0.75,varargin{:});
            end
        elseif isnumeric(DataOpt) 
            if (isempty(DataOpt) || DataOpt>nWF)
                DataOpt = nWF;
                iWF{iCh,iTrGrp} = 1:nWF;
            elseif ~isempty(DataOpt)
                iWF{iCh,iTrGrp} = randsample(nWF,DataOpt);
                nWF = DataOpt;
            end
            h{iCh,iTrGrp} = line(repmat(tWF',1,nWF),cWF(iWF{iCh,iTrGrp},:)',varargin{:});
        end
        
        
    end
end


