function s = spk_SpikeWave2PC(s,iWF,iPC)

% converts spike-waveforms to principal components using princomp.m

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

%% prepare memory for all spikes
nSpksTrial = cellfun('size',s.spkwave,1);
nWFs = cellfun('size',s.spkwave,2);
WFlength = max(nWFs(:));
nSpks = sum(sum(nSpksTrial(s.currentchan,s.currenttrials)));
allWFs = zeros(nSpks,WFlength).*NaN;

if nargin<2 || isempty(iWF)
    iWF = 1:WFlength;
end
if nargin<3 || isempty(iPC)
    iPC = 1:WFlength;
end 

%% collect spike waveforms
cWFcount = 0;
for iCh = 1:length(s.currentchan)
    cCh = s.currentchan(iCh);
    for iTr = 1:length(s.currenttrials)
        cTrNr = s.currenttrials(iTr);
        allWFs(cWFcount+1:cWFcount+nSpksTrial(cCh,cTrNr),:) = s.spkwave{cCh,cTrNr};
        cWFcount = cWFcount+nSpksTrial(cCh,cTrNr);
    end
end

%% compute principal components
[coefs,scores] = princomp(allWFs(:,iWF));

%% deal spike waveforms
cWFcount = 0;
for iCh = 1:length(s.currentchan)
    cCh = s.currentchan(iCh);
    for iTr = 1:length(s.currenttrials)
        cTrNr = s.currenttrials(iTr);
        s.spkwave{cCh,cTrNr} = scores(cWFcount+1:cWFcount+nSpksTrial(cCh,cTrNr),iPC);
        cWFcount = cWFcount+nSpksTrial(cCh,cTrNr);
    end
end

            

