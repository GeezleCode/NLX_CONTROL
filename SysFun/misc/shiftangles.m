function out = shiftangles(in,center)

% function out = shiftangles(in,center)
%
% shifts an array of angles to the period [-pi pi]
% center becomes 0

out = in - center;

i = find(out<-pi);
f = ceil(abs(ceil(out(i)./pi))./2);
out(i) = out(i)+f.*(2*pi);

i = find(out>pi);
f = ceil(abs(floor(out(i)./pi))./2);
out(i) = out(i)-f.*(2*pi);

