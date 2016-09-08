function [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,TimeWinAlignFlag,Chan)

% retrieve LFP data in CHRONUX format
% [dlfp,tlfp] = spk_ChronuxGetLFP(s,TimeWin,Event,Chan)
%
% TimeWin .... [lo hi] time window in units of s.timeorder, relative to
%              Event
% Event ...... char - event name, gets event timestamps as reference for
%              the time window.
%              column vector - reference time for time window, length must
%              be 1 or number of s.currenttrials
%              [] - reference is current alignment of object
% TimeWinAlignFlag ... aligns to start of time window
% Chan ....... can be channel name or index, leave empty to use
%              s.currentanalog

if nargin<5;Chan = [];end

[dlfp,tlfp] = spk_getAnalog(s,TimeWin,Chan,Event);

if iscell(dlfp) 
    nChan = length(dlfp);
    for iCh=1:nChan
        [dlfp{iCh},tlfp{iCh}] = Convert2Chronux(dlfp{iCh},tlfp{iCh},TimeWin,TimeWinAlignFlag);
        tlfp{iCh} = tlfp{iCh}.*(10^s.timeorder);
    end
else
    [dlfp,tlfp] = Convert2Chronux(dlfp,tlfp,TimeWin,TimeWinAlignFlag);
        tlfp = tlfp.*(10^s.timeorder);
end
    

function [dlfp,tlfp] = Convert2Chronux(dlfp,tlfp,TimeWin,TimeWinAlignFlag)

AllNaNTrials = all(isnan(dlfp),2);

NotNaNbins = all(~isnan(dlfp(~AllNaNTrials,:)),1);
LoBin = find(NotNaNbins,1,'first');
HiBin = find(NotNaNbins,1,'last');

dlfp = dlfp(:,LoBin:HiBin);
tlfp = tlfp(:,LoBin:HiBin);
dlfp = dlfp';
tStart = unique(tlfp(:,1));
ntStart = length(tStart);
if ntStart>1
    fprintf(1,'spk_ChronuxGetLFP: Data trials have different start time.\n');
    % take the start time which is the least different from the mean of all
    for i=1:ntStart
        dt(i) = abs(mean(tlfp(:,1))-tStart(i));
    end
    [mn,mni] = min(dt);
    tlfp = tlfp(find(tlfp(:,1)==tStart(mni),1,'first'),:);
else
    tlfp = tlfp(1,:);
end
if TimeWinAlignFlag
    tlfp = tlfp-tlfp(1);
end


