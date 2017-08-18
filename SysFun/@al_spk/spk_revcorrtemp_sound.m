  function rcHist = spk_revcorrtemp_sound(s,t,T)

% calculates a reverse correlation to a temporal sequence of different stimuli  
% rcHist = spk_revcorrtemp(s,t,T)
% t ... is a cell array with two column matrices for ALL trials of the object, 
%       describing the time window for each stimulus, all matrices must
%       have same number of rows (number of stimuli).
% T ... temporal shift, can be a vector
% rcHist ... 3 dim matrix of spike counts (num. of trials,num. of  stim.,temporal shifts,channels)

numT = length(T);
numTr = length(s.currenttrials);
if length(t)~=numTr;error('wrong number of trials');end
numStimArr = cellfun('size',t,1);
numStim = unique(numStimArr);
if length(numStim)>1
    warning(['Trials have different number of stimuli ' num2str(numStim) ' !']);
end

[NumChan,ChanLabel,EmptyChan] = spk_SpikeChanNum(s);
if isempty(s.currentchan)
    s.currentchan = [1:NumChan];
end

rcHist = zeros(numTr,max(numStim),numT,length(s.currentchan),1);
cnt = 0;
for i = s.currenttrials % loop trials
    cnt = cnt+1;
    tind = find(s.currenttrials==i);
    for j = 1:size(t{tind},1) % loop stimuli
        for k = 1:numT % loop the different time shifts
            
            for cc = s.currentchan
                if isempty(s.spk{cc,i})
                    rcHist(tind,j,k,s.currentchan==cc) = 0;
                else
                    rcHist(tind,j,k,s.currentchan==cc) = sum((s.spk{cc,i}-T(k) >= t{tind}(j,1) & s.spk{cc,i}-T(k) < t{tind}(j,2)));
                end
            end
            
        end
    end
end
