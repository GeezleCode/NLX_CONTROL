function [t,x,b,tStart,xStart,bStart] = spk_AnalogFindNextBin(s,tStart,SearchTerm,SearchPar,MoveDir)

% Go through analog bins until a bin is found.
% Needs 'currentanalog' and 'currenttrials' to be set.
% [t,x,b,tStart,xStart,bStart] = spk_AnalogFindNextBin(s,tStart,SearchTerm,SearchPar,MoveDir)
%
% tStart .................. [double] time to start search from. 
%                           [char] name of event or bin number.
% SearchTerm/SearchPar .... 
%        'ZERO'             looks for value crossing zeros
%        'SIGN' [+/-1]      looks for an change in sign of value
%        'SLOPE' [+/-1]     looks for next change in sign of bin difference
%        'SLOPE+SIGN' [+/-1 +/-1]      combines both
%        'PERCENT' [x]      looks for over/undershoot of value in relation 
%                           to start bin.
%        'OVERSHOOT' 'UNDERSHOOT' same as 'PERCENT' but using absolute
%                                 values
% MoveDir .............. [-x,+x] search direction/stepsize from tStart on

%% check current channels
iChan = s.currentanalog;
nChan = length(iChan);
if nChan>1
    error('Don''t select more than one channel!');
end
[nTotTr,nBin] = size(s.analog{iChan});

%% set current trials
if isempty(s.currenttrials)
    s.currenttrials = 1:size(s.analog{iChan},2);
end
nTr = length(s.currenttrials);

%% get start bin
tVec = spk_AnalogTimeVec(s);
if isnumeric(tStart)
    if numel(tStart)>1 && size(tStart,1)==1;error('');end
    for iTr=1:size(tStart,1)
        [bStartErr,bStart(iTr)] = min(abs(tVec-tStart(iTr)));
    end
elseif ischar(tStart)
    if all(ismember('12','0123456789'))
        bStart = sscanf(tStart,'%d');
    else
        tStart = spk_getEvents(s,tStart);
        tStart(cellfun('isempty',tStart)) = {NaN};
        if any(cellfun('prodofsize',tStart)~=1)
            error('Start events contain more than one time!');
        end
        if length(tStart)~=nTr
            error('This one shouldn''t occur');
        end
        tStart = cat(1,tStart{:});
        [dummy,bStart] = ismember(tStart,tVec);
    end
end
nbStart = length(bStart);
if nbStart==1
    bStart = ones(nTr,1).*bStart;
    nbStart = nTr;
elseif nbStart~=nTr
    error('error');
end

%% preallocate results
b = ones(nTr,1).*NaN;
t = ones(nTr,1).*NaN;
x = ones(nTr,1).*NaN;

%% loop trials
for iTr = 1:nTr
    cPar = SearchPar;
    cVec = s.analog{iChan}(s.currenttrials(iTr),:);
    cBin = bStart(iTr);
    xStart(iTr,1) = cVec(cBin);
    tStart(iTr,1) = tVec(cBin);
    switch upper(SearchTerm)
        case 'ZERO'
            % return the bin before crossing zero (change of signs)
            while (MoveDir==-1&&cBin>1) || (MoveDir==1&&cBin<nBin)
                cVal = cVec(cBin);
                if isnan(cVal) || cVal==0
                    break;
                elseif isempty(cPar) && cVal*cVec(cBin+MoveDir)<0
                    break;
                elseif ~isempty(cPar) && cPar<0 && cVal<0 && cVal*cVec(cBin+MoveDir)<0    
                    break;
                elseif ~isempty(cPar) && cPar>0 && cVal>0 && cVal*cVec(cBin+MoveDir)<0    
                    break;
                end
                cBin = cBin+MoveDir;
            end
            if cBin>0 && cBin<=nBin
                b(iTr,1) = cBin;
                t(iTr,1) = tVec(cBin);
                x(iTr,1) = cVec(cBin);
            end
            
        case 'SLOPE'
            % returns the bin before the increment changes sign    
            while (MoveDir==-1&&cBin>1) || (MoveDir==1&&cBin<nBin)
                cVal = cVec(cBin);
                dBins = sort([cBin cBin+MoveDir]);
                cSlope = diff(cVec(dBins));
                if (cBin-MoveDir>nBin ||  (cBin-MoveDir<1))
                    PreSlope = NaN;
                else
                    dBins = sort([cBin cBin-MoveDir]);
                    PreSlope = diff(cVec(dBins));
                end
                if isnan(cVal)
                    break;
                elseif isempty(cPar) && cSlope*PreSlope<0
                    break;
                elseif ~isempty(cPar) && cPar<0 && PreSlope<0 && cSlope*PreSlope<0    
                    break;
                elseif ~isempty(cPar) && cPar>0 && PreSlope>0 && cSlope*PreSlope<0    
                    break;
                end
                cBin = cBin+MoveDir;
            end
            if cBin>0 && cBin<=nBin
                b(iTr,1) = cBin;
                t(iTr,1) = tVec(cBin);
                x(iTr,1) = cVec(cBin);
            end
        case 'PERCENT'
            error('-------------------- Under construction -----------------------------');
        case 'UNDERSHOOT'
            error('-------------------- Under construction -----------------------------');
        case 'OVERSHOOT'
            error('-------------------- Under construction -----------------------------');
    end 
end

