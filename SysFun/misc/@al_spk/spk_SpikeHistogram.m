function [values,binedges,h] = spk_SpikeHistogram(s,timewin,binwidth,HistMode,PlotType,varargin)

% calculates histograms for spikedata defined by s.currenttrials and s.currentchan
%
% function [h,values,binedges] = spk_histogram(s,HistMode,PlotType,varargin)
%
% HistMode 1 absolute counts
%           2 mean counts
%           3 mean frequency
% PlotType LINE BAR PATCH

if isempty(s.currenttrials)
     error('Please set current trials !');
end
numtrials = length(s.currenttrials);

if isempty(s.currentchan)
    numchan = size(s.spk,1);
    s.currentchan = 1:numchan;
else
    numchan = length(s.currentchan);
end
numspk = sum(cellfun('length',s.spk(:,s.currenttrials)),2);


% time bins
if isempty(timewin)
    error('Please set time window !');
end

binedges = [timewin(1):binwidth:timewin(2)];
numbins = length(binedges);

% scale values
switch HistMode
    case 1;normfactor=1;
    case 2;normfactor=1./numtrials;
    case 3;normfactor=1./(numtrials.*binwidth*10^s.timeorder);
    otherwise
        normfactor=1;
end

% calculate histogram
for i=s.currentchan
    if numspk(i)>0
        values(:,find(s.currentchan==i)) = histc(cat(1,s.spk{i,s.currenttrials}),binedges)'.*normfactor;
    else
        values(1:numbins,find(s.currentchan==i)) = NaN;
    end
end

% plot histogram
h = [];
if nargin<3;return;end

if ~isempty(s.chancolor);set(gca,'ColorOrder',s.chancolor(s.currentchan,:));end

switch upper(PlotType)
     case 'LINE'
          X = [];Y = [];
          for i = 2:numbins
               X = cat(1,X,[ones(1,numchan).*binedges(i-1);ones(1,numchan).*binedges(i)]);
               Y = cat(1,Y,[values(i-1,:);values(i-1,:)]);
          end
          h = line(X,Y,varargin{:});
     case 'BAR'
         if size(values,2)>1;warning('multiple bars are not supported yet !');end;
          h = bar(binedges+0.5*binwidth,values);
          if ~isempty(varargin)
               set(h,varargin{:});
          end
     case 'PATCH'
         if size(values,2)>1;warning('multiple patches are not supported yet !');end;
          X = [binedges(end) binedges(1)];Y = [0 0];
          for i = 2:numbins
               X = cat(2,X,[binedges(i-1) binedges(i)]);
               Y = cat(2,Y,[values(i-1) values(i-1)]);
          end
          h = patch('Xdata',X,'ydata',Y,varargin{:});
end
