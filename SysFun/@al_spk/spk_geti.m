function cVal = spk_geti(s,fieldname,varargin)

% Get the ith element of @al_spk field.
% cVal = spk_geti(s,fieldname,index1,index2, ...)
% index separated by comma -> subscripting
% index as array, -> indexing

sz = size(s.(fieldname));
if nargin>3
    index =  sub2ind(sz,varargin{:});
else
    index = varargin{1};
end
cVal = s.(fieldname)(index(:)');
