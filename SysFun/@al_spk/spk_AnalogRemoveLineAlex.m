function s = spk_AnalogRemoveLineAlex(s,n,cutoff,ChanName)

% Removes line noise via method suggested by Alex.
% s = spk_AnalogRemoveLineAlex(s,n,cutoff,ftype,ChanName)
%
% n ......... filter order
% cutoff .... scaler for high/low pass, 2 element vecto for stop- and
%             passband

%% get the channel index
if nargin<5 || isempty(ChanName)
    if isempty(s.currentanalog);
        s.currentanalog = 1:size(s.analog,2);
    end
else
    s.currentanalog = spk_findAnalog(s,ChanName);
end
numAna = length(s.currentanalog);

%% get trials
numTrials = spk_TrialNum(s);
if isempty(s.currenttrials)
    s.currenttrials = 1:numTrials;
end
numCurrenttrials = length(s.currenttrials);


%% loop channels
for iA = 1:numAna
    iANr = s.currentanalog(iA);
    
    % filter parameter
    cutoff = cutoff ./ (s.analogfreq(iANr)/2);
    [b,a] = butter(n,cutoff,'bandpass');
    
    for iT = 1:numCurrenttrials
        currNaNs = find(~isnan(s.analog{iANr}(s.currenttrials(iT),:)));
        
        if isempty(currNaNs)
            warning('spk_analogFiltFilt: no data in trial?');
        elseif length(currNaNs)<= max(length(b)-1,length(a)-1)
            warning('spk_analogFiltFilt: to few samples in trial?');
        elseif any(diff(currNaNs)>1)
            warning('spk_analogFiltFilt: missing data in trial?');
        else
            
            % Data must have length more than 3 times filter order
            if length([currNaNs(1):currNaNs(end)])<=3*n
                s.analog{iANr}(s.currenttrials(iT),[currNaNs(1):currNaNs(end)] ) = NaN;
            else
                CurrSignal = s.analog{iANr}(s.currenttrials(iT),[currNaNs(1):currNaNs(end)] );
                LineSignal = filtfilt(b,a,CurrSignal);
                s.analog{iANr}(s.currenttrials(iT),[currNaNs(1):currNaNs(end)] ) = CurrSignal-LineSignal;
            end
            
        end
    end
end

