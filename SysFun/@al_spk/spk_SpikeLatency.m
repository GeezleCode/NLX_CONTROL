function [Time,Value] = spk_SpikeLatency(s,Mode,varargin)

% Calculates latencies of spiketrains
% Mode .... 'DEFAULT'
% 			Sigma 
% 			Win
% 			Thresh
% 			ThreshDur

Mode = 'DEFAULT';
NumCurrChan = length(spk_CheckCurrentChannels(s,0));
numCurrTr = length(spk_CheckCurrentTrials(s,0));

for iC = 1:NumCurrChan
    currChan = s.currentchan(iC);
    
    switch Mode
        case 'DEFAULT'
            Sigma = varargin{1};
            Win = varargin{2};
            AboveThresh = varargin{3}(1);
            BelowThresh = varargin{3}(2);
            ThreshDur = varargin{4};
            SpkNuminBinCriterion = 0.5;
            SpkNumBinWin = 10;
            
            
            [M,BinTimes] = spk_density(spk_set(s,'currentchan',currChan),Sigma,Win);
            CurrSpikeTrain = [s.spk{currChan,s.currenttrials}];
            CurrSpikeTrain(CurrSpikeTrain<(Win(1))&CurrSpikeTrain>(Win(2))) = [];
            
            if AboveThresh<5;AboveThresh=5;end
            
            
            
            % find first deflection in density curve
            isAbove = 0;
            isBelow = 0;
            currAboveThreshDur = 0;
            currBelowThreshDur = 0;
            cb = 0;
            latbin = 0;
            NumBin = length(M);
            while currBelowThreshDur<=ThreshDur & currAboveThreshDur<=ThreshDur
                cb = cb+1;
                if NumBin==cb;break;end
                
                % above or below
                if M(cb)>AboveThresh;
                    currAboveThreshDur = currAboveThreshDur+1;
                    if currBelowThreshDur>0;currBelowThreshDur=0;end
                elseif M(cb)<BelowThresh
                    currBelowThreshDur = currBelowThreshDur+1;
                    if currAboveThreshDur>0;currAboveThreshDur=0;end
                end
            end
            if NumBin==cb;latbin = NaN;
            else latbin = cb-ThreshDur;end
            
            if currBelowThreshDur == 0 & currAboveThreshDur>0;isAbove = 1;end
            if currBelowThreshDur > 0 & currAboveThreshDur==0;isBelow = 1;end
            
            
            % compensate for smoothing
            if ~isnan(latbin) & isAbove==1 & isBelow==0
                SpkNuminLatBin = sum(CurrSpikeTrain>=(Win(1)+BinTimes(latbin)-SpkNumBinWin/2) & ...
                    CurrSpikeTrain<=(Win(1)+BinTimes(latbin)+SpkNumBinWin/2));
                
                % find first maximum in density
                cb = latbin;
                while (~isnan(cb) & cb<NumBin & M(cb+1)>M(cb))
                    cb = cb+1;
                    if cb == NumBin; cb=NaN;end
                end
                maxBin = cb;
                SpkNuminMaxBin = sum(CurrSpikeTrain>=(Win(1)+BinTimes(maxBin)-SpkNumBinWin/2) & ...
                    CurrSpikeTrain<=(Win(1)+BinTimes(maxBin)+SpkNumBinWin/2));
                
                if SpkNuminMaxBin>=1/SpkNuminBinCriterion
                    % sliding window backward down the hill
                    cb = maxBin;
                    SpkNuminCurrBin = SpkNuminMaxBin;
                    while (~isnan(cb) & cb>1 & SpkNuminCurrBin>SpkNuminLatBin+(SpkNuminMaxBin-SpkNuminLatBin).*SpkNuminBinCriterion)
                        cb = cb-1;
                        SpkNuminCurrBin =  sum(CurrSpikeTrain>=(Win(1)+BinTimes(cb)-SpkNumBinWin/2) & ...
                            CurrSpikeTrain<=(Win(1)+BinTimes(cb)+SpkNumBinWin/2));
                        if cb == SpkNumBinWin/2; cb=NaN;end
                    end
                    latbin = cb;
                end
                
            elseif ~isnan(latbin) & isAbove==0 & isBelow==1
                SpkNuminLatBin = sum(CurrSpikeTrain>=(Win(1)+BinTimes(latbin)-SpkNumBinWin/2) & ...
                    CurrSpikeTrain<=(Win(1)+BinTimes(latbin)+SpkNumBinWin/2));
                
                % find first minimum in density
                cb = latbin;
                while (~isnan(cb) & cb<NumBin & M(cb+1)<M(cb))
                    cb = cb+1;
                    if cb == NumBin; cb=NaN;end
                end
                maxBin = cb;
                
				if ~isnan(maxBin);
					SpkNuminMaxBin = sum(CurrSpikeTrain>=(Win(1)+BinTimes(maxBin)-SpkNumBinWin/2) & ...
						CurrSpikeTrain<=(Win(1)+BinTimes(maxBin)+SpkNumBinWin/2));
					
					if SpkNuminMaxBin>=1/SpkNuminBinCriterion
						% sliding window backward down the hill
						cb = maxBin;
						SpkNuminCurrBin = SpkNuminMaxBin;
						while (~isnan(cb) & cb>1 & SpkNuminCurrBin<SpkNuminLatBin-(SpkNuminLatBin-SpkNuminMaxBin).*SpkNuminBinCriterion)
							cb = cb-1;
							SpkNuminCurrBin =  sum(CurrSpikeTrain>=(Win(1)+BinTimes(cb)-SpkNumBinWin/2) & ...
								CurrSpikeTrain<=(Win(1)+BinTimes(cb)+SpkNumBinWin/2));
							if cb == 5; cb=NaN;end
						end
						latbin = cb;
					end
				end
                
            end
            if isnan(latbin);Time = NaN;Value = NaN;
            else;Time = BinTimes(latbin);Value = M(latbin);
            end
        end
    end
