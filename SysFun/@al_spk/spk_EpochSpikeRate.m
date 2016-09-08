function R = spk_EpochSpikeRate(s,ChanName,Ep,AnovanProp,MultCompProp)

% compute spike-rates using windows of the Epoch object
% R = spk_EpochSpikeRate(s,ChanName,Ep)
%
% s .......... @al_spk object
% ChanName ... analog channel name
% Ep ......... Epoch object
% AnovanProp ..... Input for cell_anovan function. Leave empty [] to skip
% MultCompProp ... Input for MultCompPlus function. Leave empty [] to skip
%
% fields of results structure R
%   Name
%   Ep
%   Rate
%   RateM
%   RateS
%   RateSE
 


%% check file properties
iCh = spk_findSpikeChan(s,ChanName);

%% check settings
nEp = length(Ep);

%% loop Epochs
for iEp = 1:nEp
    R(iEp).Name = ChanName;
    R(iEp).Ep = Ep(iEp);
    
    nGrp = numel(Ep(iEp).GroupTrialIndex);
    nLevel = size(Ep(iEp).GroupTrialIndex);
    nWin = size(Ep(iEp).AnalyseWin,1);
    
    %% COMPUTE: spike rate
    for iWin = 1:nWin
        for iGrp = 1:nGrp
            
            nTr = length(Ep(iEp).GroupTrialIndex{iGrp});
            %         fprintf(1,'spk_FA_SpikeRate: Win ''%s'' Grp %1.0f(%1.0f ) - %1.0f trials\n',Ep(iEp).Name,iGrp,nGrp,nTr);
            if isempty(Ep(iEp).GroupTrialIndex{iGrp})
                R(iEp).Rate{iWin}{iGrp} = [];
                R(iEp).RateM{iWin}(iGrp) = NaN;
                R(iEp).RateS{iWin}(iGrp) = NaN;
                R(iEp).RateSE{iWin}(iGrp) = NaN;
                continue;
            end
            
            % extract the data
            s = spk_set(s,'currenttrials',Ep(iEp).GroupTrialIndex{iGrp},'currentchan',iCh);
            cEv = spk_getEvents(s,Ep(iEp).GroupAlignEvent{iGrp});
            cEv = round(cat(1,cEv{:}));
            [R(iEp).Rate{iWin}{iGrp},n,dt] = spk_SpikeWinrate(s,[cEv+Ep(iEp).AnalyseWin(iWin,1) cEv+Ep(iEp).AnalyseWin(iWin,2)]);
            R(iEp).Rate{iWin}{iGrp} = R(iEp).Rate{iWin}{iGrp}';
            [R(iEp).RateM{iWin}(iGrp),R(iEp).RateS{iWin}(iGrp),R(iEp).RateSE{iWin}(iGrp)] = agmean(R(iEp).Rate{iWin}{iGrp},[],1);
        end
        R(iEp).Rate{iWin} = reshape(R(iEp).Rate{iWin},nLevel);
        R(iEp).RateM{iWin} = reshape(R(iEp).RateM{iWin},nLevel);
        R(iEp).RateS{iWin} = reshape(R(iEp).RateS{iWin},nLevel);
        R(iEp).RateSE{iWin} = reshape(R(iEp).RateSE{iWin},nLevel);
    end
    
    %% COMPUTE: Anova
    R(iEp).ANOVA = [];
    if iscell(AnovanProp)
        for iWin = 1:nWin
            X = create(DataFrame,'cells',R(iEp).Rate{iWin},'factor',Ep.GroupFactor,'level',Ep.GroupLevelLabel);
            [X,Removed] = removeEmptyLevel(X);% remove empty levels
            if isempty(X,'ALL');continue;end
            X = squeeze(X,true);% remove factors with one level
            [nFac,nLev] = size(X);
            if isempty(X,'ALL') || (nFac==1 && all(nLev==1));continue;end
            
            %% ANOVA
            ANOVAres = anovan(X,AnovanProp{:});
            R(iEp).ANOVA(iWin).FacNames = X.factor;
            R(iEp).ANOVA(iWin).FacLevel = X.level;
            R(iEp).ANOVA(iWin).table = ANOVAres.table;
            R(iEp).ANOVA(iWin).p = ANOVAres.p;
            
            %% Multiple comparisons
            if iscell(MultCompProp)
                DimArgNr = strcmpi('dimension',MultCompProp(1:2:end));
                if ~isempty(DimArgNr)
                    % multiple comparison across all dimensions
                    MultCompProp{find(DimArgNr)*2} = 1:size(X);
                else
                    MultCompProp{end,end+1} = {'dimension',[1:size(X)]};
                end
                [R(iEp).ANOVA(iWin).MCH,R(iEp).ANOVA(iWin).CompNr,R(iEp).ANOVA(iWin).CompLevel] = MultCompPlus(ANOVAres.stats,MultCompProp);
            end
            
        end
    end
    
end


