function [Y,alignBin]  = mergearrays(X,dim,align,insertindex)

% [new,alignBin]  = mergearrays(X,dim,align)
%
% Merge vectors or matrices along dim aligned to align
% Missmatched areas of array are padded with NaNs
%
% INPUT
% X ........... cell array
% dim ......... dimension of concatenation
% align ....... alignment indices in 3 dimensions for every cell [cellnr,dim]
% OUTPUT
% Y ........... new array
% alignBin .... row aligned to of the new matrix
% insertindex ... if set, inserts second cell in first
%
% Alwin 8/2002
% Alwin 5/2013

%% check input
X = X(:)';% make horizontal array
numArr = length(X);
if numArr==0;
    Y = NaN;alignBin = NaN;return;
end

if nargin<3
    align = ones(numArr,3);
    if nargin<2
        dim = 1;
    end;end
if size(align,2)<3
    error('''align'' must be 3-Column-Vector with alignment indices for every: [cellnr,dim] !');
end
if size(align,1)<numArr
    error('''align'' must be 3-Column-Vector with alignment indices for every: [cellnr,dim] !');
end

%% get sizes of arrays
% SIZES = [];
% for i = 1:numArr
%     cArrSize = size(X{i});
%     if length(cArrSize)<3
%         cArrSize = cat(2,cArrSize,ones(1,3-length(cArrSize)));
%     end
%     SIZES = cat(1,SIZES,cArrSize);
% end

XDimNum = cellfun('ndims',X);
maxDim = max(XDimNum);
XDimNum = max([maxDim 3]);
SIZES = zeros(numArr,XDimNum);
for i=1:XDimNum
    SIZES(:,i) =  cellfun('size',X,i);
end

maxSIZES = max(SIZES);


%% dimension to pad with NaN's
paddims = setxor(1:maxDim,dim);
if length(maxSIZES)<3 & dim~=3
    paddims(find(paddims==3)) = [];
end

for cdim = paddims
    alignBin(cdim) = max(align(:,cdim));
    HEADnum    = alignBin(cdim) - align(:,cdim);
    for i = 1:numArr
        cSize = size(X{i});
        cSize(cdim) = HEADnum(i);
        X{i} = cat(cdim,ones(cSize).*NaN,X{i});
    end
    tail(:,cdim) = SIZES(:,cdim)-align(:,cdim);
    TAILnum = max(tail(:,cdim))-tail(:,cdim);
    for i = 1:numArr
        cSize = size(X{i});
        cSize(cdim) = TAILnum(i);
        X{i} = cat(cdim,X{i},ones(cSize).*NaN);
    end
end

%% merge arrays
if nargin==4 
    Y = shiftdim(X{1},dim-1);
    for i=2:numArr
        xx = shiftdim(X{i},dim-1);
        if size(Y,dim)>=insertindex{i-1}
            Y(insertindex{i-1},:) = xx(:,:);% insert into existing array
        else
            Y = cat(1,Y,xx);% concatenation
        end
    end
    Y = shiftdim(Y,1-dim);
else
    Y = cat(dim,X{:});% concatenation
end












