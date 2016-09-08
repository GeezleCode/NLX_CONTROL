function x = spk_ChronuxSpikeField(s,TimeWin,Event,ChanPairs,FunctionName,params)

% apply chronux function mtspectrumpt.m
%
% x = spk_ChronuxSpikeSpectrum(s,tWin,Ev,params)
%
% TimeWin,Event ... time window and reference event, e.g. [200 500] 'NLX_STIM_ON' 
% ChanPairs ....... channel names/index, [:,1] analog [:,2] spike
% FunctionName .... 'coherencycpt','cohgramcpt','sta','staogram'
% params ... chronux input, see coherencycpt
%


%%
if nargin<6
    params = {};
end

%% chronux parameter
defparams.tapers = [3 5];
defparams.pad = 1;
defparams.Fs = s.spkwavefreq;
defparams.fpass = [0 150];
defparams.trialave = 0;
defparams.err = 0;
defparams.fscorr = [];
defparams.t = [];
params = StructUpdate(defparams,params);

%% trials
[TrGrp,s] = spk_CheckCurrentTrials(s,true);
if isnumeric(TrGrp)
    TrGrp = {TrGrp};
end
nTrGrps = numel(TrGrp);

%% channels
if isempty(ChanPairs)
    ChanNr(:,1) = s.currentanalog(:);
    ChanNr(:,2) = s.currentchan(:);
elseif ~isempty(ChanPairs) && isnumeric(ChanPairs)
    ChanNr = ChanPairs;
elseif ~isempty(ChanPairs) && iscell(ChanPairs)
    ChanNr(:,1) = spk_findAnalog(s,ChanPairs(:,1));
    ChanNr(:,2) = spk_findSpikeChan(s,ChanPairs(:,2));
end
nCh = size(ChanNr,1);

%% loop thru groups and channels
switch FunctionName
    case 'coherencycpt'
        for iCh = 1:nCh
            for iTrGrp = 1:nTrGrps
                s = spk_set(s, ...
                    'currenttrials',TrGrp{iTrGrp}, ...
                    'currentchan',ChanNr(iCh,2), ...
                    'currentanalog',ChanNr(iCh,1));
                TimeWinAlignFlag = true;
                data1 = spk_ChronuxGetLFP(s,TimeWin,Event,TimeWinAlignFlag);
                data2 = spk_ChronuxGetSpike(s,TimeWin,Event,TimeWinAlignFlag);
                params.Fs = s.analogfreq(ChanNr(iCh,1));
                
                if isempty(params.err) || params.err(1)==0
                    [x(iCh).C{iTrGrp},x(iCh).phi{iTrGrp},x(iCh).S12{iTrGrp},x(iCh).S1{iTrGrp},x(iCh).S2{iTrGrp},x(iCh).f{iTrGrp}] = coherencycpt(data1,data2,params,params.fscorr,params.t);
                    x(iCh).zerosp{iTrGrp} = [];
                    x(iCh).confC{iTrGrp} = [];
                    x(iCh).phistd{iTrGrp} = [];
                    x(iCh).Cerr{iTrGrp} = [];
                elseif params.err(1)==1
                    [x(iCh).C{iTrGrp},x(iCh).phi{iTrGrp},x(iCh).S12{iTrGrp},x(iCh).S1{iTrGrp},x(iCh).S2{iTrGrp},x(iCh).f{iTrGrp},x(iCh).zerosp{iTrGrp},x(iCh).confC{iTrGrp},x(iCh).phistd{iTrGrp}] = coherencycpt(data1,data2,params,params.fscorr,params.t);
                    x(iCh).Cerr{iTrGrp} = [];
                elseif params.err(1)==2
                    [x(iCh).C{iTrGrp},x(iCh).phi{iTrGrp},x(iCh).S12{iTrGrp},x(iCh).S1{iTrGrp},x(iCh).S2{iTrGrp},x(iCh).f{iTrGrp},x(iCh).zerosp{iTrGrp},x(iCh).confC{iTrGrp},x(iCh).phistd{iTrGrp},x(iCh).Cerr{iTrGrp}] = coherencycpt(data1,data2,params,params.fscorr,params.t);
                end
            end
        end
        x(iCh).C = reshape(x(iCh).C,size(TrGrp));
        x(iCh).phi = reshape(x(iCh).phi,size(TrGrp));
        x(iCh).S12 = reshape(x(iCh).S12,size(TrGrp));
        x(iCh).S1 = reshape(x(iCh).S1,size(TrGrp));
        x(iCh).S2 = reshape(x(iCh).S2,size(TrGrp));
        x(iCh).f = reshape(x(iCh).f,size(TrGrp));
        x(iCh).zerosp = reshape(x(iCh).zerosp,size(TrGrp));
        x(iCh).confC = reshape(x(iCh).confC,size(TrGrp));
        x(iCh).phistd = reshape(x(iCh).phistd,size(TrGrp));
        x(iCh).Cerr = reshape(x(iCh).Cerr,size(TrGrp));
        
    case 'cohgramcpt'
         [C,phi,S12,S1,S2,t,f,zerosp,confC,phistd,Cerr]=cohgramcpt(data1,data2,movingwin,params,fscorr)
    case 'sta'
        [s,t,E] = sta(data_spk,data_lfp,smp,plt,w,T,D,err);
    case 'staogram'
        [S,tau,tc] = staogram(data_spk,data_lfp,smp,plt,Tc,Tinc,Tw,w,D);
       
    otherwise
end



