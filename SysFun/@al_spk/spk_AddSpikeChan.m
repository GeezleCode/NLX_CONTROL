function [s,i] = spk_AddSpikeChan(s,ChanLabel,TimeStamps,Waveforms,WaveformAlign,WaveformSF)

% adds a spike channel
% [s,i] = spk_AddSpikeChan(s,ChanLabel,TimeStamps,Waveforms,WaveformAlign,WaveformSF)

[nCh,nTr] = size(s.spk);
i = nCh+1;
s.channel{i} = ChanLabel;

if nargin>2 && ~isempty(TimeStamps)
    s.spk(i,:) = TimeStamps(:)';
elseif ~isempty(s.spk)
    s.spk(i,:) = {[]};
end

if nargin>3 && ~isempty(Waveforms)
    s.spkwave(i,:) =  Waveforms;
    s.spkwavealign(i) = WaveformAlign;
    s.spkwavefreq(i) = WaveformSF;
elseif i>1 && ~isempty(s.spkwave)
    s.spkwave(i,:) =  cell(1,nTr);
    s.spkwavealign(i) = NaN;
    s.spkwavefreq(i) = NaN;
end
