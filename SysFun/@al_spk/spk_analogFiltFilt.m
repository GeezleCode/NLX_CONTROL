function s = spk_analogFiltFilt(s,FilterFun,FilterParam)

numAna = length(s.currentanalog);

for iA = s.currentanalog
    iANr = find(s.currentanalog==iA);

    switch FilterFun
        case 'butter'
            FilterParam{2} = FilterParam{2} ./ (s.analogfreq(iA)/2);
            [b,a] = butter(FilterParam{:});
    end
    
% %     The length of the input x must be more than three times
% %     the filter order, defined as max(length(b)-1,length(a)-1).
%     if size(s.analog{iA},2) 
%         error('The length of the input x must be more than three times the filter order');
%     end
    
    [NumTrials,NumSamples] = size(s.analog{s.currentanalog(iA)});
    if isempty(s.currenttrials)
        s.currenttrials = 1:NumTrials;
    end
    NumTrials = length(s.currenttrials);
    
    for iT = 1:NumTrials
        currNaNs = find(~isnan(s.analog{iA}(s.currenttrials(iT),:)));
        if isempty(currNaNs)
            warning('spk_analogFiltFilt: no data in trial?');
        elseif length(currNaNs)<= max(length(b)-1,length(a)-1)
            warning('spk_analogFiltFilt: to few samples in trial?');
        elseif any(diff(currNaNs)>1)
            warning('spk_analogFiltFilt: missing data in trial?');
        else
            s.analog{iA}(s.currenttrials(iT),[currNaNs(1):currNaNs(end)] ) = (filtfilt(b,a,s.analog{iA}(s.currenttrials(iT),[currNaNs(1):currNaNs(end)] )));
        end
    end

end

