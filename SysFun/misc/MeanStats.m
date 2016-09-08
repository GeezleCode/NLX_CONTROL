function [M,S,SE,Mci] = MeanStats(x,alpha,dim);

% function [M,S,SE,Mci] = MeanStats(x,alpha,dim)
%
% INPUT
% x .......... Matrix data with NaN's
% alpha ...... confidence level 0.05=>95%
% dim ........ dimension to calculate mean
%
% OUTPUT for matrix columns
% M .......... Mean
% S .......... Standard deviation
% SE ......... Standard Error
% Mci ........ Confidence interval of the mean
%
% Alwin 05.06.2002
% Alwin 10.10.2005


% Check for empty input.
if isempty(x) 
    M = NaN;S=NaN;SE=NaN;Mci=[NaN;NaN];Sci=[NaN;NaN];
    return;
end

if nargin < 2 | isempty(alpha)
    alpha = 0.05;
end
if nargin <3 | isempty(dim)
    dim=1;
end

%_________________________
% prepare array
nans = isnan(x);
i = find(nans);
x(nans) = 0;

% N of sample
N = size(x,dim)-sum(nans,dim);

% Protect N against a column of all NaNs (divided by zero)
Nzeros = (N==0);
N(Nzeros) = NaN;

%_________
% Mean M
M = sum(x,dim)./N;

%________________________________
% Variance and Standard deviation
dd = ones(1,length(size(M)));
dd(dim) = size(x,dim);
xS = x - repmat(M,dd);

% Replace NaNs with zeros.
xS(nans) = 0;

N_safe_minus_1 = N-1;
N_safe_minus_1(N_safe_minus_1<1) = 1;
V = sum(xS.*xS,dim)./N_safe_minus_1;
S = sqrt(V);

if nargout<3;return;end
%____________________________
% standard error of the mean
SE = S./sqrt(N);

if nargout<=3;return;end

%___________________
% degrees of freedom
dF = N-1;

%_________________________________
% confidence interval of the mean
tcrit = tinv(1-alpha/2,dF);
Mci = tcrit.*SE;


%_________________________________
% confidence interval of S not implemented for matrix or NaN data
%_________________________________
%chi2crit = chi2inv([alpha/2 1-alpha/2],dF);
%Sci =  [(S.*sqrt(dF./chi2crit(2))); ...
%          (S.*sqrt(dF./chi2crit(1)))];

