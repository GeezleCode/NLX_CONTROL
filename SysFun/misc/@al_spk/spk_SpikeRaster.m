function h = spk_SpikeRaster(s,yRange,EvType,win,EvMarker,varargin)

% rasters of spikes or events in current axes
% plots currenttrials
% 
% h = spk_SpikeRaster(s,yRange,EvType,win,EvMarker,varargin)
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

%% check current channels and trials
[TrIndex,nTr] = spk_CurrentIndex(s,{'Trial'},true,'all');

%% select event array
if isempty(EvType) || (ischar(EvType)&&strcmpi(EvType,'SPK'))
    EvArray = s.spk(spk_CurrentIndex(s,{'Spike'},true,'index'),:);
    EvCatDim = 2;
elseif isnumeric(EvType) && ~isempty(EvType)
    EvArray = s.events(EvType,:);
    EvCatDim = 1;
else
    EvArray = s.events(spk_findEventlabel(s,EvType),:);
    EvCatDim = 1;
end

%% Y range
if isempty(yRange)
    yRange = [1-0.5 nTr+0.5];
end
yTrd = (yRange(2)-yRange(1))/nTr;
yTr = [yRange(1)+(yTrd*0.5) :yTrd: yRange(2)-(yTrd*0.5)];

%% loop trials
for iTr = 1:nTr
    TrNr = TrIndex(iTr);
    
    x = cat(EvCatDim,EvArray{:,TrNr});
    nx = length(x);
    LineLength = 0.8*yTrd;
     
    if ~isempty(win)
        x=x(x>=win(1)&x<=win(2));
    end
    
     % spike markers
     switch EvMarker
         case 'line'
             % verticale lines
             [YDATA,XDATA] = ndgrid([yTr(iTr)-LineLength/2;yTr(iTr)+LineLength/2;NaN],x);% TTL's dot as vertical lines
             XDATA(3,:) = NaN;
             h = line(XDATA(:),YDATA(:),'color','k','clipping','on',varargin{:});
         case '.'
             [YDATA,XDATA] = ndgrid(yTr(iTr),x);
             h = line(XDATA,YDATA, ...
                 'linestyle','none', ...
                 'marker',EvMarker,'markersize',4, ...
                 'markerfacecolor','none', ...
                 'markeredgecolor','k', ...
                 'clipping','on',varargin{:});
         otherwise
             [YDATA,XDATA] = ndgrid(yTr(iTr),x);
             h = line(XDATA,YDATA, ...
                 'linestyle','none', ...
                 'marker',EvMarker,'markersize',4, ...
                 'markerfacecolor','k', ...
                 'markeredgecolor','none', ...
                 'clipping','on',varargin{:});
     end
end
