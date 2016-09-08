function nlx_control_trialstats(t,p,varargin)

% displays trial numbers in each condition

global SPK

SPK = spk_set(SPK,'currenttrials',[]);

%% create figure
TrialstatsFigHandle = findobj('type','figure','tag','nlx_control_trialstats');
% plot axes if there no axes in the main figure
if isempty(TrialstatsFigHandle)
    TrialstatsFigHandle = figure( ...
        'tag','nlx_control_trialstats', ...
        'color','k', ...
        'numbertitle','off', ...
        'name','nlx_control_trialstats', ...
        'menubar','none', ...
        'units','normalized','position',[0.67 0.7 0.33 0.1]);
    
    axes( ...
        'parent',TrialstatsFigHandle, ...
        'tag','nlx_control_trialstats table', ...
        'color','k', ...
        'units','normalized','position',[0.2 0.05 .78 .9]);
end

%% extract trial properties
TrialCodeLabel = {'CortexBlock';'CortexCondition';'StimulusCode'};
TrialCodes = [];
for i = 1:length(TrialCodeLabel)
    TrialCodes = cat(1,TrialCodes,spk_getTrialcode(SPK,TrialCodeLabel{i}));
end
NaNTrialCodes = all(isnan(TrialCodes),2);
TrialCodeLabel(NaNTrialCodes) = [];
TrialCodes(NaNTrialCodes,:) = [];
        
[numTrialCodes,numTrials] = size(TrialCodes);

if numTrials==0
    return;
end

%% compute
[TrialUniques,dummy,TrialUniqueIndex] = unique(TrialCodes','rows');
TrialUniques = TrialUniques';
TrialUniqueIndex = TrialUniqueIndex';
numTrialUniques = size(TrialUniques,2);
TrialUniquesSum = zeros(1,numTrialUniques);
for i = 1:numTrialUniques
    TrialUniquesSum(1,i) = sum(TrialUniqueIndex==i);
end

%% plot figures
STATSTABLE = [[TrialCodeLabel;{'#'}] [num2cell(TrialUniques);num2cell(TrialUniquesSum)]];
STATSTABLE = cat(1,cell(1,numTrialUniques+1),STATSTABLE);

axes(findobj('parent',TrialstatsFigHandle,'tag','nlx_control_trialstats table'));
cla;
[th,hh,sh,ch] = cell2table(gca,STATSTABLE,'IN');
set(th,'color','w');
set(hh,'color','w');
set(sh,'color','w','horizontalalignment','right');