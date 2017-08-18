function i = spk_findEventlabel(s,eventlabel)

% returns the index of an eventlabel
%
% function i = spk_findevent(s,eventlabel)
%
%

if iscell(eventlabel)
    n = length(eventlabel);
    for k=1:n
        ci = strmatch(upper(eventlabel{k}),upper(s.eventlabel),'exact');
        if isempty(ci)
            warning('spk_findeventlabel: unknown event !');
            i(k) = 0;
        else
            i(k) = ci;
        end
    end
elseif ischar(eventlabel)
    i = strmatch(upper(eventlabel),upper(s.eventlabel),'exact');
    if isempty(i)
        warning('spk_findeventlabel: unknown event !');
    end
end
    
