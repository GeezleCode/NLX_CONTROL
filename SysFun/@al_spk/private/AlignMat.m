function [y,newalignBin] = AlignMat(x,alignbins,bindim,aligndim)

% realigns row/columns of an existing matrix
%
% x ............. array
% alignbins ..... indices in bindim
% bindim ........ dimension of the aligning shift
% aligndim ...... dimension of the align

an = size(x,aligndim);
if an~=length(alignbins)
	error('Input is inconsistent !!!');
end

% permutation array
Perm = 1:3;
Perm(1) = aligndim;
Perm(2) = bindim;
Perm(3) = find(~ismember([1:3],[bindim aligndim]));

% save for NaN's in alignbins
nans = isnan(alignbins);
if any(nans)
    alignbins(nans) = 1;
    x = permute(x,Perm);
    x(nans,:) = NaN;
    x = ipermute(x,Perm);
end

nd = ndims(x);
n = zeros(1,nd);
[n(:)] = size(x);

leadn = max(alignbins)-alignbins;
trailn = alignbins-min(alignbins);

newalignBin = leadn(1)+alignbins(1);

nn = unique(leadn+trailn);
m = n;
m(bindim) = nn;
y = cat(bindim,x,ones(m).*NaN);

y = permute(y,Perm);
for i=1:an
	y(i,:,:) = circshift(y(i,:,:),[0 leadn(i) 0]);
end
y = ipermute(y,Perm);