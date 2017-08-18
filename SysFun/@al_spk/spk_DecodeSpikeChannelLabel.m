function [ElectrodeName,ClusterNr] = spk_DecodeSpikeChannelLabel(s)

% decodes channel labels of the form 'Sc1.1'
%
% [ElectrodeName,ClusterNr] = spk_DecodeSpikeChannelLabel(s)
%
% ElectrodeName ... cell array of strings
% ClusterNr ....... vector of integers

for i=1:length(s.channel)
    [ElectrodeName{i},rem] = strtok(s.channel{i},'.');
    k = strtok(rem,'.');
    ClusterNr(i) = sscanf(k,'%d');
end