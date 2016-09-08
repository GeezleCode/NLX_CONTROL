function [s,SpkChanNr] = spk_AnalogDetectSpikes(s,Threshold,StampMode,SpkChanLabel,WaveformPar)

% detect spikes in an analog signal


[TrIndex,nTr] = spk_CurrentIndex(s,{'Trial'},true,'all');
[ChIndex,nCh] = spk_CurrentIndex(s,{'Analog'},true,'all');

for iCh = 1:nCh
    
    if Threshold<0
        cAnalogData = s.analog{ChIndex(iCh)}(TrIndex,:)*(-1);
        Threshold = Threshold*(-1);
    else
        cAnalogData = s.analog{ChIndex(iCh)}(TrIndex,:);
    end
    
    [TrDummy,nBins] = size(cAnalogData);
   
    % get threshold crossing
    isThresh = cAnalogData>Threshold;
    
    % detect peaks
    isPeak = false(TrDummy,nBins);
    isPeak(:,2:end-1) = diff(cAnalogData(:,1:end-1),1,2)>0 & diff(cAnalogData(:,2:end),1,2)<0;
    
    % choose timestamp in relation peak
    switch StampMode
        case 'Peak'%do nothing
        case 'Onset'
    end
    
    % get Timestamps
    cTimeStamps = cell(1,nTr);
    for iTr = 1:nTr
        cTimeStamps{1,iTr} = s.analogtime{ChIndex(iCh)}(isThresh(iTr,:)&isPeak(iTr,:));
    end
    
    % get Waveform
    if nargin>4 && length(WaveformPar)==2
        error('Waveform extraction not implemented yet!');
    end
    
    if nargin>3 && ~isempty(SpkChanLabel)
        if ischar(SpkChanLabel)
            SpkChanLabel = {SpkChanLabel};
        end
        [s,SpkChanNr] = spk_AddSpikeChan(s,SpkChanLabel{iCh},cTimeStamps);
    end
    
end        
        
        
        
        


