function ChanIndex = spk_findElectrodeChan(s,ElectrodeName,ClusterNr)

% get the index of a spike channel
%
% ChanIndex = spk_findElectrodeChan(s,ElectrodeName,ClusterNr)

[Els,Cls] = spk_SpikeDecodeChanName(s);
ChanIndex = find(ismember(Els,ElectrodeName) & Cls==ClusterNr);