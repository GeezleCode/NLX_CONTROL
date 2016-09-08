function [TrialGrps,tLabel,LevelTerms] = spk_TrialGroups(s,varargin)

% Group trials according to a trialcode label
%
% INPUT is list of arguments
% TrialGrps = spk_TrialGrouping(s,Trialcodelabel_1,Trialcode_cells_1, ...)
% Trialcodelabel .... s.trialcodelabel (Factor)
% Trialcode_cells ... each cell contains groups of trialcodes of the given
%                     trialcodelabel
%
% INPUT is structure
% TrialGrps = spk_TrialGrouping(s,t)
% t.TrialcodeLabel ..... TrialcodeLabel 
% t.Trialcode .......... Trialcode
% t.LevelTerm .......... a term indicating a facor-level of a trialcode
% e.g. t.TrialcodeLabel={'CortexCondition'}
%           t.Trialcode={[0 1 2 3 4 5 6 7 8]}
%           t.LevelTerm={{'in' 'out' 'in' 'out' 'in' 'out' 'in' 'out' 'in'}}
% 
% TrialGrps is a cell array containing trial indices. The number of
% dimensions corresponds to the number of Trialcodelabel (Group-Factor).
% Dimension lengths (Group-Level) corresponds to number of cells given in
% Trialcode_cells
%

TrialGrps = {};
tLabel = {};
LevelTerms = {};
    
%% check input
n = length(varargin);
if n==1 && isstruct(varargin{1})
    [tLabel,tCode,LevelTerms] = fromStructInput(s,varargin{1});
elseif n==2 && iscell(varargin{1}) && iscell(varargin{2})
    tLabel = varargin{1};
    tCode = varargin{2};
elseif n>2 && rem(n,2) == 0
    tLabel = varargin(1:2:n-1);
    tCode = varargin(2:2:n);
else
    error('Input must be Label/Value pairs!');
end

%% get row index for s.trialcode
TrialCodeLabelNr = spk_findTrialcodelabel(s,tLabel);
isOKTrialcode = ~isnan(TrialCodeLabelNr);
if any(~isOKTrialcode)
    warning('Can''t find trialcodelabel >>%s<<',tLabel{~isOKTrialcode})
    tLabel(~isOKTrialcode) = [];
    tCode(~isOKTrialcode) = [];
    TrialCodeLabelNr(~isOKTrialcode) = [];
end
nLabel = length(tLabel);
nLevel = cellfun('length',tCode);

%% allocate arrays
if numel(nLevel)==1
    TrialGrps = cell(1,nLevel);
else
    TrialGrps = cell(nLevel);
end
IsTrial = false(nLabel,size(s.trialcode,2));
cLevel = cell(1,nLabel);

%% loop through all the groups
for i = 1:prod(nLevel)
    [cLevel{:}] = ind2sub(nLevel,i);
    IsTrial(:) = false;
    for j = 1:nLabel
        IsTrial(j,:) = ismember(s.trialcode(TrialCodeLabelNr(j),:),tCode{j}{cLevel{j}});
    end
    TrialGrps{i} = find(all(IsTrial,1));
end

%%#################### SUBFUNCTIONS #############################
function [tLabel,tCode,LevelTerms] = fromStructInput(s,x)
tLabel = x.TrialcodeLabel;
n = length(x.TrialcodeLabel);
tCode = cell(size(x.TrialcodeLabel));
LevelTerms = cell(size(x.TrialcodeLabel));
for i = 1:n
    
    if isempty(x.LevelTerm{i})
        % each trialcode defines a level
        iTrialcodeLabel = spk_findTrialcodelabel(s,x.TrialcodeLabel{i});
        cCodes = unique(s.trialcode(iTrialcodeLabel,:));
        cCodes(isnan(cCodes)) = [];
        tCode{i} = num2cell(cCodes);
        LevelTerms{i} = cCodes;
    else
        % level are defined by x.LevelTerm and x.Trialcode
        [LevelTerms{i},dummy,cFacLevelNrs] = unique(x.LevelTerm{i});
        cLevNum = length(LevelTerms{i});
        for iLev = 1:cLevNum
            tCode{i}{iLev} = x.Trialcode{i}(cFacLevelNrs==iLev);
        end
    end
end
