function [h,X,Y] = polarpatch(theta,R,varargin)

% h = polarpatch(theta,R,varargin)

% wrap angles
theta = rem(rem(theta,2*pi)+2*pi,2*pi); % Make sure 0 <= theta <= 2*pi

[X,Y] = pol2cart(theta,R);
h = patch('xdata',X,'ydata',Y,varargin{:});