function o = nlx_control_RemovePrefix(s,prefix)
o = s;
if nargin<2
    prefix = 'nlx_control_';
end
i = strfind(s,prefix);
if ~isempty(i)
    o(i:i+length(prefix)-1) = '';
    [p,o,e] = fileparts(o);
end


