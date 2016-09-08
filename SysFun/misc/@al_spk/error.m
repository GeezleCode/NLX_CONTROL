function msgOut = error(s,msgIn,caller)

% Report an error that occurred in a spike object
%
% function msgOut = error(s,msgIn)
% INPUT
% s			A @spikes object	
% msgIn		Part of the message reported to the user.
% caller		Function that threw the error.
% OUTPUT
%  msg		The complete message.
%
% BK  - 25.11.2000  - Last Change $Date: 2000/12/05 07:33:59 $
% $Revision: 1.1 $

if nargin ==3
   msg = ['@MANE2 error in ' caller ':' msgIn]; 
else
   msg =['@MANE2 error: ' msgIn]; 
end

disp(msg);
error(' ');

if nargout ==1
   msgOut = msg;
end
