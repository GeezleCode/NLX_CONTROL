function [ElectrodeName,ClusterNr] = spk_SpikeDecodeChanName(s)

% decodes channel labels of the form 'Sc1.1'
%
% [ElectrodeName,ClusterNr] = spk_SpikeDecodeChanName(s)
%
% ElectrodeName ... cell array of strings
% ClusterNr ....... vector of integers

ElectrodeName = {};
ClusterNr = [];
for i=1:length(s.channel)
    [ElectrodeName{i},rem] = strtok(s.channel{i},'.');
    k = strtok(rem,'.');
    if ~isempty(k)
        ClusterNr(i) = sscanf(k,'%d');
    else
        ClusterNr(i) = NaN;
    end
end