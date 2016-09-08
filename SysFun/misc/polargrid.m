function [ch,gh,rh] = polargrid(circlegrid,radangles,varargin);

% [ch,gh,rh] = polargrid(circlegrid,radangles,varargin)
%
% INPUT
% circlegrid ... vector of radii for the circular grid
% radangles .... vector of angles to plot radius lines
% varargin ..... line properties
% OUPUT
% ch ... handle of the outer circle
% gh ... handle of the grid circles
% rh ... handle of the angular radii
%
% mag 11.11.2002

if isempty(varargin)
     varargin = {'linestyle',':','color','k'};
end
ch = [];
gh = [];
rh = [];

BigCircle = max(circlegrid);
[x,y] = pol2cart([0:0.001:2*pi],BigCircle);
ch = line(x,y,'clipping','off',varargin{:});
circlegrid(find(circlegrid==BigCircle)) = [];

for currCircle = circlegrid
     [x,y] = pol2cart([0:0.001:2*pi],currCircle);
     h = line(x,y,'clipping','off',varargin{:});
     gh = cat(1,gh,h);
end

for currRad = radangles
     [x,y] = pol2cart(currRad,BigCircle);
     h =line([0 x],[0 y],'clipping','off',varargin{:});
     rh = cat(1,rh,h);
end

set(gca,'dataaspectratio',[1,1,1]);