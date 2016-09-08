function [varargout] = spk_CurrentIndex(s,IndexField,AllFlag,OutputOption)

% returns selection in index fields (currenttrials, currentchan,
% currentanalog)
% [I] = spk_CurrentIndex(s,IndexField,AllFlag,'index')
% [N] = spk_CurrentIndex(s,IndexField,AllFlag,'n')
% [s] = spk_CurrentIndex(s,IndexField,AllFlag,'s')
% [I,N,s] = spk_CurrentIndex(s,IndexField,AllFlag)
%
% IndexField ..... 'Trial'
%                  'Spike'
%                  'Analog'
% AllFlag ........ if nothing is selected, select all
% OutputOption ... 'index'
%                  'n'
%                  's'

%% check IndexFields
if nargin<2 || isempty(IndexField)
    IndexField = {'Trial' 'Spike' 'Analog'};
elseif ischar(IndexField)
    IndexField = {IndexField};
end
nFlds = length(IndexField);
        
%%
if nargin<3
    AllFlag = false;
end

%%
I = cell(1,nFlds);
N = zeros(1,nFlds);
for iFld = 1:nFlds
    if strcmpi(IndexField{iFld},'Trial')
        cFld = 'currenttrials';
        cFldN = spk_TrialNum(s,false);
    elseif strcmpi(IndexField{iFld},'Spike')
        cFld = 'currentchan';
        cFldN = size(s.spk,2);
    elseif strcmpi(IndexField{iFld},'Analog')
        cFld = 'currentanalog';
        cFldN = length(s.analog);
    end
    
    if isempty(s.(cFld)) && AllFlag(iFld)
        s.(cFld) = 1:cFldN;
    end
    
    I{iFld} = s.(cFld);
    N(iFld) = length(I{iFld});
end

%% output
if nFlds==1
    I = I{1};
end
if nargin>3
    switch lower(OutputOption)
        case 'index'
            varargout{1} = I;
        case 'n'
            varargout{1} = N;
        case 's'
            varargout{1} = s;
        otherwise
            varargout = {I,N,s};
    end
end
    
    
