function s = spk_ExtractSpikeUnitTypes(s,UnitTypes)

% extracts an object with spike channels of the given unittype
% s = spk_ExtractSpikeUnitTypes(s,UnitTypes)

s = spk_ExtractSpikeChan(s,find(ismember(s.unittype,UnitTypes)));
