function s = StructUpdate(s1,varargin)

% updates selected fields of a structure (no multidimensional)
% s = StructUpdate(s,s2)
% s = StructUpdate(s,'field1',value1,'field2',value2, ...)

f1 = fieldnames(s1);
s = s1;

if length(varargin)==1 && isempty(varargin{1})
    return;
elseif length(varargin)==1 && isstruct(varargin{1})
    %% input is another structure
    s2 = varargin{1};
    f2 = fieldnames(s2);
    for i=1:length(f2)
        if ~any(strcmp(f2{i},f1));
            %warning('"%s" is not an existing fieldname',f2{i});
            %fprintf('StructUpdate: "%s" is not an existing fieldname\n',f2{i});
            continue;
        end
        s(1).(f2{i}) = s2.(f2{i});
    end
elseif  rem(length(varargin),2)==0
    %% input is a fieldname and value pairs
    f2 = varargin(1:2:end);
    v2 = varargin(2:2:end);
    for i=1:length(f2)
        if ~any(strcmp(f2{i},f1));
            error('"%s" is not an existing fieldname',f2{i});
            continue;
        end
        s(1).(f2{i}) = v2{i};
    end
else
    error('Input must be either a structure or property/value pairs!');
end