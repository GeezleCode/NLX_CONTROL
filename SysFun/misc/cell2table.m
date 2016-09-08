function [TabH,HeadH,SideH,CornerH] = cell2table(H,Data,HeadPlotMode,GridPlotMode)

% plots a cell as a table
% [TabH,HeadH,SideH,CornerH] = cell2table(H,Data,HeadPlotMode)
%
% H .............. target axes
% Data ........... cell array
% HeadPlotMode ... 'IN' all cell array fields will plot inside axes box
%                  'OUT' plots the left column and the top row on axes edges
% GridPlotMode ... 'ALL','BOX','VERTICAL','HORIZONTAL'


[numDataR,numDataC] = size(Data);
if any([numDataR,numDataC]<2)
    HeadPlotMode = 'NONE';
end
if nargin<4
    GridPlotMode = 'NONE';
    if nargin<3
        HeadPlotMode = 'NONE';
    end;end

if strcmp(upper(HeadPlotMode),'NONE')
    Data = cat(1,cell(1,numDataC),Data);
    Data = cat(2,cell(numDataR+1,1),Data);
    HeadPlotMode = 'OUT';
end
Data(cellfun('isempty',Data)) = {''};
[numR,numC] = size(Data);

% calculate cell positions
switch upper(HeadPlotMode)
     case 'IN'
          [x,y,horspace,verspace] = divideaxis(numC,numR);
          
          headx = x(2:end);
          heady = repmat(y(1),length(headx),1);
          
          sidey = y(2:end);
          sidex = repmat(x(1),1,length(sidey));
          
          cornerx = x(1);
          cornery = y(1);
          
          tablex = x(2:end);
          tabley = y(2:end);
     case 'OUT'
          [x,y,horspace,verspace] = divideaxis(numC-1,numR-1);
          
          headx = x;
          heady = repmat(1,length(headx),1);
          
          sidey = y;
          sidex = repmat(0,1,length(sidey));
          
          cornerx = 0;
          cornery = 1;
          
          tablex = x;
          tabley = y;
end

% calculate grid positions
if length(tablex)==1
    Gridx = NaN;
else
    Gridx = tablex(1:end-1) + (tablex(2)-tablex(1))/2;
end
if length(tabley)==1
    Gridy = NaN;
else
    Gridy = tabley(1:end-1) + (tabley(2)-tabley(1))/2;
end

switch upper(HeadPlotMode)
	case 'IN'
		Boxx = [tablex(1) - (tablex(1)-sidex(1))/2 tablex(end) + (tablex(1)-sidex(1))/2];
		Boxy = [tabley(1) + (heady(1)-tabley(1))/2;tabley(end) - (heady(1)-tabley(1))/2];
% 		Boxx = [tablex(1)-unique(diff(tablex))/2 tablex(end)+unique(diff(tablex))/2];
% 		Boxy = [tabley(1)-unique(diff(tabley))/2;tabley(end)+unique(diff(tabley))/2];
        HeadVerticalAlignment = 'middle';
        SideHorizontalAlignment = 'center';
	case 'OUT'
		Boxx = [0 1];
		Boxy = [0;1];
        HeadVerticalAlignment = 'bottom';
        SideHorizontalAlignment = 'right';
end

% prepare axes
axes(H);
set(H,'units','normalized','xlim',[0 1],'ylim',[0 1],'visible','off');

% plot grid
switch upper(GridPlotMode)
    case 'ALL'
        [HorizontalGridX,HorizontalGridY] = meshgrid(Boxx,Gridy);
        [VerticalGridX,VerticalGridY] = meshgrid(Gridx,Boxy);
        line(HorizontalGridX',HorizontalGridY','color','k','clipping','off');
        line(VerticalGridX,VerticalGridY,'color','k','clipping','off');
        [BoxLineX,BoxLineY] = meshgrid(Boxx,Boxy);
        line(BoxLineX',BoxLineY','color','k','clipping','off');
        line(BoxLineX,BoxLineY,'color','k','clipping','off');
	case 'BOX'
        [BoxLineX,BoxLineY] = meshgrid(Boxx,Boxy);
        line(BoxLineX',BoxLineY','color','k','clipping','off');
        line(BoxLineX,BoxLineY,'color','k','clipping','off');
	case 'VERTICAL'
        [VerticalGridX,VerticalGridY] = meshgrid(Gridx,Boxy);
        line(VerticalGridX,VerticalGridY,'color','k','clipping','off');
	case 'HORIZONTAL'
        [HorizontalGridX,HorizontalGridY] = meshgrid(Boxx,Gridy);
        line(HorizontalGridX',HorizontalGridY','color','k','clipping','off');
		
        
end

% plot Head 
CornerH = text(cornerx,cornery,Data(1,1),'clipping','off','horizontalalignment','center','verticalalignment','middle');     
HeadH = text(headx,heady,Data(1,2:end),'clipping','off','horizontalalignment','center','verticalalignment',HeadVerticalAlignment);     
SideH = text(sidex,sidey,Data(2:end,1),'clipping','off','horizontalalignment',SideHorizontalAlignment,'verticalalignment','middle');     

for colnr = 2:numC
     for rownr = 2:numR
          if isnumeric(Data(rownr,colnr))
               Data(rownr,colnr) = num2str(Data(rownr,colnr));
          end
          TabH(rownr-1,colnr-1) = text(tablex(colnr-1),tabley(rownr-1),Data(rownr,colnr),'tag',['table(' num2str(rownr) ',' num2str(colnr) ')'],...
               'clipping','off','horizontalalignment','center','verticalalignment','middle');
     end
end

if nargout==1
    OutHandles = ones(size(Data)).*NaN;
    if ~isempty(CornerH);OutHandles(1,1) = CornerH;end
    if ~isempty(HeadH);OutHandles(1,2:end) = HeadH;end
    if ~isempty(SideH);OutHandles(2:end,1) = SideH;end
    if ~isempty(TabH);OutHandles(2:end,2:end) = TabH;end
    TabH = OutHandles;
end
    
%=============================================
function [x,y,horspace,verspace] = divideaxis(nC,nR)
horspace = 1/(nC);
verspace = 1/(nR);
x = -0.5*horspace + [1:nC]*horspace;
y = -0.5*verspace + [1:nR]'*verspace;
y = flipud(y);
