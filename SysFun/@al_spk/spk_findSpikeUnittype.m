function ChanIndex = spk_findSpikeUnittype(s,Unittype)

% get the indices of ChanIndex as appearing in s.unitttype
% ChanIndex = spk_findSpikeUnittype(s,Unittype)
%
% ChanName ... cell array of channel names

ChanIndex = ismember(s.unittype,Unittype);
