function s = spk_analogconvert(s,factor,units)

% converts analog

numAna = length(s.currentanalog);

for a = 1:numAna
    iAna = s.currentanalog(a);
    
    if isempty(s.analogunits)
        s.analogunits = cell(1,length(s.analogname));
    end
    
    if ~isempty(s.analogunits{iAna}) & strcmp(upper(s.analogunits{iAna}),upper(units))
        warning(['Analog data already exists as ' units '! ->No conversion']);
    else
        s.analogunits{iAna} = units;
        if isnumeric(factor)
            s.analog{iAna} = s.analog{iAna}.*factor;
        elseif ischar(factor)
            eval(['s.analog{s.currentanalog(a)} = ' strrep(factor,'X','s.analog{s.currentanalog(a)}') ';']);
        end
        
    end
end