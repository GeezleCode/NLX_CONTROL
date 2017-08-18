function h = spk_raster(s,yRange,EvType,win,EvMarker,varargin)

% rasters of spikes or events in current axes
% plots currenttrials
% 
% h = spk_raster(s,EvType,EvMarker,varargin)
%
% INPUT
% yRange ... plot the rasters in the given range of the y axis
%                if its empty it plots the first trial at 1 etc.
% EvType ..... [] or 'SPK' -> rasters of spikes
%              event index (numeric) or eventlabel (string) -> rasters of
%              events.
% EvMarker ... symbol, vertical 'line' or matlab marker of line object
%
% OUTPUT
% h ... handle to rasters

if nargin<2
     EvMarker = '.';
end

if isempty(s.currenttrials)
    s.currenttrials = 1:size(s.spk,2);
end

if isempty(s.currentchan) & strcmp(upper(EvType),'SPK')
    s.currentchan = 1;
elseif length(s.currentchan)>1 & strcmp(upper(EvType),'SPK')
    disp('warning: just plot the first of selected channels');
    s.currentchan = s.currentchan(1);
end

numTr = length(s.currenttrials);

if isempty(yRange)
    yRange = [1-0.5 numTr+0.5];
end

%_________________________________________________
yTrd = (yRange(2)-yRange(1))/numTr;
yTr = [yRange(1)+(yTrd*0.5) :yTrd: yRange(2)-(yTrd*0.5)];

for i = 1:numTr
    j = s.currenttrials(i);
    
    if (ischar(EvType) & strcmp(upper(EvType),'SPK')) | isempty(EvType)
        x = s.spk{s.currentchan,j}';
        LineLength = 0.8*yTrd;
    elseif ischar(EvType)
        x = s.events{spk_findeventlabel(s,EvType),j}';
        LineLength = yTrd;
    elseif isnumeric(EvType)
        x = s.events{EvType,j}';LineLength = 1;
    end
     
    x=x(x>=win(1)&x<=win(2));
    
     %____________________
     % spike dots
     %____________________
     switch EvMarker
     case 'line'
          % verticale lines
          [YDATA,XDATA] = ndgrid([yTr(i)-LineLength/2;yTr(i)+LineLength/2],x);% TTL's dot as vertical lines
          h = line(XDATA,YDATA,'color','k','clipping','on',varargin{:});
     otherwise
          [YDATA,XDATA] = ndgrid(yTr(i),x);
          h = line(XDATA,YDATA, ...
               'linestyle','none', ...
               'marker',EvMarker,'markersize',4, ...
               'markerfacecolor','k', ...
               'markeredgecolor','none', ...
               'clipping','on',varargin{:});
     end
end
