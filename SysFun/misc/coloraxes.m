function cH = coloraxes(h,position,orientation,TickMode,TickLabel,TickPrecision,Marker,MarkerLineProps)

% plots a color bar into its own axes.
% uses image to plot the map, which cleares the 'tag' field of an axes
%
% h ........... axes handle
% position .... position in relative coordinates to h.
%               when position is left empty, colorbar is plot into h
% TickMode
%               1 - plots 'TickLabel' as ticks
%               2 - plots 'TickLabel' as ticks, but only labels the min and max tick
%               3 - plots clim values as ticks
% TickLabel ... ticks on the colormap
% Precision ... format string for sprintf
% Marker ...... Position for additional ticks drawn as a line
% MarkerLineProps ... cell array with line properties

PreGCA = gca;

if isempty(h)
    h = gca;
end

if nargin<5
    TickPrecision = '%1.0f';
end

h=h(:);
nAx = length(h);


for i=1:nAx
    parentfig = get(h(i),'parent');
    
    %% calc relative position
    if isempty(position)
        cH(i) = h(i);
    else
        oldPos = get(h(i),'position');
        oldUnits = get(h(i),'units');
        
        newHor = oldPos(1)+oldPos(3)*position(1);
        newVert = oldPos(2)+oldPos(4)*position(2);
        newWidth = oldPos(3)*position(3);
        newHeight = oldPos(4)*position(4);
        cH(i) = axes('parent',parentfig,'units',oldUnits,'position',[newHor newVert newWidth newHeight]);
    end

    %% get colormap data
    cmap = get(parentfig,'colormap');
    ncmap = size(cmap,1);
    
    clim = get(h(i),'clim');

    switch TickMode
        case 1 % plots 'TickLabel' as ticks
            TickLabel(TickLabel-clim(1)<0 | TickLabel-clim(2)>0) = [];% omit ticks out of range
            Ticks = 1+((TickLabel-clim(1))*((ncmap-1)/(clim(2)-clim(1))));
        case 2 % plots 'TickLabel' as ticks, but only labels the min and max tick
            TickLabel(TickLabel-clim(1)<0 | TickLabel-clim(2)>0) = [];% omit ticks out of range
            Ticks = 1+((TickLabel-clim(1))*((ncmap-1)/(clim(2)-clim(1))));
            TickLabel = num2cell(TickLabel);
            for j=1:length(TickLabel)
                if j==1 | j==length(TickLabel)
                    TickLabel{j} = sprintf(TickPrecision,TickLabel{j});
                else
                    TickLabel{j} = '';
                end
            end
        case 3 % plots clim values as ticks
            Ticks = [1 ncmap];
            TickLabel = cell(1,2);
            TickLabel{1} = sprintf(TickPrecision,clim(1));
            TickLabel{2} = sprintf(TickPrecision,clim(2));
            
    end
    
    if nargin>=7 && ~isempty(Marker)
        Marker = 1+((Marker-clim(1))*((ncmap-1)/(clim(2)-clim(1))));
        Marker = Marker(:)';
    else
        Marker = [];
    end

    %% plot map
    axes(cH(i));
    switch lower(orientation)
        case 'h'
             image([1:ncmap]);
             set(cH(i),'box','on', ...
                 'ylim',[0.5 1.5],'ytick',[], ...
                 'xdir','normal','xtick',Ticks,'xticklabel',TickLabel,'xAxislocation','bottom');
             if ~isempty(Marker)
                 line([Marker;Marker],repmat([0.5;1.5],[1 length(Marker)]),'color','k',MarkerLineProps{:});
             end
        case 'v'
             image([1:ncmap]');
             set(cH(i),'box','on', ...
                 'xlim',[0.5 1.5],'xtick',[], ...
                 'ydir','normal','ytick',Ticks,'yticklabel',TickLabel,'yAxislocation','right');
             if ~isempty(Marker)
                 line(repmat([0.5;1.5],[1 length(Marker)]),[Marker;Marker],'color','k',MarkerLineProps{:});
             end
                 
    end
    
end
    
axes(PreGCA);
