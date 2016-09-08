function h = TimeRasterPlot(t,yrange,option,scale,prop)

% plots timestamp data
% INPUT
% t ... cell array with timestamps
% yrange ... the range of the y axis to plot the trains in
% option ... can be 'MARKER' or 'LINE'
% scale ... scales the size of the 'LINE'
% prop ... properties of the plotted objects
%
% OUTPUT
% h ... handles to the plotted objects

t = t(:);
m = length(t);
n = cellfun('length',t);
d = diff(yrange)/m;
y = [yrange(1):d:yrange(2)]+d/2;
for i=1:m
    
    switch upper(option)
        case 'LINE'
            ydata = repmat([y(i)-abs(d)*scale/2;y(i)+abs(d)*scale/2],[1 n(i)]);
            xdata = repmat([t{i}(:)'],[2,1]);
            h{i} = line(xdata,ydata, ...
                'linestyle','-', ...
                'marker','none',...
                'color','k', ...
                'linewidth',0.5, ...
                'clipping','off',prop{:});
        case 'MARKER'
            ydata = ones(1,n(i)).*y(i);
            xdata = t{i};
            h(i) = line(xdata,ydata, ...
                'linestyle','none', ...
                'marker','.',...
                'clipping','off',prop{:});
    end
end