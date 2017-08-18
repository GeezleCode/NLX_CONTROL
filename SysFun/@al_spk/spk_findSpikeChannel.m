function ChanIndex = spk_findSpikeChannel(s,ElectrodeName,ClusterNr)

% get the index of a spike channel
%
% ChanIndex = spk_findSpikeChannel(s,ElectrodeName,ClusterNr)

[Els,Cls] = spk_DecodeSpikeChannelLabel(s);
ChanIndex = find(ismember(Els,ElectrodeName) & Cls==ClusterNr);