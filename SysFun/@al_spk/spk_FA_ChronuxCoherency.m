function R = spk_FA_ChronuxCoherency(s,ChanName,Set,Pdm)

% compute coherency
% R = spk_FA_ChronuxCoherency(s,ChanName,Set,Pdm)
%
% s .......... @al_spk object
% ChanName ... analog channel name
%
% Set ........ settings for computations
%              Set.SpecBand - [loF hiF]
%              Set.ChronuxPar.tapers - [TW K] Bandwidth product and number of tapers
%              Set.ChronuxPar.pad - scalar integer
%              Set.ChronuxPar.Fs - sample frequency;
%              Set.ChronuxPar.fpass - pass band;
%              Set.ChronuxPar.err - scalar;
%              Set.ChronuxPar.trialave - scalar
%
% Pdm ........ condition grouping structure
%              Pdm.Cnd.Factor - {1xnFac} char with name of factor
%              Pdm.Cnd.Level - {1xnFac} arrays with parameter of cateories
%              Pdm.Win(iWin).Name - [char] name of this window
%              Pdm.Win(iWin).PlotWin - [1x2] time window for plotting
%              Pdm.Win(iWin).AnalyseWin - [1x2] time window for analyses
%              Here, factors and levels are different from Pdm.Cnd because of
%              regrouping of conditions
%              Pdm.Win(iWin).GroupFactor - {1xnFac} char with name of factor  
%              Pdm.Win(iWin).GroupLevel - {1xnFac} arrays with parameter of cateories
%              Pdm.Win(iWin).GroupCnd - {nLevel1 x nLevel2 x nLevel3 ...} condition numbers
%              Pdm.Win(iWin).GroupAlignEvent - {nLevel1 x nLevel2 x nLevel3 ...} event strings
%              Pdm.Win(iWin).GroupTrialIndex - {nLevel1 x nLevel2 x nLevel3 ...} trialindices

R.Set = Set;
R.Pdm = Pdm;
R.ChanPair = ChanName;

%% get channel index
SpikeChanNr = spk_findSpikeChan(s,ChanName);
AnalogChanNr = spk_findAnalog(s,ChanName);
    
%% check channel pair
if ~any(isnan(SpikeChanNr)) && all(isnan(AnalogChanNr))
    R.CohMode = 'Spike-Spike';
    s = spk_SpikeTimePrecision(s,-3,true);
    Set.ChronuxPar.Fs = 1000;
elseif ~any(isnan(AnalogChanNr)) && all(isnan(SpikeChanNr))
    R.CohMode = 'Field-Field';
    Fs = spk_get(s,'analogfreq');
    if Fs(AnalogChanNr(1))~=Fs(AnalogChanNr(2))
        error('Different Fs of channel pair!');
    end
    Set.ChronuxPar.Fs = Fs(AnalogChanNr(1)); 
elseif sum(isnan(AnalogChanNr))==1 && sum(isnan(SpikeChanNr))==1
    R.CohMode = 'Spike-Field';
    SpikeChanNr(isnan(SpikeChanNr)) = [];
    AnalogChanNr(isnan(AnalogChanNr)) = [];
    Fs = spk_get(s,'analogfreq');
    Set.ChronuxPar.Fs = Fs(AnalogChanNr); 
else
    error('failed to determine signal-pair ...');
end
    
%% check settings
nWin = length(Pdm.Win);

%% COMPUTE: spectrum
for iWin = 1:nWin
    nGrp = numel(Pdm.Win(iWin).GroupTrialIndex);
    nLevel = size(Pdm.Win(iWin).GroupTrialIndex);
    for iGrp = 1:nGrp
        
        nTr = length(Pdm.Win(iWin).GroupTrialIndex{iGrp});
        fprintf(1,'spk_FA_ChronuxCoherency: Win ''%s'' Grp %1.0f(%1.0f ) - %1.0f trials\n',Pdm.Win(iWin).Name,iGrp,nGrp,nTr);
        if isempty(Pdm.Win(iWin).GroupTrialIndex{iGrp});continue;end

        % extract the data
        s = spk_set(s,'currenttrials',Pdm.Win(iWin).GroupTrialIndex{iGrp});
        cEv = spk_getEvents(s,Pdm.Win(iWin).GroupAlignEvent{iGrp});
        cEv = round(cat(1,cEv{:}));
        
        switch R.CohMode
            case 'Spike-Spike'
                    s = spk_set(s,'currentchan',SpikeChanNr);
                    spks = spk_ChronuxGetSpike(s,Pdm.Win(iWin).AnalyseWin,cEv,true);
                    [R.Coh{iWin}{iGrp},R.phi{iWin}{iGrp},R.S12{iWin}{iGrp},R.S1{iWin}{iGrp},R.S2{iWin}{iGrp},R.f{iWin}]=coherencypt(spks(1,:),spks(2,:),Set.ChronuxPar,0); 
            case 'Field-Field'
                    s = spk_set(s,'currentanalog',AnalogChanNr);
                    [dlfp,tlfp] = spk_ChronuxGetLFP(s,Pdm.Win(iWin).AnalyseWin,cEv,true);
                    [R.Coh{iWin}{iGrp},R.phi{iWin}{iGrp},R.S12{iWin}{iGrp},R.S1{iWin}{iGrp},R.S2{iWin}{iGrp},R.f{iWin}]=coherencyc(dlfp{1},dlfp{2},Set.ChronuxPar);
            case 'Spike-Field'
                    s = spk_set(s,'currentanalog',AnalogChanNr,'currentchan',SpikeChanNr);
                    [dlfp,tlfp] = spk_ChronuxGetLFP(s,Pdm.Win(iWin).AnalyseWin,cEv,true);
                    spks = spk_ChronuxGetSpike(s,Pdm.Win(iWin).AnalyseWin,cEv,true);
                    [R.Coh{iWin}{iGrp},R.phi{iWin}{iGrp},R.S12{iWin}{iGrp},R.S1{iWin}{iGrp},R.S2{iWin}{iGrp},R.f{iWin}]=coherencycpt(dlfp,spks,Set.ChronuxPar,0,tlfp);
        end
    end
    R.Coh{iWin} = reshape(R.Coh{iWin},nLevel);
    R.phi{iWin} = reshape(R.phi{iWin},nLevel);
    R.S12{iWin} = reshape(R.S12{iWin},nLevel);
    R.S1{iWin} = reshape(R.S1{iWin},nLevel);
    R.S2{iWin} = reshape(R.S2{iWin},nLevel);
end

