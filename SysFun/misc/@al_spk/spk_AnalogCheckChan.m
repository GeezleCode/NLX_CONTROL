function n = spk_AnalogCheckChan(s)

% check for consistency of analog channel data, returns number of channels.

%% take data field as reference for channel number
if ~iscell(s.analog) && isempty(s.analog)
    n = 0;
elseif iscell(s.analog)
    [r,c] = size(s.analog);
    
    if r>c
        error('Analog channels should be along columns!');
    end
    
    n = c;
else
    error('Analog data are expected to be a cell array!');
end

%% check rest of analog fields
if n>0
    if any([ ...
            ~iscell(s.analogunits), ...
            ~iscell(s.analogname), ...
            ~iscell(s.analogtime), ...
            ~iscell(s.analogunits)]) ...
            || any([ ...
            length(s.analogunits)~=n, ...
            length(s.analogname)~=n, ...
            length(s.analogfreq)~=n, ...
            length(s.analogtime)~=n, ...
            length(s.analogalignbin)~=n])
        error('Analog channel numbers are inconsistent across fields!');
    end
end
