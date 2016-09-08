function s = spk_AnalogDeleteChannel(s,DelChan)

% delete analog channels
%
% s = spk_AnalogDeleteChannel(s,DelChan)
%
% DelChan ... cell array of channel names
%             'ALL' deletes all channels
%             index of analog channels
%             when omitted or empty, all except s.currentchan are deleted

if nargin<2
    DelChan = [];
end

nCh = length(s.analog);

if isempty(DelChan)
    DelChanIndex = setdiff(1:nCh,s.currentanalog);
elseif iscell(DelChan)
	DelChanIndex = spk_findAnalog(s,DelChan);
elseif ischar(DelChan)
    if strcmpi(DelChan,'ALL')
        DelChanIndex = 1:nCh;
    else
        DelChanIndex = spk_findAnalog(s,DelChan);
    end
elseif isnumeric(DelChan)
	DelChanIndex = DelChan;
end

s.analog(DelChanIndex) = []; 
s.analogunits(DelChanIndex) = [];
s.analogname(DelChanIndex) = [];
s.analogtime(DelChanIndex) = [];
s.analogfreq(DelChanIndex) = [];
s.analogalignbin(DelChanIndex) = [];
s.currentanalog = [];
