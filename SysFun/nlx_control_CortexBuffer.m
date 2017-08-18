classdef nlx_control_CortexBuffer
    properties
        TrialStartedFlag
        TrialStartedCount
        TrialEndedCount
        TrialReadCount
        TrialOmittedCount
        Pointer
        
        ReadFlag
        TrialStartTime
        TrialID
        Block
        Condition
        StimulusCodes
        ParamArray
    end
    methods
        function CTX = nlx_control_CortexBuffer(nTrials,nStimPerTrial,nParParStim,nParam)
            CTX.TrialStartedFlag = 0;
            CTX.TrialStartedCount = 0;
            CTX.TrialEndedCount = 0;
            CTX.TrialReadCount = 0;
            CTX.TrialOmittedCount = 0;
            CTX.Pointer = 0;

            CTX.ReadFlag = false(nTrials,1);
            CTX.TrialStartTime = zeros(nTrials,1).*NaN;
            CTX.TrialID = zeros(nTrials,1).*NaN;
            CTX.Block = zeros(nTrials,1).*NaN;
            CTX.Condition = zeros(nTrials,1).*NaN;
            CTX.StimulusCodes = zeros(nTrials,nParParStim,nStimPerTrial).*NaN;
            CTX.ParamArray = cell(nTrials,1);
            CTX.ParamArray(:) = {zeros(1,nParam).*NaN};
        end
    end
end
