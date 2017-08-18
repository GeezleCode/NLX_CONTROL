function s = al_spk(x)

% Constructor for the @al_spk class
%
% function s = neurons(x)
% s		- @al_spk object
% x		- INPUT
%
% MAG 28.08.2004

structure;%Read the default data structure.

nin = nargin;

if nin ==0 
   % Default constructor
   s = class(s,'al_spk');
   
elseif isa(x,'struct')
   
   xFields = fieldnames(x);
   sFields = fieldnames(s);
   nrFields = length(sFields);
   for fieldNr = 1:nrFields
	   indexInx = strmatch(sFields{fieldNr},xFields,'exact');
	   if ~isempty(indexInx)
		   s = setfield(s,sFields{fieldNr},getfield(x,xFields{indexInx}));
	   end   
   end
   
   s = class(s,'al_spk');
   
elseif isa(x,'al_spk')
   % Copy constructor
   s = x;	
   
else
   s = class(s,'al_spk');
   error(s,'No such constructor')
   
end
