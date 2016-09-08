function Count = count_timestamps(TimeStamps,WinLo,WinHi,Tau)
% TimeStamps ... column vector
% WinLo ....... column vector
% WinHi ...... column vector
% Tau .......... row vector
%
% Count .... [n Win , n Tau]

NumTS = length(TimeStamps);
NumTau = length(Tau);
NumWin  = length(WinLo);
Count = zeros(NumWin,NumTau);
TSmat = repmat(TimeStamps,[1 NumTau]) + repmat(Tau,[NumTS 1]);

currSpkNum = zeros(1,NumTau);
for w = 1:NumWin
    Count(i,:) = sum((TSmat>=WinLo(w) & TSmat<=WinHi(w)),1);
end

