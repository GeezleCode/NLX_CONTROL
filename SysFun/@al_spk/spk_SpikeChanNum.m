function [NumChan,ChanLabel,EmptyChan,NumSpk] = spk_SpikeChanNum(s);

% returns channel data
% [NumChan,ChanLabel,EmptyChan,NumSpk] = spk_numchan(s)
%
% NumChan ..... number of channels
% ChanLabel ... returns the channels labels as appearing in s.channels
% EmptyChan ... logical array, returns channels containing no spike in
%               every trial
% NumSp ....... number of spikes per trial per channel

NumChan = size(s.spk,1);
NumChanLabel = length(s.channel);
NumUnittypes = length(s.unittype);

%% check consistency
if NumChan~=NumChanLabel
    error('Channel number (s.spk) and channel label (s.channel) are inconsistent !');
end
if NumChan~=NumUnittypes && ~isempty(s.unittype)
    error('Channel number (s.spk) and unit types (s.unittype) are inconsistent !');
end

ChanLabel = s.channel;

if nargout>2
    EmptySpk = cellfun('isempty',s.spk);
    EmptyChan = all(EmptySpk,2);
    if nargout>3
        NumSpk = cellfun('length',s.spk);
    end;end