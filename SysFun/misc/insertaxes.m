function nH = insertaxes(h,position)

% function nH = insertaxes(h,position)
%
% creates a new axes as an insert in a parent axes
% INPUT:
% h - handle of parent axes
% position - position in parent axes as normalized units
% OUTPUT:
% nH - new axes handle

oldPos = get(h,'position');
oldUnits = get(h,'units');
parentfig = get(h,'parent');

newHor = oldPos(1)+oldPos(3)*position(1);
newVert = oldPos(2)+oldPos(4)*position(2);
newWidth = oldPos(3)*position(3);
newHeight = oldPos(4)*position(4);

nH = axes('parent',parentfig,'units',oldUnits,'position',[newHor newVert newWidth newHeight]);