function values = spk_get(s,varargin)

% Get the value of @al_spk fields.
% values = spk_get(s,field1,field2, ...,fieldn)
%
% values is a cell array if you enter more than 1 field

values = [];

n = length(varargin);

fn = fieldnames(s);

for i = 1:n
	if ~ismember(varargin{i},fn)
		cVal = NaN;
	else
        strField = varargin{i};
        cVal = s.(deblank(strField));
% 		cVal = getfield(s,varargin{i});
	end
	if n==1
		values = cVal;
	else
		values{i} = cVal;
	end
end
