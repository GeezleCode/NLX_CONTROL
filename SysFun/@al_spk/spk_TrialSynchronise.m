function TrialIndex = spk_TrialSynchronise(s,CmpTrialCode,ConversionTerm)

% Find matching trials in two objects using s.trialcode property
% First is used as reference, allowing the second to have missing trials 
%
% s .............. object array
% IDTrialCode ....
% CmpTrialCode ...
%
% TrialIndex ..............

if nargin<3
    ConversionTerm = [];
end

%% check number of objects
nObj = length(s);
[nDum,nTC] = size(CmpTrialCode);
if nObj~=2 || nDum~=2;
    error('Provide trialcode definitions for 2 objects!');
end

%% get trialcode

CompArr = cell(1,nObj);
for iObj = 1:2
    for iTC =1:nTC
        cTrialCodeNr = spk_findTrialcodelabel(s(iObj),CmpTrialCode(iObj,iTC));
        if isnan(cTrialCodeNr)
            error('Can''t find trialcodelabel!');
        end
        
        CompArr{iObj}(iTC,:) = s(iObj).trialcode(cTrialCodeNr,:);
        
        % convert trialcode
        if ~isempty(ConversionTerm) && ~isempty(ConversionTerm{iObj,iTC})
            eval(['CompArr{iObj}(iTC,:) = CompArr{iObj}(iTC,:)' ConversionTerm{iObj,iTC} ';']);
        end
    end
end

%%

% [TstIndex,RefIndex] = MatchVecOrder(CompArr{iObj},CompArr{iObj});%% Big Bug !!!!!!!!! discovered on 24/5/2012 
[TstIndex,RefIndex] = MatchVecOrder(CompArr{1},CompArr{2}); 
TrialIndex = [RefIndex;TstIndex];




function [TstIndex,RefIndex] = MatchVecOrder(Ref,Tst)
% Ref is used as reference, allowing Tst to have missing trials 

nRef = size(Ref,2);
nTst = size(Tst,2);
TstIndex = [];
RefIndex = [];
TstCnt = 1;
RefCnt = 1;

StartSeqWin = 4;
StartSeqMax = 50;


if nRef==nTst & all(Ref==Tst)% both identical
	TstIndex = 1:nTst;
	RefIndex = 1:nRef;
else
	
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % find a sequence with 3 matches in a row
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % start with counting up the reference (cortex) trial
    % e.g. cortex failed to record trials at the beginning
    foundSeq = 0;
    StartTstCnt = 1;
    StartRefCnt = 1;
   
    while foundSeq==0
        TstCnt = StartTstCnt;
        RefCnt = StartRefCnt;
        while RefCnt<=nRef-(StartSeqWin-1) & RefCnt<StartSeqMax
            if all( ...
                    Ref(:,[RefCnt:RefCnt+(StartSeqWin-1)])==Tst(:,TstCnt:TstCnt+(StartSeqWin-1)) ...
                    | isnan(Ref(:,[RefCnt:RefCnt+(StartSeqWin-1)])) ...
                    | isnan(Tst(:,TstCnt:TstCnt+(StartSeqWin-1))))
                foundSeq = 1;
                break;
            else
                RefCnt = RefCnt+1;
            end
        end
        
        % start with counting up the test (neuralynx) trials
        % e.g. neuralynx failed to record trials at the beginning
        if foundSeq==0
            foundSeq = 0;
            TstCnt = StartTstCnt;
            RefCnt = StartRefCnt;
            while TstCnt<=nTst-(StartSeqWin-1) & TstCnt<StartSeqMax
            if all( ...
                    Ref(:,[RefCnt:RefCnt+(StartSeqWin-1)])==Tst(:,TstCnt:TstCnt+(StartSeqWin-1)) ...
                    | isnan(Ref(:,[RefCnt:RefCnt+(StartSeqWin-1)])) ...
                    | isnan(Tst(:,TstCnt:TstCnt+(StartSeqWin-1))))
                    foundSeq = 1;
                    break;
                else
                    TstCnt = TstCnt+1;
                end
            end
        end
        StartTstCnt = StartTstCnt+1;
        StartRefCnt = StartTstCnt+1;
        if StartTstCnt>5
            break;
        end
    end

    if foundSeq==0
        error('Couldn''t find matching sequence between cortex and neuralynx trials!!');
        foundSeq = 1;
        TstCnt = 1;
        RefCnt = 1;
    end

    %:::::::::::::::::::::::::::::::::::::
    % now that the start sequence is known, count up cortex (ref) trials
    % since cortex is more reliable
    if foundSeq==0
        error('Can''t match files!!')
    else
        while TstCnt<=nTst & RefCnt<=nRef
            if all( ...
                    Ref(:,RefCnt)==Tst(:,TstCnt) ...
                    | isnan(Ref(:,RefCnt)) | isnan(Tst(:,TstCnt)))
                TstIndex = [TstIndex TstCnt];
                RefIndex = [RefIndex RefCnt];
                TstCnt = TstCnt+1;
                RefCnt = RefCnt+1;
            else
                RefCnt = RefCnt+1;
            end
        end
    end
    
    
end


