function R = spk_AnalogSpectrogramRead(s,C,CropWin,MargSpecWin,MargSpecOpt)

% read from a structure created by spk_AnalogSpectrogram.m
% 1. Crops spectrograms to window
% 2. Calcs marginal spectrums for a set of windows

nChC = length(C);

%% get trial indices, enable cells of groups of trials
if isnumeric(s.currenttrials)
    s.currenttrials = {s.currenttrials};
end
nLevel = size(idxTr);
nFac = find(nLevel>1,1,'last');
nGrp = numel(idxTr);

%% align spk object and spec results structure
[iAlignEvent,AlignEvent] = spk_getAlignEvent(s);
iCAlignEvent = spk_findEventlabel(s,C.AlignEvent);


%% loop
for iGrp = 1:Grp
    nTr = length(s.currenttrials{iGrp});
    for iTr = 1:nTr
        
        % get current trials
        csTr = s.currenttrials{iGrp}(iTr);
        cCTr = find(C.iTr==csTr);
        
        % align s and C times
        CAlignOffset = s.events{iCAlignEvent,csTr};
        CSpecOffset = C.T(find(C.idx(cCTr,:),1,'first')) + COffset;
        
        % crop spec
        iSpecT =  C.SpecT{cCTr}+CSpecOffset>=CropWin(1) & C.SpecT{cCTr}+CSpecOffset<=CropWin(2);
        
        R(iGrp).Spec(:,:,iTr) = C.SpecS
    end
end
        
        
        

