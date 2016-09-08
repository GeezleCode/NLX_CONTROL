function x = spk_ChronuxSpikeSpectrum(s,tWin,Ev,params,fscorr,t)

% apply chronux function mtspectrumpt.m
% x = spk_ChronuxSpikeSpectrum(s,tWin,Ev,params)

%%
if nargin<6
    t = [];
    if nargin<5
        fscorr = [];
        if nargin<4
            params = {};
    end;end;end

%% chronux parameter
defparams.tapers = [3 5];
defparams.pad = 1;
defparams.Fs = s.spkwavefreq;
defparams.fpass = [0 200];
defparams.trialave = 0;
defparams.err = 0;
params = StructUpdate(defparams,params);

%% trials
[TrGrp,s] = spk_CheckCurrentTrials(s,true);
if isnumeric(TrGrp)
    TrGrp = {TrGrp};
end
nTrGrps = numel(TrGrp);

%% channels
[ChanNr,s] = spk_CheckCurrentChannels(s,true);
nCh = length(ChanNr);

%% loop thru groups and channels
for iCh = 1:nCh
    for iTrGrp = 1:nTrGrps
        
        s = spk_set(s, ...
            'currenttrials',TrGrp{iTrGrp}, ...
            'currentchan',ChanNr(iCh));
        
        %-----------------------------------------------------
        % apply chronux functions
        TimeWinAlignFlag = true;
        data = spk_ChronuxGetSpike(s,tWin,Ev,TimeWinAlignFlag);
        params.Fs = 32000;% data is in sec
                
        if isempty(params.err) || params.err==0
            [x(iCh).S{iTrGrp},x(iCh).f{iTrGrp},R] = mtspectrumpt(data,params,fscorr,t);
        else
            [x(iCh).S{iTrGrp},x(iCh).f{iTrGrp},R,Serr] = mtspectrumpt(data,params,fscorr,t);
        end
        %-----------------------------------------------------
    end
end

x(iCh).S = reshape(x(iCh).S,size(TrGrp));
x(iCh).f = reshape(x(iCh).f,size(TrGrp));


