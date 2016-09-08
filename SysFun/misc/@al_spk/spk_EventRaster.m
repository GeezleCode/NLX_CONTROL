function h = spk_EventRaster(s,yRange,EvType,win,EvMarker,varargin)

% rasters of spikesin current axes
% plots currenttrials
% 
% h = spk_EventRaster(s,yRange,EvType,win,EvMarker,varargin)
%
% INPUT
% yRange ... plot the rasters in the given range of the y axis
%                if its empty it plots the first trial at 1 etc.
% EvType ..... event index (numeric) or eventlabel (string) -> rasters of
%              events.
% EvMarker ... symbol, vertical 'line' or matlab marker of line object
%
% OUTPUT
% h ... handle to rasters

if nargin<2
     EvMarker = '.';
end

if isempty(EvType)
    [nEv,nTr] = size(s.events);
    EvType = 1:nEv;
end

if ischar(EvType)& ~isempty(EvType)
    nEv = 1;
    EvType = {EvType};
else
    nEv = length(EvType);
end

%% check current channels and trials
[currenttrials,s] = spk_CheckCurrentTrials(s,true); 
numTr = length(currenttrials);

%% Y range
if isempty(yRange)
    yRange = [1-0.5 numTr+0.5];
end
yTrd = (yRange(2)-yRange(1))/numTr;
yTr = [yRange(1)+(yTrd*0.5) :yTrd: yRange(2)-(yTrd*0.5)];

%% loop trials
for i = 1:numTr
    j = s.currenttrials(i);
    
    for iEv = 1:nEv
        
        if iscell(EvType)
            x = s.events{spk_findEventlabel(s,EvType(iEv)),j}';
            LineLength = yTrd;
        elseif isnumeric(EvType)
            x = s.events{EvType(iEv),j}';
            LineLength = yTrd;
        end
        if isempty(x);continue;end
        
        if ~isempty(win)
            x=x(x>=win(1)&x<=win(2));
        end
        
        % spike markers
        switch EvMarker
            case 'line'
                % verticale lines
                [YDATA,XDATA] = ndgrid([yTr(i)-LineLength/2;yTr(i)+LineLength/2],x);% TTL's dot as vertical lines
                h{iEv} = line(XDATA,YDATA,'color','k','clipping','on',varargin{:});
            otherwise
                [YDATA,XDATA] = ndgrid(yTr(i),x);
                h{iEv} = line(XDATA,YDATA, ...
                    'linestyle','none', ...
                    'marker',EvMarker,'markersize',4, ...
                    'markerfacecolor','k', ...
                    'markeredgecolor','none', ...
                    'clipping','on',varargin{:});
        end
    end
end
