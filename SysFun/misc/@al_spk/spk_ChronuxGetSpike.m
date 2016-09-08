function x = spk_ChronuxGetSpike(s,tWin,Ev,TimeWinAlignFlag,ChNr,TrNr)

% extract spike data to chronux format: struct(chan/trials).times; in SEC.!
% x = spk_ChronuxGetSpike(s,tWin,Ev,TimeWinAlignFlag,ChNr,TrNr)
%
% tWin ............... relative event window
% Ev ................. char/numeric; if set tWin works as an offset to the event
% TimeWinAlignFlag ... aligns to start of time window
% tPrec .......... temporal precision of timestamps, removes dup. timestamps as well.
% precision. Removes the resulting timestamp duplicates
% ChNr,TrNr .......... channel index and trial index

if nargin>=6&&~isempty(TrNr);s.currenttrials = TrNr;end
if nargin>=5&&~isempty(ChNr);s.currentchan = ChNr;end
if nargin<4;TimeWinAlignFlag==true;end

% extract spikes in time window
[spks,tWin] = spk_getSpikes(s,tWin,Ev);

% loop thru channels and trials
[nCh,nTr] = size(spks);
x = struct('times',cell(nCh,nTr));
for iCh = 1:nCh
    for iTr = 1:nTr
        
        % align
        if TimeWinAlignFlag
            spks{iCh,iTr} = spks{iCh,iTr} - tWin(iTr,1);
        end
        
        % convert to sec
        spks{iCh,iTr} = spks{iCh,iTr}.*(10^(s.timeorder));
        
        % put into structure, make sure spikestimes are column vector
        x(iCh,iTr).times = spks{iCh,iTr}(:);
    end
end
