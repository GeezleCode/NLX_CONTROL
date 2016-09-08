function E = spk_EpochAddDrugGrouping(s,E,DrugMode)

% adds grouping to the Epoch structure E according to a trialcode (s.trialcode)

nEp = length(E);
        
switch DrugMode
    case 'LO_HI_REC'
        TrialCodeLabel = 'drugstate';
        TrialCode = {[0] [1] [2]};
        LevelLabel = {'LO' 'HI' 'REC'};
        FactorLabel = 'Drug';
    case 'LO_HI_WASH'
        TrialCodeLabel = 'drugstate';
        TrialCode = {[2] [1] [3]};
        LevelLabel = {'LO' 'HI' 'WASH'};
        FactorLabel = 'Drug';
    case 'LO_HI'
        TrialCodeLabel = 'drugstate';
        TrialCode = {[0] [1]};
        LevelLabel = {'LO' 'HI'};
        FactorLabel = 'Drug';
    case 'REC_HI'
        TrialCodeLabel = 'drugstate';
        TrialCode = {[2] [1]};
        LevelLabel = {'LO' 'HI'};
        FactorLabel = 'Drug';
    case 'WASH_HI'
        TrialCodeLabel = 'drugstate';
        TrialCode = {[3] [1]};
        LevelLabel = {'LO' 'HI'};
        FactorLabel = 'Drug';
    case 'LO/REC/WASH_HI'
        TrialCodeLabel = 'drugstate';
        TrialCode = {[0 2 3] [1]};
        LevelLabel = {'LO' 'HI'};
        FactorLabel = 'Drug';
    case 'Files'
        TrialCodeLabel = 'cat_index';
        FileCodes = spk_getTrialcode(s,TrialCodeLabel);
        DrugCodes = spk_getTrialcode(s,'drugstate');
        
        TrialCodes = unique(FileCodes);
        TrialCode = num2cell(TrialCodes);
        
        for iTC = 1:length(TrialCodes)
            cDC = unique(DrugCodes(FileCodes==TrialCodes(iTC)));
            if length(cDC)>1
                LevelLabel(iTC) = {sprintf('%1.0f',TrialCodes(iTC))};
            elseif cDC==1
                LevelLabel(iTC) = {sprintf('%1.0f.LO',TrialCodes(iTC))};
            elseif cDC==2
                LevelLabel(iTC) = {sprintf('%1.0f.HI',TrialCodes(iTC))};
            elseif cDC==3
                LevelLabel(iTC) = {sprintf('%1.0f.REC',TrialCodes(iTC))};
            end
        end
        FactorLabel = 'FileNr';
end
nDrugGrp = length(TrialCode);

%% add grouping
for iEp = 1:nEp
    nNewLevel = length(LevelLabel);

    %% reorder group information
    E(iEp).GroupFactor = [{FactorLabel} E(iEp).GroupFactor];
    E(iEp).GroupLevelLabel = [{LevelLabel} E(iEp).GroupLevelLabel];
    E(iEp).GroupLevelCode = [{ones(1,nNewLevel).*NaN} E(iEp).GroupLevelCode];
    
    nFac = ndims(E(iEp).GroupCnd);
    
    if numel(E(iEp).GroupCnd)==1
        %
        E(iEp).GroupCnd = repmat(E(iEp).GroupCnd,[nDrugGrp 1]);
        E(iEp).GroupAlignEvent = repmat(E(iEp).GroupAlignEvent,[nDrugGrp 1]);
    else
        
        E(iEp).GroupCnd = permute(E(iEp).GroupCnd,[nFac+1,1:nFac]);
        E(iEp).GroupCnd = repmat(E(iEp).GroupCnd,[nDrugGrp ones(1,nFac)]);
        E(iEp).GroupAlignEvent = permute(E(iEp).GroupAlignEvent,[nFac+1,1:nFac]);
        E(iEp).GroupAlignEvent = repmat(E(iEp).GroupAlignEvent,[nDrugGrp ones(1,nFac)]);
    end
    
    %% add trials
    OldGroupTrialIndex = E(iEp).GroupTrialIndex;
    nOldLevel = size(OldGroupTrialIndex);
    NewGroupTrialIndex = cell(1,nNewLevel);
    for i = 1:nNewLevel
        tempOldGroupTrialIndex = OldGroupTrialIndex;
        cTr = spk_findtrials_AND(s,TrialCodeLabel,TrialCode{i});
        for iFactorLevel = 1:numel(OldGroupTrialIndex)
            % get the trials
            tempOldGroupTrialIndex{iFactorLevel} = intersect(tempOldGroupTrialIndex{iFactorLevel},cTr);
        end
        NewGroupTrialIndex{i} = shiftdim(tempOldGroupTrialIndex,-1);
    end
    E(iEp).GroupTrialIndex = cat(1,NewGroupTrialIndex{:});

end
