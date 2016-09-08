function E = spk_EpochGroupConditions(s,Cnd,varargin)

% set time window, regroup conditions and set alignment events
% E = spk_Epoch(SPK,Cnd,varargin)
%
% Cnd ... structure with fields
%         Factor: {'','',...} n factor names
%         Level: [N Factor X N Condition] matrix encoding conditon level
%         for every factor
% varargin ... Field/value pairs of the structure E
%              Name: [char] name of current epoch
%              CndTrialCodeLabel: [char] Trialcodelabel that encodes condition
%              PlotWin:       [1x2] time window for plotting
%              AnalyseWin:    [nx2] epoch window for analysing
%              GroupFactor:   {char} factor names that will be grouped
%                             separately
%              GroupLevelCode: {[N Level], ...} level code to go with
%                              GroupFactor
%              GroupLevelLabel: {[]} labels to go with GroupLevelCode
%              AlignmentFactor: Factor that determines alignment
%              AlignmentLevel: [1 X N events] factor levels to go with AlignmentEvents
%              AlignmentEvents: {''} to go with AlignmentLevel
%              GroupCnd: resulting condition grouping
%              GroupAlignEvent: alignment events to go with GroupCnd

%% default settings
E.Name = 'Dim';
E.CndTrialCodeLabel = 'CortexCondition';
E.PlotWin = [-500 250];
E.AnalyseWin = [-500 250];
E.GroupFactor = {'Attention','Direction'};
E.GroupLevelLabel = {{'out' 'in'},{'nPD' 'PD'}};
E.GroupLevelCode = {[0 1],[0 1]};
E.AlignmentFactor = 'Attention';
E.AlignmentLevel = [1 0];
E.AlignmentEvents = {'NLX_TESTDIMMED' 'NLX_DISTDIMMED'};
E.GroupCnd = [];
E.GroupAlignEvent = {};

%% update inputs
E = StructUpdate(E,varargin{:});

%% regroup conditions
E.GroupCnd = group_Conditions(Cnd.Level,Cnd.Factor,E.GroupFactor,E.GroupLevelCode);
nFac = ndims(E.GroupCnd);
nFacLevel = size(E.GroupCnd);

%% define aligning event
E.GroupAlignEvent = cell(size(E.GroupCnd));
iFac = find(strcmpi(E.AlignmentFactor,E.GroupFactor));
nAlEv = length(E.AlignmentEvents);
if nAlEv==1
    E.GroupAlignEvent(:) = E.AlignmentEvents;
else
    E.GroupAlignEvent = permute(E.GroupAlignEvent,circshift([1:nFac],[1 -(iFac-1)]));% permute to make alignment defining factor the first dimension
    for i=1:length(E.AlignmentEvents)
        iLevel = E.GroupLevelCode{iFac}==E.AlignmentLevel(i);
        E.GroupAlignEvent(iLevel,:) = E.AlignmentEvents(i);
    end
    E.GroupAlignEvent = permute(E.GroupAlignEvent,circshift([1:nFac],[1 (iFac-1)]));% permute back
end

%% get trials for the grouped conditions 
E.GroupTrialIndex = cell(nFacLevel);
for iFactorLevel = 1:numel(E.GroupCnd)
    
    % get the trials
    E.GroupTrialIndex{iFactorLevel} = spk_findtrials_AND(s,E.CndTrialCodeLabel,E.GroupCnd{iFactorLevel});
    
    % check for single align event
    if ~isempty(E.GroupTrialIndex{iFactorLevel})
        s = spk_set(s,'currenttrials',E.GroupTrialIndex{iFactorLevel});
        cEv = spk_getEvents(s,E.GroupAlignEvent{iFactorLevel});
        if any(cellfun('length',cEv)~=1)
            warning('Discard trial(s) due to missing/multiple align event!');
            E.GroupTrialIndex{iFactorLevel} = E.GroupTrialIndex{iFactorLevel}(cellfun('length',cEv)==1);
        end
    end
end



function [cGrpCnd] = group_Conditions(CndLevelCode,CndFactorLabel,AnalyseFactors,AnalyseLevelCode)
% re-group conditions (e.g. for averaging across conditions etc.)  
nFactor = length(AnalyseFactors);
nFactorLevel = cellfun('length',AnalyseLevelCode);

if nFactor==0
    cGrpCnd = {1:size(CndLevelCode,2)};
else
    if length(nFactorLevel)==1;nFactorLevel = [nFactorLevel 1];end
    nGroups = prod(nFactorLevel);
    nCnd = size(CndLevelCode,2);
    cGrpCnd = cell(nFactorLevel);
    cLevelNr = cell(1,nFactor);
    for iGrp = 1:nGroups
        [cLevelNr{:}] = ind2sub(nFactorLevel,iGrp);
        cFacCndInd = false(nFactor,nCnd);
        for iFac = 1:nFactor
            cFacNr = strmatch(AnalyseFactors{iFac},CndFactorLabel);
            cFacCndInd(iFac,:) = CndLevelCode(cFacNr,:) == AnalyseLevelCode{iFac}(cLevelNr{iFac});
        end
        cGrpCnd{iGrp} = find(all(cFacCndInd,1));
    end
end

