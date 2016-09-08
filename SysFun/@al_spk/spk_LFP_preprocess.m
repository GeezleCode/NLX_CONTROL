function S = spk_LFP_preprocess(S,AnalogChan,LFPFilter,RemoveLine,RemoveSaturated)

if nargin<6
    RemoveSaturated = 0;
    if nargin<5
        RemoveLine = 0;
        if nargin<4
            LFPFilter = []
        end;end;end

if iscell(AnalogChan)
    nChan = length(AnalogChan);
    ChanIndex = spk_findanalog(S,AnalogChan);
elseif ischar(AnalogChan)
    nChan = 1;
    ChanIndex = spk_findanalog(S,AnalogChan);
elseif isnumeric(AnalogChan)
    nChan = length(AnalogChan);
    ChanIndex = AnalogChan;
end

for iA = 1:nChan
    S = spk_set(S,'currenttrials',[],'currentanalog',ChanIndex(iA));
    
    % ----------------------------------------
    % remove saturated trials
    % ----------------------------------------
    if RemoveSaturated==1
        S = spk_AnalogSaturation(S,[CSCMaxValue*(-1) CSCMaxValue],[],1);
    end

    % ----------------------------------------
    % remove 50Hz----------------
    % ----------------------------------------
    if RemoveLine==1
        % S = spk_analogFiltFilt(S,'butter',{3,[49.9 50.1],'stop'});
        S = spk_AnalogRemoveSine(S,50);
    end
    
    % ----------------------------------------
    % filter data
    % ----------------------------------------
    if ~isempty(LFPFilter) & ~isnan(LFPFilter(2));S = spk_analogFiltFilt(S,'butter',{LFPFilter(1),LFPFilter(2),'high'});end
    if ~isempty(LFPFilter) & ~isnan(LFPFilter(3));S = spk_analogFiltFilt(S,'butter',{LFPFilter(1),LFPFilter(3),'low'});end
        
end
