function [newh] = subaxes(h,sizeAxes,index,interspace,edgespace,printsize,printunits)

% [newh] = subaxes(h,sizeAxes,index,interspace,edgespace)
%
% tile a parent axes in an array of new axes
% INPUT:
% h ............ handle of figure or axes
% sizeAxes ..... m by n number of new axes, if scalar then ...
% index ........ subscript [row,col], if than one index pair  matlab returns
%               the area of axes
% interspace .... space between axes in [vertical,horizontal] distance in normalized units;
% edgespace .... space at edges [left,right,top,bottom]
% OUTPUT:
% newh ....... m by n matrix of handles

%% check input
if nargin<7
    printunits = '';
    if nargin<6
        printsize = [];
        if nargin<5
            edgespace = [0 0 0 0];
            if nargin<4
                interspace = [0 0];
                if nargin<3
                    index = [];
        end;end;end;end;end
if length(edgespace)==1;edgespace = ones(1,4).*edgespace;end

%% axes size is scalar
if numel(sizeAxes)==1
    sizeAxes = ones(1,2).*ceil(sqrt(sizeAxes));
end
if numel(index)==1
    [index(1),index(2)] = ind2sub(sizeAxes,index);
end

rowNr = repmat([1:sizeAxes(1)]',1,sizeAxes(2));
colNr = repmat([1:sizeAxes(2)],sizeAxes(1),1);

%% deal with old axes
if strcmp(upper(get(h,'type')),'FIGURE')
    baseUnits = 'normalized';
    basePos = [0 0 1 1];
    hFig = h;
elseif strcmp(upper(get(h,'type')),'AXES')
    baseUnits = 'normalized';
    set(h,'units',baseUnits);
    basePos = get(h,'position');
    hFig = get(h,'parent');
else
    error('Parent object to the subaxes function must be a figure or an axes !');
end

%% get measures
if ~isempty(printunits) & ~isempty(printsize) 
    OldpUnits = get(h,'paperunits');
    set(h,'paperunits',printunits);
    pPos = get(h,'paperposition');
    
    newwidth = printsize(1)/pPos(3);
    newheight = printsize(2)/pPos(4);
    interSpace(1) = interspace(1)/pPos(4);
    interSpace(2) = interspace(2)/pPos(3);
    edgeSpace([1 2]) = edgespace([1 2])./pPos(3);
    edgeSpace([3 4]) = edgespace([3 4])./pPos(4);
    
    set(h,'paperunits',OldpUnits);
    
    x0 = edgeSpace(1);
    y0 = 1-edgeSpace(3);
else
    interSpace = interspace.*[basePos(4) basePos(3)];
    edgeSpace = edgespace.*[basePos(3),basePos(3),basePos(4),basePos(4)];
    newheight =     (basePos(4) - (interSpace(1)*(sizeAxes(1)-1)) - edgeSpace(3) - edgeSpace(4)    ) /sizeAxes(1);
    newwidth =      (basePos(3) - (interSpace(2)*(sizeAxes(2)-1)) - edgeSpace(1) - edgeSpace(2)    ) /sizeAxes(2);
    
    x0 = basePos(1) + edgeSpace(1);
    y0 = basePos(2) + basePos(4) - edgeSpace(3);    
end

% make matrix for lower left position
X = x0 + (colNr-1).*newwidth + (colNr-1).*interSpace(2);
Y = y0 - (rowNr*newheight) - ((rowNr-1).*interSpace(1));

if isempty(index)
    % make all at once
     for m = 1:sizeAxes(1)
          for n = 1:sizeAxes(2)
               newh(m,n) = axes('parent',hFig,'units',baseUnits,'position',[X(m,n) Y(m,n) newwidth newheight]);
          end
     end
else
    % make selected axes
    % index can define an area !
     topI = min(index(:,1));
     bottomI = max(index(:,1));
     leftI = min(index(:,2));
     rightI = max(index(:,2));
     
     newPos(1) = X(bottomI,leftI);
     newPos(2) = Y(bottomI,leftI);
     newPos(3) = X(bottomI,rightI) - X(bottomI,leftI) + newwidth;
     newPos(4) = Y(topI,leftI) - Y(bottomI,leftI) + newheight;
     
     newh = axes('parent',hFig,'units',baseUnits,'position',newPos);
end
