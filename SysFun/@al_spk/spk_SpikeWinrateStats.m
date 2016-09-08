function R = spk_SpikeWinrateStats(s,ChanName,Par,tag,NormOption,MatchedTimeWin)

% Descriptive statistics and high-level use of spk_SpikeWinrate.m
%
% R = spk_SpikeWinrateGroups(s,ChanName,Par,tag,NormOption,NormFixedFactorLevel)
%
% s ............ @al_spk object
% ChanName ..... analog channel name
% Par .......... An array of structures with fields
%                win    : two column matrix with time boundaries
%                trials : cell array with trial indices
%                align  : event win is aligned to, 1 value or same size as trials
% tag .......... a string for the tag field, cells to add a tag for each
%                Epoch-Object (Par)
% NormOption ... if is set, it expects 2 Par struct. The first gets
%                normalised by the second.
%                'SUBSTRACTMEAN' substracts mean of the second
%                'SUBSTRACTTRIAL' substracts trialwise
% MatchedTimeWin ... match timewindows for normalisation 
%
% fields of results structure R
%   Tag      char
%   Name
%   Win      char
%   Trials   Epoch-Object
%   TrialNum
%   Rates    {iWin}{iGrp}
%   Mean     {iWin}(iGrp)
%   SDev     {iWin}(iGrp)
%   SErr     {iWin}(iGrp)
%   Fano     {iWin}(iGrp)
%   CoV      {iWin}(iGrp)

if nargin<6 || isempty(NormOption)
    NormOption = '';
end
if nargin<5 || isempty(tag)
    tag = '';
end

if iscell(Par)
    for iPar=1:size(Par,1)
        x(iPar).win = Par{iPar,1};
        x(iPar).trials = Par{iPar,2};
        if size(Par,2)>2
            x(iPar).align = Par{iPar,3};
        else
            x(iPar).align = [];
        end
    end
    Par = x;
end

%% check file properties
iCh = spk_findSpikeChan(s,ChanName);

%% check settings
nPar = length(Par);
if ~isempty(NormOption) && nPar~=2
    error('For any normalisation I need exactly TWO Par structures!');
elseif ~isempty(NormOption) && nPar==2
    % that's fine
elseif isempty(NormOption) && nPar==2
    error('I need normalisation parameter!');
elseif nPar>2
    error('Max 2 Par-structures!');
end

%% loop Epochs
for iPar = 1:nPar
    R(iPar).Tag = tag;
    R(iPar).Name = ChanName;
    R(iPar).Win = Par(iPar).win;
    R(iPar).Align = Par(iPar).align;
    R(iPar).Trials = Par(iPar).trials;
    R(iPar).TrialNum = cellfun('length',Par(iPar).trials);
    
    nGrp = numel(Par(iPar).trials);
    nLevel = size(Par(iPar).trials);
    nWin = size(Par(iPar).win,1);
    
    %% COMPUTE: spike rate
    for iWin = 1:nWin
        for iGrp = 1:nGrp
            
            if isempty(Par(iPar).trials{iGrp})
                R(iPar).Count.Counts{iWin}{iGrp} = [];
                R(iPar).Count.M{iWin}(iGrp) = NaN;
                R(iPar).Count.S{iWin}(iGrp) = NaN;
                R(iPar).Count.SE{iWin}(iGrp) = NaN;
                R(iPar).Count.Fano{iWin}(iGrp) = NaN;
                R(iPar).Count.CoV{iWin}(iGrp) = NaN;
                R(iPar).Rate.Rates{iWin}{iGrp} = [];
                R(iPar).Rate.M{iWin}(iGrp) = NaN;
                R(iPar).Rate.S{iWin}(iGrp) = NaN;
                R(iPar).Rate.SE{iWin}(iGrp) = NaN;
                R(iPar).Rate.Fano{iWin}(iGrp) = NaN;
                R(iPar).Rate.CoV{iWin}(iGrp) = NaN;
                
                continue;
            end
            
            % extract the data
            s = spk_set(s,'currenttrials',Par(iPar).trials{iGrp},'currentchan',iCh);
            
            if isfield(Par,'align') && ~isempty(Par(iPar).align)
                if ischar(Par(iPar).align) || length(Par(iPar).align)==1
                    cEv = spk_getEvents(s,Par(iPar).align);
                else
                    cEv = spk_getEvents(s,Par(iPar).align{iGrp});
                end
                cEv = round(cat(1,cEv{:}));
                cWin = [cEv+Par(iPar).win(iWin,1) cEv+Par(iPar).win(iWin,2)];
            else
                cWin = Par(iPar).win(iWin,:);
            end
            
            % get the trial rates
            [R(iPar).Rate.Rates{iWin}{iGrp},R(iPar).Count.Counts{iWin}{iGrp},dt] = spk_SpikeWinrate(s,cWin);
            R(iPar).Rate.Rates{iWin}{iGrp} = R(iPar).Rate.Rates{iWin}{iGrp}';
            R(iPar).Count.Counts{iWin}{iGrp} = R(iPar).Count.Counts{iWin}{iGrp}';
            
            st = GetStats(R(iPar).Count.Counts{iWin}{iGrp});
            R(iPar).Count.M{iWin}(iGrp) = st.M;
            R(iPar).Count.S{iWin}(iGrp) = st.S;
            R(iPar).Count.SE{iWin}(iGrp) = st.SE;
            R(iPar).Count.Fano{iWin}(iGrp) = st.Fano;
            R(iPar).Count.CoV{iWin}(iGrp) = st.CoV;
            
            st = GetStats(R(iPar).Rate.Rates{iWin}{iGrp});
            R(iPar).Rate.M{iWin}(iGrp) = st.M;
            R(iPar).Rate.S{iWin}(iGrp) = st.S;
            R(iPar).Rate.SE{iWin}(iGrp) = st.SE;
            R(iPar).Rate.Fano{iWin}(iGrp) = st.Fano;
            R(iPar).Rate.CoV{iWin}(iGrp) = st.CoV;
        end
        R(iPar).Count.Counts{iWin} = reshape(R(iPar).Count.Counts{iWin},nLevel);
        R(iPar).Count.M{iWin} = reshape(R(iPar).Count.M{iWin},nLevel);
        R(iPar).Count.S{iWin} = reshape(R(iPar).Count.S{iWin},nLevel);
        R(iPar).Count.SE{iWin} = reshape(R(iPar).Count.SE{iWin},nLevel);
        R(iPar).Count.Fano{iWin} = reshape(R(iPar).Count.Fano{iWin},nLevel);
        R(iPar).Count.CoV{iWin} = reshape(R(iPar).Count.CoV{iWin},nLevel);
        R(iPar).Rate.Rates{iWin} = reshape(R(iPar).Rate.Rates{iWin},nLevel);
        R(iPar).Rate.M{iWin} = reshape(R(iPar).Rate.M{iWin},nLevel);
        R(iPar).Rate.S{iWin} = reshape(R(iPar).Rate.S{iWin},nLevel);
        R(iPar).Rate.SE{iWin} = reshape(R(iPar).Rate.SE{iWin},nLevel);
        R(iPar).Rate.Fano{iWin} = reshape(R(iPar).Rate.Fano{iWin},nLevel);
        R(iPar).Rate.CoV{iWin} = reshape(R(iPar).Rate.CoV{iWin},nLevel);
    end
end

if nargin>=5 && ~isempty(NormOption)
    
    iPar = 1;
    iRef = 2;
    nGrp = numel(Par(iPar).trials);
    nWin = size(Par(iPar).win,1);
    
    for iGrp = 1:nGrp
        nTr = length(Par(iPar).trials{iGrp});
        if nTr==0;continue;end
        [isRefGrp,cRefTrialindex] = findRefGrp(Par(iPar).trials{iGrp},Par(iRef).trials);
        for iWin = 1:nWin
            if MatchedTimeWin
                iWinRef = iWin;
            else
                iWinRef = 1;
            end
            switch upper(NormOption)
                case 'SUBSTRACTMEAN'
                    isRefGrp = unique(isRefGrp);
                    R(iPar).Rate.Rates{iWin}{iGrp} = R(iPar).Rate.Rates{iWin}{iGrp} - R(iRef).Rate.M{iWinRef}(isRefGrp);
                    R(iPar).Count.Counts{iWin}{iGrp} = R(iPar).Count.Counts{iWin}{iGrp} - R(iRef).Count.M{iWinRef}(isRefGrp);
                case 'SUBSTRACTTRIAL'
                    for iTr = 1:nTr
                        R(iPar).Rate.Rates{iWin}{iGrp}(iTr) = R(iPar).Rate.Rates{iWin}{iGrp}(iTr) - R(iRef).Rate.Rates{iWinRef}{isRefGrp(iTr)}(cRefTrialindex(iTr));
                        R(iPar).Count.Counts{iWin}{iGrp}(iTr) = R(iPar).Count.Counts{iWin}{iGrp}(iTr) - R(iRef).Count.Counts{iWinRef}{isRefGrp(iTr)}(cRefTrialindex(iTr));
                    end
            end
            st = GetStats(R(iPar).Count.Counts{iWin}{iGrp});
            R(iPar).Count.M{iWin}(iGrp) = st.M;
            R(iPar).Count.S{iWin}(iGrp) = st.S;
            R(iPar).Count.SE{iWin}(iGrp) = st.SE;
            R(iPar).Count.Fano{iWin}(iGrp) = st.Fano;
            R(iPar).Count.CoV{iWin}(iGrp) = st.CoV;
            
            st = GetStats(R(iPar).Rate.Rates{iWin}{iGrp});
            R(iPar).Rate.M{iWin}(iGrp) = st.M;
            R(iPar).Rate.S{iWin}(iGrp) = st.S;
            R(iPar).Rate.SE{iWin}(iGrp) = st.SE;
            R(iPar).Rate.Fano{iWin}(iGrp) = st.Fano;
            R(iPar).Rate.CoV{iWin}(iGrp) = st.CoV;
        end
    end
end

function s = GetStats(x)
[s.M,s.S,s.SE] = agmean(x,[],1);
s.Fano = (s.S.^2)./s.M;
s.CoV = s.S./s.M;

function [cellindex,elementindex] = findRefGrp(a,b)
foundTr = false(size(a));
cellindex = zeros(size(a));
elementindex = zeros(size(a));
n = numel(b);
for i=1:n
    [foundTr,cindex] = ismember(a,b{i}(:));
    cellindex(foundTr) = i;
    if any(foundTr);elementindex(foundTr) = cindex;end
    if all(foundTr);break;end
end

