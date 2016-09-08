function new = convert(old,new)
% function object = convert(old,new)
%
% Convert a structure 'old' that contains some of the fields of the object of 
% new's type to a structure with the same fields as 'new'. Values that are not
% defined in the old object take on the value of the new object. This makes it possible 
% to change class definitions and still use the saved data files with objects of the old type in it.
%
% Note that data in 'old' that are no longer defined or renamed in 'new' are lost!
%
% This function should be called from the constructor of the class, where a default object is available.
% This default object is passed as a structure (in new), together with the structure that was loaded from file.
% THe constructor will receive an updated structure from here, which it can convert to an object.
% INPUT
%	old	A structure with field definitions of an older version.
%  new   The default structure with the current field definitions and default values.
% OUTPUT
%  new	An updated version of the old-object, now containing all fields that are also
%			defined in the current default. 
%
%  BK - 2/6/99

oldFields = fieldnames(old);
newFields = fieldnames(new);
nrFields = length(newFields);


for fieldNr = 1:nrFields
   indexInOld = strmatch(newFields{fieldNr},oldFields,'exact');
   if ~isempty(indexInOld)
      new = setfield(new,newFields{fieldNr},getfield(old,oldFields{indexInOld}));
   end   
end
% The version should not be set to the new version if it did not already exist.
hasVersion = strmatch('version',oldFields,'exact');
if isempty(hasVersion)
   new.version = -1;
end
