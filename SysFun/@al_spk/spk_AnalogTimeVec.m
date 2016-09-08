function t = spk_AnalogTimeVec(s,Chan)

% retrieves times of analog data bins
% t = spk_AnalogTimeVec(s,Chan)
%
% Chan ... channel name or channel nr.

%% get the channel index
if nargin<2 || isempty(Chan)
    if isempty(s.currentanalog);
        s.currentanalog = 1:size(s.analog,2);
    end
elseif ischar(Chan)
    s.currentanalog = spk_findAnalog(s,Chan);
elseif isnumeric(Chan)
    s.currentanalog = Chan;
end
nCh = length(s.currentanalog);

%% loop channels
for iCh = 1:nCh
    ChNr = s.currentanalog(iCh);
    SF = s.analogfreq(ChNr);% sample frequency
    aB = s.analogalignbin(ChNr);% align bin
    nB = size(s.analog{ChNr},2);% number of sample bins
    t{iCh} = zeros(1,nB);% time vector
    t{iCh}(aB:-1:1) = [0 : ((-1)*(1000/SF)) : ((aB-1)*(-1)*(1000/SF))];
    t{iCh}(aB:1:nB) = [0 : (1000/SF) : ((nB-aB)*(1000/SF))];
end

%% modify output
if nCh==1
    t = t{1};
end