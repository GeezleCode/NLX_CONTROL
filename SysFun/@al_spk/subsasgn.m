function s = subsasgn(s,subscript,value)

% Subscript assignmemt for the @al_spk object. 
%
% function s = subsasgn(s,subscript,value)
%
% mag 25.07.2001

error('N assign of values to object fields, use spk_set(s) !');

switch subscript(1).subs
     
     %case 'name';s.name = value;
     
     %case 'ID' 
%	switch subscript(2).subs
%	case 'file'
%		s.ID.file = value;
          %	case 'path'
%		s.ID.path = value;
          %     end
end



