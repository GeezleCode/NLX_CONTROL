function[s_index] = rkradix(us_rad)
%	AUTH: RAIMUND KLEISER
%	VERS: 1.0
%	DATE: 15/01/98
% 	GOAL: decode RADIX

% globale Variablen

% Umwandlung in Buchstaben
% input		Zahl (Code)
% output	Buchstaben-Triplex 

%                   1         2         3         4
%          1234567890123456789012345678901234567890
s_radix = ' ABCDEFGHIJKLMNOPQRSTUVWXYZ$._0123456789';
s_index = '   ';

s_index1 = s_radix (fix(us_rad / 1600 + 1));
s_index2 = s_radix (fix(rem(us_rad, 1600) / 40 +1));
s_index3 = s_radix (fix(rem(rem(us_rad, 1600), 40) +1));

s_index = [s_index1, s_index2, s_index3];
