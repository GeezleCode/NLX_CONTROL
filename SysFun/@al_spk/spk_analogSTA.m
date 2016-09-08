function [STA,STASegmentTimeVec] = spk_analogSTA(s,STASegment,TimeWin);

% Spike Triggered Average of an analog channel
% STA = spk_analogSTA(s,STASegment,TimeWin)
%
% STASegment ... in ms
% TimeWin ...... in ms
% STA .......... raw data, analog signal for every spike, cell(AnalogCh,SPKCh,Trial)

cANum = length(s.currentanalog);
cCNum = length(s.currentchan);
cTNum = length(s.currenttrials);
STA = cell(cANum,cCNum,cTNum);

for iA = 1:cANum
    t = spk_analogtimematrix(spk_set(s,'currentanalog',s.currentanalog(iA)));
    SF = s.analogfreq(s.currentanalog(iA));
    [cNTr,cNBins] = size(s.analog{s.currentanalog(iA)});
    
    STASegmentTimeBin = 1000/SF;
    STASegmentTimeBinNum = STASegment/STASegmentTimeBin;
    STASegmentTimeVec{iA} = [ ...
            (STASegmentTimeBinNum.*STASegmentTimeBin)*(-1):STASegmentTimeBin:STASegmentTimeBin*(-1) ...
            0 ...
            STASegmentTimeBin:STASegmentTimeBin:STASegmentTimeBinNum.*STASegmentTimeBin];
    STASegmentTimeVecLength = (length(STASegmentTimeVec{iA})-1)/2;
    
    STA{iA} = zeros(cTNum,STASegmentTimeVecLength*2+1,cCNum,3);

    for iC = 1:cCNum
        for iT = 1:cTNum
            cSpikeTrainSegment = s.spk{s.currentchan(iC),s.currenttrials(iT)}( ...
                s.spk{s.currentchan(iC),s.currenttrials(iT)}>=TimeWin(1) & s.spk{s.currentchan(iC),s.currenttrials(iT)}<=TimeWin(2));
            cSpikeNum = length(cSpikeTrainSegment);
            STA{iA,iC,iT} = zeros(cSpikeNum,STASegmentTimeVecLength*2+1).*NaN;
            for iS = 1:cSpikeNum
                [cAnalogAlignOffset,cAnalogAlignIndex] = min(abs(t-cSpikeTrainSegment(iS)));
                cAnalogIndex = [cAnalogAlignIndex-STASegmentTimeVecLength:1:cAnalogAlignIndex+STASegmentTimeVecLength];
                
                cAnalogIndexIndex = (cAnalogIndex>=1&cAnalogIndex<=cNBins);
                cAnalogIndex = cAnalogIndex(cAnalogIndexIndex);
                
                STA{iA,iC,iT}(iS,cAnalogIndexIndex) = s.analog{s.currentanalog(iA)}(s.currenttrials(iT),cAnalogIndex);
            end
        end
    end
end