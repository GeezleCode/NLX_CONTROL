function nTrials = spk_TrialNum(s,CheckDataFlag)

% returns and check for number of trials in @al_spk object
% function nTrials = spk_TrialNum(s,CheckDataFlag)

if nargin<2
    CheckDataFlag = false;
end
nTrials = size(s.trialcode,2);
if ~CheckDataFlag;return;end

%% check trial numbers
nTrEv = size(s.events,2);
[nChSpk,nTrSpk] = size(s.spk);
[nChSpkWv,nTrSpkWv] = size(s.spkwave);
nTrAlgn = size(s.align,2);
nTrStim = size(s.stimulus,2);
nTrAna = cellfun('size',s.analog,1);
nChAna = length(s.analog);

nTr = [nTrEv nTrSpk nTrAlgn nTrStim nTrAna(:)'];
nTr = nTr(~isnan(nTr)&nTr>0);
if length(unique(nTr))>1
    fprintf(1,'number of trials\n');
    fprintf(1,'trialcode: %1.0f\n',nTrials);
    fprintf(1,'events:    %1.0f\n',nTrEv);
    fprintf(1,'spikes:    %1.0f\n',nTrSpk);
    fprintf(1,'spikewave: %1.0f\n',nTrSpkWv);
    fprintf(1,'align:     %1.0f\n',nTrAlgn);
    fprintf(1,'stimulus:  %1.0f\n',nTrStim);
    fprintf(1,'analog:    ');
    fprintf(1,'%1.0f ',nTrAna(:));
    fprintf(1,'\n');
    error('inconsistency in number of trials !!!');
end

